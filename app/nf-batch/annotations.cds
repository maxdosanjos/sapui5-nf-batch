using NFBatchService as service from '../../srv/nf-service';

// -----------------------------------------------------------------------------
// Rótulos e textos
// -----------------------------------------------------------------------------
annotate service.Lotes with {
  ID            @title: '{i18n>NumLote}';
  uf            @title: '{i18n>UF}';
  dataEnvio     @title: '{i18n>DataEnvio}';
  totalNotas    @title: '{i18n>TotalNotas}';
  status        @title: '{i18n>StatusLote}'
                @Common: {
                  Text           : status.nome,
                  TextArrangement: #TextOnly
                };
  statusSefaz   @title: '{i18n>StatusSefaz}'
                @Common: {
                  Text           : statusSefaz.descricao,
                  TextArrangement: #TextOnly
                };
};

annotate service.NotasFiscais with {
  ID               @UI.Hidden;
  chaveAcesso      @title: '{i18n>ChaveAcesso}';
  numDocumento     @title: '{i18n>NumDocumento}';
  nfeNum           @title: '{i18n>NFe}';
  cnpjEmissor      @title: '{i18n>CnpjEmissor}';
  cnpjDestinatario @title: '{i18n>CnpjDestinatario}';
  nomeDestinatario @title: '{i18n>NomeDestinatario}';
  lote             @title: '{i18n>NumLote}';
  empresa          @title: '{i18n>Empresa}'
                   @Common: {
                     Text           : empresa.descricao,
                     TextArrangement: #TextOnly
                   };
  status           @title: '{i18n>Status}'
                   @Common: {
                     Text           : status.descricao,
                     TextArrangement: #TextOnly
                   };
};

annotate service.SinteseStatusLote with {
  ID        @UI.Hidden;
  atividade @title: '{i18n>Atividade}';
  descricao @title: '{i18n>Descricao}';
  textoInfo @title: '{i18n>TextoInfo}';
  dataHora  @title: '{i18n>DataHora}';
  tipo      @title: '{i18n>Status}';
};

