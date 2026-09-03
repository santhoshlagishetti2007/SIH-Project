const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const destinationCustomsService = require('../src/services/destination_customs.service');

describe('Know Before You Go: Destination Customs & Etiquette Suite', () => {
  it('DestinationCustomsService.getDestinationCustoms returns dress code, temple etiquette, tipping, and scams', async () => {
    const jaipurCustoms = await destinationCustomsService.getDestinationCustoms('Jaipur');
    assert.ok(jaipurCustoms);
    assert.equal(jaipurCustoms.destination.toLowerCase(), 'jaipur');
    assert.ok(jaipurCustoms.dressCode.religiousSites);
    assert.ok(Array.isArray(jaipurCustoms.templeEtiquette) && jaipurCustoms.templeEtiquette.length > 0);
    assert.ok(jaipurCustoms.tippingNorms.restaurants);
    assert.ok(Array.isArray(jaipurCustoms.commonScams) && jaipurCustoms.commonScams.length > 0);
    assert.ok(jaipurCustoms.commonScams[0].warning);
    assert.ok(jaipurCustoms.commonScams[0].preventionTip);
    assert.ok(Array.isArray(jaipurCustoms.dos) && jaipurCustoms.dos.length > 0);
    assert.ok(Array.isArray(jaipurCustoms.donts) && jaipurCustoms.donts.length > 0);
  });

  it('DestinationCustomsService.updateDestinationCustoms updates guidelines', async () => {
    const updated = await destinationCustomsService.updateDestinationCustoms('Jaipur', {
      region: 'Rajasthan Heritage Zone',
    });
    assert.ok(updated);
    assert.equal(updated.region, 'Rajasthan Heritage Zone');
  });

  it('HTTP REST Destination Customs routes respond with 200 via Express', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. GET /api/v1/destinations/customs/Jaipur
      const res = await fetch(`http://127.0.0.1:${port}/api/v1/destinations/customs/Jaipur`);
      assert.equal(res.status, 200);
      const json = await res.json();
      assert.equal(json.success, true);
      assert.equal(json.data.destination, 'Jaipur');
      assert.ok(json.data.commonScams.length > 0);

      // 2. GET /api/v1/destinations/customs
      const listRes = await fetch(`http://127.0.0.1:${port}/api/v1/destinations/customs`);
      assert.equal(listRes.status, 200);
      const listJson = await listRes.json();
      assert.equal(listJson.success, true);
      assert.ok(listJson.data.length > 0);
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
