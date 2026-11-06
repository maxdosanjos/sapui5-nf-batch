using {nfbatch as db} from '../db/schema';

/**
 * Serviço OData V4 para monitoramento e reenvio de lotes de NF-e.
 * Exposto em /odata/v4/nf-batch
 */
@path    : '/odata/v4/nf-batch'
@requires: 'authenticated-user'
service NFBatchService {

  @readonly
  entity Lotes             as projection on db.Lotes
    actions {
      /** Reenvia o lote para a SEFAZ */
      @(
        Common.SideEffects             : {TargetProperties: [
          'status_ID',
          'dataEnvio'
        ],
        TargetEntities                 : [
          in.status,
          in.sinteseStatus
        ]},
        Core.OperationAvailable        : {$edmJson: {$Ne: [
          {$Path: 'in/status_ID'},
          '03'
        ]}}
      )
      action reenviar() returns Lotes;
    };

  @readonly
  entity NotasFiscais      as projection on db.NotasFiscais
    actions {
      /** Continua o processamento da NF-e */
      @(Common.SideEffects: {TargetEntities: [in.status]})
      action continuarProcesso()  returns NotasFiscais;

      /** Solicita à SEFAZ a verificação do status da NF-e */
      @(Common.SideEffects: {TargetEntities: [in.status]})
      action verificarStatus()    returns NotasFiscais;
    };

  @readonly
  entity SinteseStatusLote as projection on db.SinteseStatusLote;

  @readonly
  entity Empresas          as projection on db.Empresas;

  @readonly
  entity StatusLote        as projection on db.StatusLote;

  @readonly
  entity StatusNotaFiscal  as projection on db.StatusNotaFiscal;

  @readonly
  entity Sefaz             as projection on db.Sefaz;
}
