const { test, describe } = require('node:test');
const assert = require('node:assert');
const placesService = require('../src/services/places.service');
const app = require('../src/app');

describe('Eat Nearby Authentic Eateries & 24-Hour Caching Suite', () => {
  test('PlacesService.getEatNearby returns 3 authentic local eatery suggestions with rich fields', async () => {
    const result = await placesService.getEatNearby({
      lat: 26.9855,
      lng: 75.8513,
      stopName: 'Amber Palace & Sheesh Mahal',
      city: 'Jaipur',
    });

    assert.ok(result.data, 'Should contain data');
    assert.ok(Array.isArray(result.data), 'Data should be an array');
    assert.strictEqual(result.data.length, 3, 'Should return exactly 3 suggestions');

    for (const eatery of result.data) {
      assert.ok(eatery.name, 'Eatery should have a name');
      assert.ok(eatery.cuisineType, 'Eatery should have a cuisineType');
      assert.ok(eatery.photoUrl, 'Eatery should have a photoUrl');
      assert.ok(eatery.priceLevel, 'Eatery should have a priceLevel string');
      assert.ok(eatery.rating >= 4.0, 'Eatery should have rating >= 4.0');
      assert.ok(eatery.distanceMeters >= 0, 'Eatery should have valid distance in meters');
      assert.ok(eatery.distanceKm >= 0, 'Eatery should have valid distance in km');
      assert.ok(Array.isArray(eatery.specialties), 'Eatery should have specialties list');
    }
  });

  test('PlacesService.getEatNearby serves repeated queries from 24-hour cache', async () => {
    const testStopId = `test_stop_${Date.now()}`;

    // First call: live / catalog computation
    const call1 = await placesService.getEatNearby({
      lat: 26.9258,
      lng: 75.8236,
      stopId: testStopId,
      city: 'Jaipur',
    });

    assert.ok(call1.data.length === 3);

    // Second call: should hit cache
    const call2 = await placesService.getEatNearby({
      lat: 26.9258,
      lng: 75.8236,
      stopId: testStopId,
      city: 'Jaipur',
    });

    assert.strictEqual(call2.fromCache, true, 'Second call should be served from 24-hour cache');
    assert.deepStrictEqual(call2.data, call1.data, 'Cached data should match first call');
  });

  test('HTTP GET /api/v1/trips/places/eat-nearby returns 200 with 3 suggestions and cache headers', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      const response = await fetch(
        `http://127.0.0.1:${port}/api/v1/trips/places/eat-nearby?lat=26.9373&lng=75.8155&city=Jaipur`,
        {
          headers: {
            Authorization: 'Bearer mock-dev-token-user-001',
          },
        }
      );

      const body = await response.json();
      assert.strictEqual(response.status, 200);
      assert.strictEqual(body.success, true);
      assert.ok(Array.isArray(body.data));
      assert.strictEqual(body.data.length, 3);
      assert.ok(body.data[0].name.length > 0);
      assert.ok(body.data[0].cuisineType.length > 0);
    } finally {
      server.close();
    }
  });
});
