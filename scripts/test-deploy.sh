#!/usr/bin/env bash
# Testa localmente (com act) o .github/workflows/deploy.yml deste repositório,
# comparando a versão do main (atual) com a do seu working tree (alterada).
# Rode antes de abrir PR que mexa no deploy.yml: os projetos usam @main, então
# a mudança vale para todos assim que entra no main.
#
# Uso (na raiz do repo):  ./scripts/test-deploy.sh
#
# Requisitos: docker, act, git. Usa a porta 5000 (registry local temporário).
# Nada é enviado ao GitHub; tudo é removido no final.
set -euo pipefail

CENTRAL="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
REG_NAME="deploy-test-registry"
ACT_IMAGE="ghcr.io/catthehacker/ubuntu:act-22.04"

cleanup() {
  for s in a b c d e; do
    [ -d "$WORK/proj_$s" ] && docker compose -p "proj_$s" -f "$WORK/proj_$s/docker-compose.yml" down -v >/dev/null 2>&1 || true
  done
  docker rm -f "$REG_NAME" >/dev/null 2>&1 || true
  docker images --format '{{.Repository}}:{{.Tag}}' | grep '^localhost:5000/test/app' | xargs -r docker rmi >/dev/null 2>&1 || true
  echo "Logs mantidos em: $WORK"
}
trap cleanup EXIT

cd "$WORK"
git init -q && git config user.email test@local && git config user.name test
mkdir -p .github/workflows

# 1. Duas versões do deploy: main (atual) e working tree (nova)
git -C "$CENTRAL" show main:.github/workflows/deploy.yml > .github/workflows/deploy-old.yml
cp "$CENTRAL/.github/workflows/deploy.yml" .github/workflows/deploy-new.yml

# O job "Verificar Aprovação" usa actions/github-script, que no act exige um
# token real do GitHub. Ele é igual nas duas versões, então vira um no-op em ambas.
for f in deploy-old deploy-new; do
  python3 - ".github/workflows/$f.yml" <<'EOF'
import sys
p = sys.argv[1]; s = open(p).read()
a = s.index('      - name: Verificar Reviews'); b = s.index('  deploy:')
s = s[:a] + '      - name: Verificar Reviews (no-op no teste)\n        run: "true"\n\n' + s[b:]
open(p, 'w').write(s)
EOF
done

# 2. Projetos compose de teste (alpine no lugar da aplicação)
for s in a b c d e; do
  mkdir -p "proj_$s"
  cat > "proj_$s/docker-compose.yml" <<'EOF'
services:
  app:
    image: ${IMAGE_TAG:-alpine:3.20}
    command: ["sleep", "3600"]
    env_file:
      - path: .env
        required: false
EOF
done

# 3. Callers: um por cenário
# mk <cenário> <deploy-old|deploy-new> <backend|frontend> <explicit|inherit> [env_keys]
mk() {
  {
    cat <<EOF
name: cenario-$1
on: push
jobs:
  deploy:
    uses: ./.github/workflows/$2.yml
    with:
      project_type: $3
      service_name: app
      working_directory: proj_$1
      migration_command: "true"
      runner_labels: '["ubuntu-latest"]'
      environment_name: develop
EOF
    [ -n "${5:-}" ] && echo "      env_keys: '$5'"
    if [ "$4" = inherit ]; then
      echo "    secrets: inherit"
    else
      cat <<'EOF'
    secrets:
      REGISTRY_USERNAME: ${{ secrets.REGISTRY_USERNAME }}
      REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
      PROD_DB_HOST: ${{ secrets.PROD_DB_HOST }}
      JWT_SECRET: ${{ secrets.JWT_SECRET }}
EOF
    fi
  } > ".github/workflows/caller-$1.yml"
}
mk a deploy-old backend  explicit
mk b deploy-new backend  explicit
mk c deploy-new backend  inherit "DATABASE_URL SECRET_KEY ALLOWED_HOSTS PROD_DB_HOST FALTANDO"
mk d deploy-old frontend explicit
mk e deploy-new frontend explicit

# 4. Secrets e vars falsos
cat > secrets.env <<'EOF'
REGISTRY_USERNAME=testuser
REGISTRY_PASSWORD=testpass
PROD_DB_HOST=dbhost-secret
JWT_SECRET=jwt-secret
DATABASE_URL=postgres://u:p%40s$s@h:5432/db
SECRET_KEY=k#1$x
EOF
cat > vars.env <<'EOF'
ORG_REGISTRY_URL=localhost:5000
REPO_IMAGE_NAME=test/app
NETWORK_NAME=testnet
LINK_ACESSO=https://link
TITLE=Titulo
ALLOWED_HOSTS=cms.dev,localhost
EOF

git add -A && git commit -qm test
SHA="$(git rev-parse HEAD)"

# 5. Registry local com a imagem que o deploy vai "baixar"
if ss -ltn | grep -q ':5000 '; then echo "Porta 5000 ocupada; libere-a e rode de novo."; exit 1; fi
docker run -d --name "$REG_NAME" -p 5000:5000 registry:2 >/dev/null
docker pull -q alpine:3.20 >/dev/null
sleep 2
docker tag alpine:3.20 "localhost:5000/test/app:$SHA"
docker push -q "localhost:5000/test/app:$SHA" >/dev/null

# 6. Roda os cenários
fail=0
for s in a b c d e; do
  if act push -W ".github/workflows/caller-$s.yml" --secret-file secrets.env --var-file vars.env \
       -P "ubuntu-latest=$ACT_IMAGE" --pull=false --env-file /dev/null > "act-$s.log" 2>&1; then
    echo "✅ cenário $s: deploy OK"
  else
    echo "❌ cenário $s: deploy falhou (ver $WORK/act-$s.log)"; fail=1
  fi
done

# 7. Compara o ambiente recebido pelos containers
envof() {
  docker inspect "proj_$1-app-1" --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null \
    | grep -v -e '^PATH=' -e '^$' | sort
}
check() { if eval "$2"; then echo "✅ $1"; else echo "❌ $1"; fail=1; fi; }

echo
check "backend sem env_keys: ambiente igual entre atual e nova" 'diff <(envof a) <(envof b) >/dev/null'
check "frontend sem env_keys: ambiente igual entre atual e nova" 'diff <(envof d) <(envof e) >/dev/null'
check "env_keys grava DATABASE_URL (com %40 e \$ preservados)" 'envof c | grep -qxF "DATABASE_URL=postgres://u:p%40s\$s@h:5432/db"'
check "env_keys grava SECRET_KEY (com # e \$ preservados)"    'envof c | grep -qxF "SECRET_KEY=k#1\$x"'
check "env_keys lê das vars quando não há secret"            'envof c | grep -qxF "ALLOWED_HOSTS=cms.dev,localhost"'
check "env_keys não duplica chave já gravada (PROD_DB_HOST)" '[ "$(envof c | grep -c ^PROD_DB_HOST=)" = 1 ]'
check "chave inexistente gera só aviso"                      'grep -q "FALTANDO sem valor" act-c.log'
check "secrets: inherit funciona com REGISTRY_* opcional"    'grep -q "Login Succeeded" act-c.log'

echo
echo "Ambiente do container no cenário c (nova + env_keys):"
envof c | sed 's/^/   /'
echo
[ "$fail" = 0 ] && echo "RESULTADO: tudo OK" || echo "RESULTADO: há falhas"
exit "$fail"
