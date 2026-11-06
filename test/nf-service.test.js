const cds = require('@sap/cds');
const { test, describe } = require('node:test');
const assert = require('node:assert/strict');

const { GET, POST, axios } = cds.test(__dirname + '/..');
axios.defaults.auth = { username: 'alice', password: '' };
axios.defaults.validateStatus = () => true;

const BASE = '/odata/v4/nf-batch';

describe('NFBatchService', () => {
  test('exige usuário autenticado', async () => {
    const res = await GET(`${BASE}/Lotes`, { auth: null });
    assert.equal(res.status, 401);
  });

  test('lista os lotes com status e criticality', async () => {
    const { data } = await GET(`${BASE}/Lotes?$expand=status&$orderby=ID`);
    assert.equal(data.value.length, 4);
    assert.equal(data.value[0].status.nome, 'Erro');
    assert.equal(data.value[0].status.criticality, 1);
  });

  test('filtra lotes por NF-e e empresa (navegação 1:n)', async () => {
    const filter = "notasFiscais/any(n:n/nfeNum eq '1236-1') and notasFiscais/any(n:n/empresa_ID eq '1000')";
    const { data } = await GET(`${BASE}/Lotes?$select=ID&$filter=${encodeURIComponent(filter)}`);
    assert.deepEqual(data.value.map((l) => l.ID), ['346625']);
  });

  test('reenviar lote muda o status e registra a síntese', async () => {
    const res = await POST(`${BASE}/Lotes('346625')/NFBatchService.reenviar`, {});
    assert.equal(res.status, 200);
    assert.equal(res.data.status_ID, '03');
    assert.match(res.headers['sap-messages'], /LOTE_REENVIADO/);

    const { data } = await GET(`${BASE}/Lotes('346625')/sinteseStatus?$filter=descricao eq 'Reenvio solicitado'`);
    assert.equal(data.value.length, 1);
  });

  test('não reenvia lote já em processamento', async () => {
    const res = await POST(`${BASE}/Lotes('346627')/NFBatchService.reenviar`, {});
    assert.equal(res.status, 409);
  });

  test('continuar processo e verificar status da NF-e', async () => {
    const id = '35180100198057000902550090000000141465720706';
    let res = await POST(`${BASE}/NotasFiscais('${id}')/NFBatchService.continuarProcesso`, {});
    assert.equal(res.status, 200);
    assert.equal(res.data.status_ID, '03');

    res = await POST(`${BASE}/NotasFiscais('${id}')/NFBatchService.verificarStatus`, {});
    assert.equal(res.status, 200);
    assert.match(res.headers['sap-messages'], /Processando/);
  });

  test('serviço é somente leitura', async () => {
    const res = await POST(`${BASE}/Lotes`, { ID: '999' });
    assert.equal(res.status, 405);
  });
});
