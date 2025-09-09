# 🔒 Bem-vindo à organização GitHub da FESF-SUS

## 📌 Sobre este repositório

Este repositório centraliza as **diretrizes de desenvolvimento**, **templates** e **workflows reutilizáveis** da FESF-SUS.
O objetivo é padronizar nossas práticas e facilitar a integração de novos membros.

---

## 🚀 Recursos Essenciais

### Boilerplates Oficiais (Apenas para membros da organização)

Para garantir consistência e acelerar o início de novos projetos, utilize sempre os boilerplates oficiais:

- **[Boilerplate Backend (Python/FastAPI)](https://github.com/fesflabs/boilerplate_back)** → Estrutura para APIs com FastAPI, banco de dados configurado e `Dockerfile` otimizado.
- **[Boilerplate Frontend (React/Next.js)](https://github.com/fesflabs/boilerplate_front)** → Base para aplicações web com Next.js, CI configurado e `Dockerfile` otimizado.

---

## 📖 Documentos de Referência

- [Diretrizes de Contribuição (`CONTRIBUTING.md`)](./CONTRIBUTING.md)Explica em detalhe os padrões de **branches**, **commits**, **versionamento** e **pull requests**.
- [Templates de Issues e PRs](.github/ISSUE_TEMPLATE) Incluem templates para **bugs**, **features**, **tarefas**, **melhorias técnicas**, **histórias de usuário** e **pedidos DevOps**.
- [Workflows Reutilizáveis](.github/workflows)Padrões de **CI/CD** da organização que podem (e devem) ser usados pelos repositórios da FESF-SUS.Exemplos:

  - `ci-checks.yml` → testes e verificações básicas.
  - `deploy.yml` → fluxo de deploy.

---

## 📂 Organização dos Repositórios

Todos os repositórios seguem convenção de nomes e escopos:

- **boilerplate-** → Estruturas base de projetos.
- **-devops** → Automação de infraestrutura.
- **-front / -back** → Aplicações de frontend e backend.
- **-docs** → Documentação interna.

---

## ✅ Regras Gerais

- Todo repositório deve conter:

  - `README.md` com descrição clara.
  - Templates de Issues e PRs (preferencialmente os da organização).
  - Workflows de CI/CD configurados.
- Branches padrão:

  - **main** → Produção
  - **homolog** → Homologação
  - **develop** → Desenvolvimento

---

> 📌 Este documento serve como **ponto de entrada**.
> Para detalhes técnicos, consulte o [CONTRIBUTING.md](./CONTRIBUTING.md).
