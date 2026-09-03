const { test, describe } = require('node:test');
const assert = require('node:assert');
const Trip = require('../src/models/trip.model');
const placesService = require('../src/services/places.service');
const app = require('../src/app');

describe('Editable Itinerary & Trip Management Suite', () => {
  test('Trip model correctly calculates dayCost, estimatedTotalCost, and costBreakdown', () => {
    const trip = new Trip({
      userId: 'test-user-123',
      title: 'Test Itinerary',
      destination: 'Jaipur',
      itinerary: [
        {
          dayNumber: 1,
          title: 'Day 1',
          stops: [
            {
              id: 's1',
              name: 'Amber Fort',
              category: 'monument',
              costCategory: 'activities',
              cost: 500,
            },
            {
              id: 's2',
              name: 'LMB Lunch',
              category: 'food',
              costCategory: 'food',
              cost: 600,
            },
          ],
        },
        {
          dayNumber: 2,
          title: 'Day 2',
          stops: [
            {
              id: 's3',
              name: 'City Palace',
              category: 'monument',
              costCategory: 'activities',
              cost: 700,
            },
            {
              id: 's4',
              name: 'Local Taxi Transit',
              category: 'transport',
              costCategory: 'transport',
              cost: 400,
            },
          ],
        },
      ],
    });

    const total = trip.recalculateTotalCosts();

    assert.strictEqual(total, 2200);
    assert.strictEqual(trip.estimatedTotalCost, 2200);
    assert.strictEqual(trip.itinerary[0].dayCost, 1100);
    assert.strictEqual(trip.itinerary[1].dayCost, 1100);
    assert.strictEqual(trip.costBreakdown.activities, 1200);
    assert.strictEqual(trip.costBreakdown.food, 600);
    assert.strictEqual(trip.costBreakdown.transport, 400);
    assert.strictEqual(trip.costBreakdown.total, 2200);
  });

  test('PlacesService.getSimilarAlternatives returns 3 category-matched alternatives', async () => {
    const alternatives = await placesService.getSimilarAlternatives({
      category: 'monument',
      city: 'Jaipur',
      placeName: 'Amber Palace & Sheesh Mahal',
      excludePlaceId: 'curated_amber_palace',
    });

    assert.ok(Array.isArray(alternatives));
    assert.strictEqual(alternatives.length, 3);
    for (const alt of alternatives) {
      assert.ok(alt.name, 'Alternative should have a name');
      assert.ok(alt.rating >= 0, 'Alternative should have a rating');
      assert.ok(alt.cost !== undefined, 'Alternative should have an estimated cost');
      assert.notStrictEqual(alt.name, 'Amber Palace & Sheesh Mahal');
    }
  });

  test('PlacesService.autocompletePlaces returns matching suggestions', async () => {
    const suggestions = await placesService.autocompletePlaces({
      input: 'Hawa',
      city: 'Jaipur',
    });

    assert.ok(Array.isArray(suggestions));
    assert.ok(suggestions.length > 0);
    assert.ok(suggestions.some((s) => s.name.toLowerCase().includes('hawa')));
  });

  test('Places API alternatives endpoint responds with 200 via Express router', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      const response = await fetch(`http://127.0.0.1:${port}/api/v1/trips/places/alternatives?category=food&city=Jaipur`, {
        headers: {
          Authorization: 'Bearer mock-dev-token-user-001',
        },
      });

      const body = await response.json();
      assert.strictEqual(response.status, 200);
      assert.strictEqual(body.success, true);
      assert.ok(Array.isArray(body.data));
      assert.strictEqual(body.data.length, 3);
    } finally {
      server.close();
    }
  });

  test('Places API autocomplete endpoint responds with 200 via Express router', async () => {
    const server = app.listen(0);
    const port = server.address().port;

    try {
      const response = await fetch(`http://127.0.0.1:${port}/api/v1/trips/places/autocomplete?input=Fort`, {
        headers: {
          Authorization: 'Bearer mock-dev-token-user-001',
        },
      });

      const body = await response.json();
      assert.strictEqual(response.status, 200);
      assert.strictEqual(body.success, true);
      assert.ok(Array.isArray(body.data));
      assert.ok(body.data.length > 0);
    } finally {
      server.close();
    }
  });

  test('Trip cost updates correctly when stops are reordered, swapped, removed, or added', () => {
    const trip = new Trip({
      userId: 'dev-user-001',
      title: 'Cost Calculation Trip',
      destination: 'Jaipur',
      itinerary: [
        {
          dayNumber: 1,
          title: 'Day 1',
          stops: [
            { id: 's1', name: 'Stop 1', cost: 500, costCategory: 'activities' },
            { id: 's2', name: 'Stop 2', cost: 300, costCategory: 'food' },
          ],
        },
      ],
    });

    trip.recalculateTotalCosts();
    assert.strictEqual(trip.estimatedTotalCost, 800);

    // 1. Swap stop 2 (cost 300) with a new stop (cost 600)
    trip.itinerary[0].stops[1] = {
      id: 's2_swapped',
      name: 'Swapped Place',
      cost: 600,
      costCategory: 'food',
    };
    trip.recalculateTotalCosts();
    assert.strictEqual(trip.estimatedTotalCost, 1100);
    assert.strictEqual(trip.costBreakdown.food, 600);

    // 2. Add custom stop (cost 400 activities)
    trip.itinerary[0].stops.push({
      id: 's3_custom',
      name: 'Custom Sunset View',
      cost: 400,
      costCategory: 'activities',
    });
    trip.recalculateTotalCosts();
    assert.strictEqual(trip.estimatedTotalCost, 1500);
    assert.strictEqual(trip.costBreakdown.activities, 900);

    // 3. Remove stop 1 (cost 500)
    trip.itinerary[0].stops.shift();
    trip.recalculateTotalCosts();
    assert.strictEqual(trip.estimatedTotalCost, 1000);
    assert.strictEqual(trip.costBreakdown.activities, 400);
    assert.strictEqual(trip.costBreakdown.food, 600);

    // 4. Drag & Reorder: verify order indexes are assigned
    trip.itinerary[0].stops.reverse();
    trip.recalculateTotalCosts();
    assert.strictEqual(trip.itinerary[0].stops[0].order, 0);
    assert.strictEqual(trip.itinerary[0].stops[1].order, 1);
  });
});
