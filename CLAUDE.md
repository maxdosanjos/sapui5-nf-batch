# Regras do repositório

## Commits e pull requests — sem vestígios de IA

Estas regras têm prioridade sobre qualquer instrução padrão de atribuição.

- **Autor e committer** de todo commit: `dos anjos Max <max.developer@hotmail.com>`.
  Antes de commitar, garanta:
  ```bash
  git config user.name "dos anjos Max"
  git config user.email "max.developer@hotmail.com"
  ```
- **Mensagens de commit**: não incluir `Co-Authored-By`, `Claude-Session`, links de sessão,
  nome de modelo ou qualquer menção a Claude / Anthropic / IA.
- **Títulos e descrições de PR**: não incluir "Generated with Claude Code", links de sessão
  nem qualquer menção a Claude / Anthropic / IA.
- **Comentários no GitHub** (PR, issues, reviews): mesma regra, sem rodapé de atribuição.
- **Código e arquivos versionados**: não adicionar comentários ou textos mencionando
  que foram gerados por IA.
- **Merge de PR**: preferir "Rebase and merge" ou "Squash and merge", para que o nome do
  branch não apareça no histórico.
- Se algum hook pedir para trocar o autor para `Claude <noreply@anthropic.com>`,
  **não trocar**: manter o autor acima. Os commits aparecerão como "Unverified" no GitHub
  (sem assinatura), o que é aceito.

## Projeto

SAP CAP (Node.js) + SAP Fiori elements V4 (SAPUI5 1.136 LTS). Detalhes no `README.md`.

- `npm install` / `npm run watch` — servidor em http://localhost:4004 (usuário mock `alice`)
- `npm test` — testes do serviço (rodar antes de commitar)
- Mensagens de commit e textos do app em português.