annotate service.Empresas with {
  ID        @title: '{i18n>Empresa}' @Common: {Text: descricao, TextArrangement: #TextFirst};
  descricao @title: '{i18n>Descricao}';
};

annotate service.StatusLote with {
  ID   @title: '{i18n>StatusLote}' @Common: {Text: nome, TextArrangement: #TextOnly};
  nome @title: '{i18n>Descricao}';
};

annotate service.StatusNotaFiscal with {
  ID        @title: '{i18n>Status}' @Common: {Text: descricao, TextArrangement: #TextOnly};
  descricao @title: '{i18n>Descricao}';
};

annotate service.Sefaz with {
  ID        @title: '{i18n>UF}';
  descricao @title: '{i18n>StatusSefaz}';
};

// -----------------------------------------------------------------------------
// Ajudas de pesquisa (value helps) dos filtros
// -----------------------------------------------------------------------------
annotate service.Lotes with {
  status      @Common.ValueListWithFixedValues: true
              @Common.ValueList               : {
                CollectionPath: 'StatusLote',
                Parameters    : [
                  {$Type: 'Common.ValueListParameterInOut', LocalDataProperty: status_ID, ValueListProperty: 'ID'},
                  {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'nome'}
                ]
              };
  statusSefaz @Common.ValueList: {
                CollectionPath: 'Sefaz',
                Parameters    : [
                  {$Type: 'Common.ValueListParameterInOut', LocalDataProperty: statusSefaz_ID, ValueListProperty: 'ID'},
                  {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descricao'}
                ]
              };
};

annotate service.NotasFiscais with {
  empresa @Common.ValueListWithFixedValues: true
          @Common.ValueList               : {
            CollectionPath: 'Empresas',
            Parameters    : [
              {$Type: 'Common.ValueListParameterInOut', LocalDataProperty: empresa_ID, ValueListProperty: 'ID'},
              {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descricao'}
            ]
          };
  nfeNum  @Common.ValueList: {
            CollectionPath: 'NotasFiscais',
            Parameters    : [
              {$Type: 'Common.ValueListParameterInOut', LocalDataProperty: nfeNum, ValueListProperty: 'nfeNum'},
              {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'numDocumento'},
              {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'cnpjEmissor'}
            ]
          };
  status  @Common.ValueListWithFixedValues: true
          @Common.ValueList               : {
            CollectionPath: 'StatusNotaFiscal',
            Parameters    : [
              {$Type: 'Common.ValueListParameterInOut', LocalDataProperty: status_ID, ValueListProperty: 'ID'},
              {$Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'descricao'}
            ]
          };
};

// -----------------------------------------------------------------------------
// Lotes: List Report + Object Page
// -----------------------------------------------------------------------------
annotate service.Lotes with @(
  UI.HeaderInfo                  : {
    TypeName      : '{i18n>Lote}',
    TypeNamePlural: '{i18n>Lotes}',
    Title         : {Value: ID},
    Description   : {Value: uf},
    TypeImageUrl  : 'sap-icon://group-2'
  },

  // Filtros (equivalentes ao FilterBar do app antigo)
  UI.SelectionFields             : [
    status_ID,
    dataEnvio,
    notasFiscais.empresa_ID,
    notasFiscais.nfeNum
  ],

  UI.LineItem                    : [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'NFBatchService.reenviar',
      Label : '{i18n>Reenviar}'
    },
    {Value: ID},
    {
      Value                    : status_ID,
      Criticality              : status.criticality,
      CriticalityRepresentation: #WithIcon
    },
    {Value: uf},
    {
      Value                    : statusSefaz_ID,
      Label                    : '{i18n>Sefaz}',
      Criticality              : statusSefaz.criticality,
      CriticalityRepresentation: #WithIcon
    },
    {Value: dataEnvio},
    {Value: totalNotas}
  ],

  UI.PresentationVariant         : {
    SortOrder     : [{Property: dataEnvio, Descending: true}],
    Visualizations: ['@UI.LineItem']
  },

  // Cabeçalho do Object Page
  UI.DataPoint #StatusLote       : {
    Value      : status_ID,
    Title      : '{i18n>StatusLote}',
    Criticality: status.criticality
  },
  UI.DataPoint #StatusSefaz      : {
    Value      : statusSefaz_ID,
    Title      : '{i18n>StatusSefaz}',
    Criticality: statusSefaz.criticality
  },
  UI.HeaderFacets                : [
    {$Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#StatusLote'},
    {$Type: 'UI.ReferenceFacet', Target: '@UI.DataPoint#StatusSefaz'}
  ],

  UI.Identification              : [{
    $Type : 'UI.DataFieldForAction',
    Action: 'NFBatchService.reenviar',
    Label : '{i18n>ReenviarLote}'
  }],

  UI.FieldGroup #Detalhes        : {Data: [
    {Value: ID},
    {Value: dataEnvio},
    {Value: uf},
    {Value: totalNotas}
  ]},

  UI.Facets                      : [
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'Detalhes',
      Label : '{i18n>Detalhes}',
      Target: '@UI.FieldGroup#Detalhes'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'NotasFiscais',
      Label : '{i18n>NotasFiscais}',
      Target: 'notasFiscais/@UI.LineItem'
    },
    {
      $Type : 'UI.ReferenceFacet',
      ID    : 'SinteseStatus',
      Label : '{i18n>SinteseStatus}',
      Target: 'sinteseStatus/@UI.LineItem'
    }
  ]
);

// -----------------------------------------------------------------------------
// Notas fiscais (tabela do Object Page)
// -----------------------------------------------------------------------------
annotate service.NotasFiscais with @(
  UI.HeaderInfo: {
    TypeName      : '{i18n>NotaFiscal}',
    TypeNamePlural: '{i18n>NotasFiscais}',
    Title         : {Value: nfeNum},
    Description   : {Value: chaveAcesso}
  },
  UI.LineItem  : [
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'NFBatchService.continuarProcesso',
      Label : '{i18n>ContinuarProcesso}'
    },
    {
      $Type : 'UI.DataFieldForAction',
      Action: 'NFBatchService.verificarStatus',
      Label : '{i18n>VerificarStatus}'
    },
    {Value: chaveAcesso},
    {
      Value                    : status_ID,
      Criticality              : status.criticality,
      CriticalityRepresentation: #WithIcon
    },
    {Value: numDocumento},
    {Value: nfeNum},
    {Value: cnpjDestinatario},
    {Value: nomeDestinatario},
    {Value: cnpjEmissor}
  ]
);

// -----------------------------------------------------------------------------
// Síntese de status (tabela do Object Page)
// -----------------------------------------------------------------------------
annotate service.SinteseStatusLote with @(
  UI.LineItem           : [
    {Value: atividade},
    {
      Value                    : descricao,
      Criticality              : criticality,
      CriticalityRepresentation: #WithIcon
    },
    {Value: textoInfo},
    {Value: dataHora}
  ],
  UI.PresentationVariant: {
    SortOrder     : [{Property: dataHora, Descending: true}],
    Visualizations: ['@UI.LineItem']
  }
);
