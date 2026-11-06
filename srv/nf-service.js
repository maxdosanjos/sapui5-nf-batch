const cds = require('@sap/cds');

const STATUS_LOTE_PROCESSANDO = '03';
const STATUS_NF_PROCESSANDO = '03';

/**
 * Implementação do NFBatchService.
 *
 * As ações abaixo apenas atualizam o banco local e registram o histórico.
 * A integração real (ex.: chamada ao backend S/4HANA / GRC NF-e ou ao
 * web service da SEFAZ) deve ser feita nos pontos marcados com "TODO integração",
 * normalmente via um serviço remoto declarado em package.json > cds.requires.
 */
module.exports = class NFBatchService extends cds.ApplicationService {
  init() {
    const { Lotes, NotasFiscais } = this.entities;
    const db = cds.entities('nfbatch');

    this.on('reenviar', Lotes, async (req) => {
      const { ID } = req.params[0];
      const lote = await SELECT.one.from(db.Lotes, ID).columns('ID', 'status_ID', 'statusSefaz_ID');
      if (!lote) return req.reject(404, 'LOTE_NAO_ENCONTRADO', [ID]);
      if (lote.status_ID === STATUS_LOTE_PROCESSANDO) {
        return req.reject(409, 'LOTE_EM_PROCESSAMENTO', [ID]);
      }

      const sefaz = lote.statusSefaz_ID && (await SELECT.one.from(db.Sefaz, lote.statusSefaz_ID));
      if (sefaz?.tipo === 'E') {
        req.warn('SEFAZ_COM_ERRO', [sefaz.ID, sefaz.descricao]);
      }

      // TODO integração: disparar o reenvio do lote no backend.
      const agora = new Date().toISOString();
      await UPDATE(db.Lotes, ID).with({ status_ID: STATUS_LOTE_PROCESSANDO, dataEnvio: agora });
      await INSERT.into(db.SinteseStatusLote).entries({
        lote_ID: ID,
        atividade: 'Reenviar lote NF-e',
        descricao: 'Reenvio solicitado',
        textoInfo: 'Lote reenviado pelo usuário ' + req.user.id,
        tipo: 'W',
        dataHora: agora
      });

      req.info('LOTE_REENVIADO', [ID]);
      return SELECT.one.from(Lotes, ID);
    });

    this.on('continuarProcesso', NotasFiscais, async (req) => {
      const { ID } = req.params[0];
      const nf = await SELECT.one.from(db.NotasFiscais, ID).columns('ID', 'nfeNum');
      if (!nf) return req.reject(404, 'NF_NAO_ENCONTRADA', [ID]);

      // TODO integração: continuar o processamento da NF-e no backend.
      await UPDATE(db.NotasFiscais, ID).with({ status_ID: STATUS_NF_PROCESSANDO });

      req.info('NF_PROCESSO_CONTINUADO', [nf.nfeNum]);
      return SELECT.one.from(NotasFiscais, ID);
    });

    this.on('verificarStatus', NotasFiscais, async (req) => {
      const { ID } = req.params[0];
      const nf = await SELECT.one.from(db.NotasFiscais, ID).columns('ID', 'nfeNum', 'status_ID');
      if (!nf) return req.reject(404, 'NF_NAO_ENCONTRADA', [ID]);

      // TODO integração: consultar o status da NF-e na SEFAZ e atualizar status_ID.
      const status = await SELECT.one.from(db.StatusNotaFiscal, nf.status_ID);

      req.info('NF_STATUS_VERIFICADO', [nf.nfeNum, status?.descricao ?? '-']);
      return SELECT.one.from(NotasFiscais, ID);
    });

    return super.init();
  }
};
