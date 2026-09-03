const { test, describe } = require('node:test');
const assert = require('node:assert');
const Trip = require('../src/models/trip.model');
const { TransportRateConfig, DEFAULT_CITY_RATES } = require('../src/models/transport_rate.model');
const routesService = require('../src/services/routes.service');
const app = require('../src/app');

describe('Itinerary Transport Cost Layer & Configurable Rate Tables Suite', () => {
  test('RoutesService accurately calculates urban distance and travel times between stops', async () => {
    const origin = { lat: 26.9855, lng: 75.8513, name: 'Amber Palace' };
    const destination = { lat: 26.9845, lng: 75.8456, name: 'Jaigarh Fort' };

    const matrix = await routesService.calculateDistanceMatrix({ origin, destination });

    assert.ok(matrix.distanceKm > 0, 'Distance should be greater than 0');
    assert.ok(matrix.durationMinutes > 0, 'Duration should be positive');
  });

  test('RoutesService computes multi-modal transport options with city rate tables', async () => {
    const fromStop = { id: 's1', name: 'Amber Fort', location: { lat: 26.9855, lng: 75.8513 } };
    const toStop = { id: 's2', name: 'City Palace', location: { lat: 26.9258, lng: 75.8236 } };

    const leg = await routesService.computeLegTransitOptions({
      fromStop,
      toStop,
      city: 'Jaipur',
    });

    assert.strictEqual(leg.fromStopId, 's1');
    assert.strictEqual(leg.toStopId, 's2');
    assert.ok(leg.distanceKm > 5, 'Amber Fort to City Palace distance should be ~7-10 km');
    assert.ok(Array.isArray(leg.modes));
    assert.ok(leg.modes.length >= 3);

    // Verify auto, bus, walk, and cab modes
    const autoMode = leg.modes.find((m) => m.mode === 'auto');
    const busMode = leg.modes.find((m) => m.mode === 'bus');
    const walkMode = leg.modes.find((m) => m.mode === 'walk');

    assert.ok(autoMode, 'Auto mode must be present');
    assert.ok(busMode, 'Bus mode must be present');
    assert.ok(walkMode, 'Walk mode must be present');
    assert.strictEqual(walkMode.cost, 0);
    assert.ok(autoMode.cost > busMode.cost, 'Auto fare should be higher than bus fare');
    assert.ok(leg.estimatedCost > 0);
  });

  test('Trip model recalculates day transport cost and total transport breakdown', () => {
    const trip = new Trip({
      userId: 'dev-user-001',
      title: 'Transport Test Trip',
      destination: 'Jaipur',
      itinerary: [
        {
          dayNumber: 1,
          title: 'Day 1',
          stops: [
            { id: 's1', name: 'Stop A', cost: 200, costCategory: 'activities' },
            { id: 's2', name: 'Stop B', cost: 400, costCategory: 'food' },
          ],
          transitLegs: [
            {
              fromStopId: 's1',
              toStopId: 's2',
              fromStopName: 'Stop A',
              toStopName: 'Stop B',
              distanceKm: 4.5,
              durationMinutes: 18,
              selectedMode: 'auto',
              estimatedCost: 75,
            },
          ],
        },
      ],
    });

    trip.recalculateTotalCosts();

    assert.strictEqual(trip.itinerary[0].dayTransportCost, 75);
    assert.strictEqual(trip.itinerary[0].dayCost, 675); // 200 + 400 + 75
    assert.strictEqual(trip.costBreakdown.activities, 200);
    assert.strictEqual(trip.costBreakdown.food, 400);
    assert.strictEqual(trip.costBreakdown.transport, 75);
    assert.strictEqual(trip.costBreakdown.total, 675);
    assert.strictEqual(trip.estimatedTotalCost, 675);
  });

  test('POST /api/v1/trips/transport/calculate-legs returns transit legs between stops', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      const response = await fetch(`http://127.0.0.1:${port}/api/v1/trips/transport/calculate-legs`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer mock-dev-token-user-001',
        },
        body: JSON.stringify({
          city: 'Jaipur',
          stops: [
            { id: 's1', name: 'Amber Fort', location: { lat: 26.9855, lng: 75.8513 } },
            { id: 's2', name: 'Jaigarh Fort', location: { lat: 26.9845, lng: 75.8456 } },
            { id: 's3', name: 'City Palace', location: { lat: 26.9258, lng: 75.8236 } },
          ],
        }),
      });

      const body = await response.json();
      assert.strictEqual(response.status, 200);
      assert.strictEqual(body.success, true);
      assert.ok(Array.isArray(body.data));
      assert.strictEqual(body.data.length, 2, '3 stops should produce 2 transit legs');
      assert.strictEqual(body.data[0].fromStopId, 's1');
      assert.strictEqual(body.data[0].toStopId, 's2');
      assert.strictEqual(body.data[1].fromStopId, 's2');
      assert.strictEqual(body.data[1].toStopId, 's3');
    } finally {
      server.close();
    }
  });

  test('GET & PUT /api/v1/admin/transport-rates allows viewing and updating city rate tables', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      // 1. GET all city rates
      const getRes = await fetch(`http://127.0.0.1:${port}/api/v1/admin/transport-rates`, {
        headers: {
          Authorization: 'Bearer mock-dev-token-admin',
        },
      });

      const getBody = await getRes.json();
      assert.strictEqual(getRes.status, 200);
      assert.strictEqual(getBody.success, true);
      assert.ok(Array.isArray(getBody.data));

      // 2. PUT custom rate for Udaipur
      const putRes = await fetch(`http://127.0.0.1:${port}/api/v1/admin/transport-rates/Udaipur`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer mock-dev-token-admin',
        },
        body: JSON.stringify({
          currency: 'INR',
          modes: {
            walking: { baseFare: 0, perKmRate: 0, speedKmh: 4.5, isAvailable: true },
            auto: { baseFare: 35, perKmRate: 16.0, minFare: 35, speedKmh: 20, isAvailable: true },
            bus: { baseFare: 12, perKmRate: 3.5, minFare: 12, speedKmh: 16, isAvailable: true },
            metro: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 0, isAvailable: false },
            cab: { baseFare: 70, perKmRate: 22.0, minFare: 70, speedKmh: 25, isAvailable: true },
          },
        }),
      });

      const putBody = await putRes.json();
      assert.strictEqual(putRes.status, 200);
      assert.strictEqual(putBody.success, true);
      assert.strictEqual(putBody.data.city, 'Udaipur');
      assert.strictEqual(putBody.data.modes.auto.perKmRate, 16);
    } finally {
      server.close();
    }
  });
});
