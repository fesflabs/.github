# Diretrizes de Contribuição

Este documento fornece as diretrizes para contribuir com o projeto, incluindo padrões para branches, commits e pull requests.

## Sumário

- [Padrão de Branches](#padrão-de-branches)
  - [Branches Principais](#branches-principais)
  - [Branches de Vida Curta](#branches-de-vida-curta)
- [Commits Convencionais](#commits-convencionais)
- [Versionamento e Releases](#versionamento-e-releases)
- [Boas Práticas de Pull Requests](#boas-práticas-de-pull-requests)

---

## Padrão de Branches

### Branches Principais

- **`main`**: Branch de produção. Contém a versão estável e funcional do projeto.
- **`homolog`**: Branch de homologação. Usada para testes do cliente antes do deploy em produção.
- **`develop`**: Branch de desenvolvimento. Integra novas features antes de movê-las para `homolog`.

> **Nota**: Cada uma dessas branches deve estar vinculada a ambientes, pipelines e arquivos `.env` específicos.

### Branches de Vida Curta

Use os seguintes prefixos para branches de curta duração:

- **`feature/`**: Usada para adicionar novas funcionalidades ao projeto.
  - Exemplo: `feature/add-user-authentication`
- **`fix/`**: Usada para corrigir bugs e erros específicos.
  - Exemplo: `fix/correct-login-redirect`
- **`refactor/`**: Usada para reestruturar o código sem alterar o comportamento externo.
  - Exemplo: `refactor/optimize-api-calls`
- **`bump/`**: Usada para atualizar dependências e pacotes.
  - Exemplo: `bump/update-react-version`
- **`release/`**: Usada para preparar novas versões e releases do projeto.
  - Exemplo: `release/v1.2.0`

---

## Commits Convencionais

Devemos seguir o padrão de [Conventional Commits](https://www.conventionalcommits.org/) para manter a consistência e a clareza nos históricos de commits. Abaixo estão os tipos de commits que devem ser usados:

- **`feat`**: Adição de uma nova funcionalidade (feature).
- **`fix`**: Correção de um bug.
- **`refactor`**: Modificação no código que não altera a funcionalidade, como refatorações.
- **`chore`**: Tarefas menores, como atualizações de scripts ou configurações.
- **`style`**: Alterações de estilo e formatação (espaçamento, ponto e vírgula, etc.), sem mudar a lógica do código.
- **`bump`**: Atualizações de dependências e pacotes.
- **`docs`**: Alterações relacionadas à documentação.
- **`build`**: Alterações que afetam o sistema de build ou dependências externas (ex: gulp, npm).
- **`devops`**: Alterações relacionadas a DevOps, infraestrutura e scripts de deployment.
- **`revert`**: Reversão de um commit anterior.

### Exemplo de Commit

```bash
feat: adiciona funcionalidade de autenticação de usuário
fix: corrige bug no redirecionamento de login
```

---

## Versionamento e Releases

O projeto utiliza o [Semantic Versioning 2.0.0](https://semver.org/).

- **Semantic Versioning**: Usar versionamento semântico para gerenciar as releases (`v1.0.0`, `v1.1.0`, etc.).
- **Tags de Release**: Cada versão estável deve ser marcada com uma tag correspondente no Git (`v1.0.0`, `v1.1.0`, etc.).
- **Semantic Release**: Automatizar a criação de releases com base nos commits, para garantir consistência nas versões.

---

## Boas Práticas de Pull Requests

- **Sem commits diretos na branch `main`**: Todos os desenvolvimentos devem passar por uma PR (Pull Request) e ser revisados por outro desenvolvedor antes de serem integrados à branch principal.
- **Revisão obrigatória**: Exceto em casos de extrema urgência, todo PR deve ser revisado.
- **Uso de `rebase`**: Tenha cuidado ao usar o método de rebase (`git rebase`) ao invés de merge (`git merge`) para manter o histórico de commits linear e limpo.
  Apesar do merge deixar "sujo", é ideal que seja feito o merge no lugar do rebase para auxiliar no debug caso ocorram erros.
