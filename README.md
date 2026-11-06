# SendNFBatch — Reenvio de Lotes NF-e (SAP CAP + SAP Fiori elements)

Monitoramento e reenvio de lotes de NF-e. Projeto convertido do antigo app
freestyle SAPUI5 1.56 (SAP Build / OData V2 com mock server) para:

| Camada   | Antes                                   | Agora                                                         |
|----------|-----------------------------------------|---------------------------------------------------------------|
| Backend  | Nenhum (mock server com JSON)           | **SAP CAP** (Node.js, `@sap/cds` 10) com SQLite em dev        |
| Protocolo| OData V2                                | **OData V4**                                                  |
| UI       | SAPUI5 1.56, views XML + controllers    | **SAP Fiori elements V4** (List Report + Object Page), SAPUI5 **1.136 LTS** |
| Tema     | `sap_belize`                            | `sap_horizon`                                                 |
| Hospedagem | SAP Cloud Platform Neo (`neo-app.json`) | Pronto para SAP BTP Cloud Foundry / Kyma (via `cds add`)    |

## Estrutura

```
db/
  schema.cds          Modelo de dados (Lotes, NotasFiscais, SinteseStatusLote, Empresas, Status..., Sefaz)
  data/*.csv          Dados de exemplo (migrados do antigo localService/*.json)
srv/
  nf-service.cds      Serviço OData V4 /odata/v4/nf-batch + ações
  nf-service.js       Lógica das ações (reenviar, continuarProcesso, verificarStatus)
_i18n/                Textos dos rótulos e mensagens (pt / en)
app/
  services.cds
  nf-batch/
    annotations.cds   Anotações UI (filtros, colunas, facetas, value helps)
    webapp/           App Fiori elements (manifest.json, Component.js, i18n)
    ui5.yaml          Dev com SAP Fiori tools (UI5 via CDN)
    ui5-local.yaml    Dev com UI5 baixado do npm (sem CDN)
test/
  nf-service.test.js  Testes do serviço (node:test + cds.test)
```

### Mapeamento do app antigo

| App antigo                                         | Agora                                                              |
|----------------------------------------------------|--------------------------------------------------------------------|
| `ListaLote.view.xml` (DynamicPage + FilterBar)     | List Report (`UI.SelectionFields`, `UI.LineItem`)                  |
| Filtros Status / Data Envio / Empresa / Nº NF-e    | `status_ID`, `dataEnvio`, `notasFiscais.empresa_ID`, `notasFiscais.nfeNum` |
| Botão "Reenviar" (era `#TODO`)                     | Ação vinculada `reenviar` (multi-seleção)                         |
| `PopoverSefaz` / coluna SEFAZ                      | Coluna "SEFAZ" com criticality + value help de `Sefaz`             |
| `ValueHelpNf.fragment.xml`                         | `Common.ValueList` em `nfeNum`                                     |
| `DetailLote.view.xml` (ObjectPageLayout)           | Object Page (`UI.HeaderInfo`, `UI.HeaderFacets`, `UI.Facets`)      |
| "Continuar processo" / "Solicitar verificação status" (eram `alert`) | Ações `continuarProcesso` / `verificarStatus` em `NotasFiscais` |
| `SisteseStatusLote`                                | `SinteseStatusLote` (nome corrigido), composição de `Lotes`        |
| Campos `___FK_...`                                 | Associações CDS (`status`, `statusSefaz`, `lote`, `empresa`)       |
| Status sempre "Error" fixo na view                 | `criticality` calculada a partir de `tipo` (E/W/S)                 |

## Executar localmente

Pré-requisito: Node.js 20+.

```bash
npm install
npm run watch            # cds watch -> http://localhost:4004
```

- App: http://localhost:4004/nf-batch/webapp/index.html
- Serviço: http://localhost:4004/odata/v4/nf-batch
- Usuário mock: `alice` (senha em branco) — o serviço exige usuário autenticado.

O `index.html` carrega o SAPUI5 1.136 do CDN `ui5.sap.com`. Sem acesso ao CDN,
use o UI5 do npm (com o CAP rodando em outro terminal):

```bash
cd app/nf-batch
npm install
npm run start-local      # http://localhost:8080/index-local.html
```

## Testes

```bash
npm test
```

## Integração com o backend real

As ações em `srv/nf-service.js` hoje atualizam apenas o banco local e gravam a
síntese de status. Os pontos para integrar com o S/4HANA / GRC NF-e / SEFAZ
estão marcados com `TODO integração`. O caminho usual no CAP é importar o
serviço remoto (`cds import <edmx>`), declará-lo em `cds.requires` e chamá-lo
com `cds.connect.to(...)`.

## Deploy no SAP BTP (Cloud Foundry)

```bash
npx cds add hana,xsuaa,approuter,mta,html5-repo
npm install
mbt build && cf deploy mta_archives/*.mtar
```
