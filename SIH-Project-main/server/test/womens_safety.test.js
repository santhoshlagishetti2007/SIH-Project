const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const womensSafetyService = require('../src/services/womens_safety.service');

describe("Women's Safety & Destination Security Guide Suite", () => {
  it('WomensSafetyService.getCitySafetyGuide returns curated safety areas, caution zones, and helplines', async () => {
    const guide = await womensSafetyService.getCitySafetyGuide('Jaipur');
    assert.ok(guide, 'Guide should exist for Jaipur');
    assert.equal(guide.city.toLowerCase(), 'jaipur');
    assert.ok(Array.isArray(guide.safeAreas) && guide.safeAreas.length > 0, 'Safe areas required');
    assert.ok(Array.isArray(guide.cautionAreas) && guide.cautionAreas.length > 0, 'Caution areas required');
    assert.equal(guide.emergencyNumbers.womenHelpline, '1091');
    assert.equal(guide.emergencyNumbers.nationalHelpline, '112');
  });

  it('WomensSafetyService.getNearestEmergencyServices returns nearby police stations & hospitals', async () => {
    const services = await womensSafetyService.getNearestEmergencyServices({
      lat: 26.9124,
      lng: 75.7873,
      city: 'Jaipur',
    });

    assert.ok(Array.isArray(services));
    assert.ok(services.length >= 2);

    const police = services.find((s) => s.type === 'police');
    assert.ok(police, 'Must return at least 1 police station');
    assert.ok(police.name.toLowerCase().includes('police'));
    assert.ok(police.phone);
    assert.ok(police.distanceText);

    const hosp = services.find((s) => s.type === 'hospital');
    assert.ok(hosp, 'Must return at least 1 hospital');
    assert.ok(hosp.phone);
  });

  it('WomensSafetyService.getWomenVerifiedStaysAndGuides returns verified female hosts & guides', async () => {
    const listings = await womensSafetyService.getWomenVerifiedStaysAndGuides({ city: 'Jaipur' });
    assert.ok(Array.isArray(listings));
    assert.ok(listings.length > 0);

    const stay = listings.find((l) => l.type === 'stay');
    assert.ok(stay);
    assert.equal(stay.isWomenVerified, true);
    assert.ok(Array.isArray(stay.safetyBadges) && stay.safetyBadges.length > 0);

    const guide = listings.find((l) => l.type === 'guide');
    assert.ok(guide);
    assert.equal(guide.isWomenVerified, true);
  });

  it('HTTP REST Women Safety routes respond with 200 via Express', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. GET /api/v1/safety/women/guide/Jaipur
      const guideRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/women/guide/Jaipur`);
      assert.equal(guideRes.status, 200);
      const guideJson = await guideRes.json();
      assert.equal(guideJson.success, true);
      assert.equal(guideJson.data.city, 'Jaipur');

      // 2. GET /api/v1/safety/women/emergency-nearby
      const emergRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/women/emergency-nearby?city=Jaipur`);
      assert.equal(emergRes.status, 200);
      const emergJson = await emergRes.json();
      assert.equal(emergJson.success, true);
      assert.ok(emergJson.data.length > 0);

      // 3. GET /api/v1/safety/women/verified-stays-guides
      const verRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/women/verified-stays-guides?city=Jaipur`);
      assert.equal(verRes.status, 200);
      const verJson = await verRes.json();
      assert.equal(verJson.success, true);
      assert.ok(verJson.data.length > 0);
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
