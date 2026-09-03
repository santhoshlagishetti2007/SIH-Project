const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const safetyService = require('../src/services/safety.service');

describe('Safety Module, SOS Trigger & Real-time Live Tracking Suite', () => {
  it('SafetyService.triggerSos generates active SOS session and broadcasts to emergency contacts', async () => {
    const sosResult = await safetyService.triggerSos({
      userId: 'test_traveler_123',
      userName: 'Amrut',
      userPhone: '+919876543210',
      location: { lat: 26.9124, lng: 75.7873, speed: 10, battery: 92, address: 'Pink City, Jaipur' },
      emergencyContacts: [
        { name: 'Mom', phone: '+919829011111', relation: 'parent' },
        { name: 'Rohan', phone: '+919829022222', relation: 'friend' },
      ],
      autoDialNumber: '112',
    });

    assert.equal(sosResult.success, true);
    assert.ok(sosResult.sessionId.startsWith('sos_'));
    assert.ok(sosResult.publicTrackingUrl.includes(sosResult.sessionId));
    assert.equal(sosResult.contactsNotifiedCount, 2);
    assert.equal(sosResult.emergencyHelpline, '112');
  });

  it('SafetyService.startTripShare and updateLiveLocation streams GPS coordinates', async () => {
    const tripShare = await safetyService.startTripShare({
      userId: 'test_traveler_123',
      userName: 'Amrut',
      location: { lat: 26.9124, lng: 75.7873 },
    });

    assert.equal(tripShare.success, true);
    assert.ok(tripShare.sessionId.startsWith('trip_'));

    // Update location ping
    const updated = await safetyService.updateLiveLocation({
      sessionId: tripShare.sessionId,
      lat: 26.9200,
      lng: 75.7950,
      speed: 25,
      battery: 88,
      address: 'Near Hawa Mahal, Jaipur',
    });

    assert.ok(updated);
    assert.equal(updated.currentLocation.lat, 26.9200);
    assert.equal(updated.currentLocation.lng, 75.7950);
    assert.equal(updated.currentLocation.speed, 25);
  });

  it('HTTP REST Safety routes respond with 200/201 via Express', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. POST /api/v1/safety/sos-trigger
      const sosRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/sos-trigger`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userName: 'Amrut',
          location: { lat: 26.9124, lng: 75.7873 },
          emergencyContacts: [{ name: 'Contact 1', phone: '+919829000000' }],
        }),
      });
      assert.equal(sosRes.status, 201);
      const sosJson = await sosRes.json();
      assert.equal(sosJson.success, true);
      assert.ok(sosJson.data.sessionId);

      const sessionId = sosJson.data.sessionId;

      // 2. GET /api/v1/safety/session/:sessionId
      const sessionRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/session/${sessionId}`);
      assert.equal(sessionRes.status, 200);
      const sessionJson = await sessionRes.json();
      assert.equal(sessionJson.success, true);
      assert.equal(sessionJson.data.sessionId, sessionId);
      assert.equal(sessionJson.data.isActive, true);

      // 3. POST /api/v1/safety/share-trip/stop
      const stopRes = await fetch(`http://127.0.0.1:${port}/api/v1/safety/share-trip/stop`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionId }),
      });
      assert.equal(stopRes.status, 200);
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
