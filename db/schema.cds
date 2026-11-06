namespace nfbatch;

using {
  cuid,
  managed
} from '@sap/cds/common';

/**
 * Tipo de mensagem/status usado em todo o modelo:
 *   E = Erro, W = Aviso/Processando, S = Sucesso
 */
type TipoStatus : String(1) enum {
  Erro    = 'E';
  Aviso   = 'W';
  Sucesso = 'S';
};

/**
 * Aspecto reutilizável que converte o tipo (E/W/S) em criticality
 * do Fiori (1 = vermelho, 2 = amarelo, 3 = verde, 0 = neutro).
 */
aspect ComCriticality {
  tipo        : TipoStatus;
  criticality : Integer = (
    case tipo
      when 'E' then 1
      when 'W' then 2
      when 'S' then 3
      else 0
    end
  );
}

/** Lote de NF-e enviado à SEFAZ */
entity Lotes : managed {
  key ID            : String(15);
      uf            : String(2);
      dataEnvio     : Timestamp;
      totalNotas    : Integer;
      status        : Association to StatusLote;
      statusSefaz   : Association to Sefaz;
      notasFiscais  : Association to many NotasFiscais
                        on notasFiscais.lote = $self;
      sinteseStatus : Composition of many SinteseStatusLote
                        on sinteseStatus.lote = $self;
}

/** Nota fiscal eletrônica pertencente a um lote */
entity NotasFiscais : managed {
  key ID               : String(44);
      chaveAcesso      : String(44);
      numDocumento     : String(20);
      nfeNum           : String(20);
      cnpjEmissor      : String(18);
      cnpjDestinatario : String(18);
      nomeDestinatario : String(100);
      lote             : Association to Lotes;
      empresa          : Association to Empresas;
      status           : Association to StatusNotaFiscal;
}

/** Histórico (síntese) de status do processamento de um lote */
entity SinteseStatusLote : cuid, ComCriticality {
  lote      : Association to Lotes;
  atividade : String(60);
  descricao : String(100);
  textoInfo : String(255);
  dataHora  : Timestamp;
}

entity Empresas {
  key ID        : String(4);
      descricao : String(60);
}

entity StatusLote : ComCriticality {
  key ID   : String(2);
      nome : String(40);
}

entity StatusNotaFiscal : ComCriticality {
  key ID        : String(2);
      descricao : String(40);
}

/** Status do serviço da SEFAZ por UF */
entity Sefaz : ComCriticality {
  key ID        : String(2);
      descricao : String(60);
}
