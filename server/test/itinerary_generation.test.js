const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const routesService = require('../src/services/routes.service');
const Trip = require('../src/models/trip.model');

describe('Itinerary Generation & Cost Estimation Logic Suite', () => {
  it('Computes correct distance, duration, and transit fare breakdown between consecutive stops', async () => {
    const fromStop = {
      id: 'stop_1',
      name: 'Hawa Mahal',
      location: { lat: 26.9239, lng: 75.8267, address: 'Hawa Mahal Rd, Badi Choupad, Jaipur' },
    };
    const toStop = {
      id: 'stop_2',
      name: 'City Palace',
      location: { lat: 26.9258, lng: 75.8237, address: 'Tulsi Marg, Gangori Bazaar, Jaipur' },
    };

    const leg = await routesService.computeLegTransitOptions({
      fromStop,
      toStop,
      city: 'Jaipur',
    });

    assert.ok(leg);
    assert.equal(leg.fromStopId, 'stop_1');
    assert.equal(leg.toStopId, 'stop_2');
    assert.ok(leg.distanceKm > 0);
    assert.ok(leg.durationMinutes > 0);
    assert.ok(Array.isArray(leg.modes));
    assert.ok(leg.modes.length >= 3);

    const walkMode = leg.modes.find((m) => m.mode === 'walk');
    const autoMode = leg.modes.find((m) => m.mode === 'auto');

    assert.ok(walkMode);
    assert.equal(walkMode.cost, 0);
    assert.ok(autoMode);
    assert.ok(autoMode.cost > 0);
  });

  it('Trip model accurately recalculates dayCost, estimatedTotalCost, and costCategoryBreakdown', () => {
    const trip = new Trip({
      title: 'Royal Rajasthan 3-Day Tour',
      destination: 'Jaipur, Rajasthan',
      budget: 20000,
      itinerary: [
        {
          dayNumber: 1,
          theme: 'Forts & Palaces',
          dayTransportCost: 450,
          stops: [
            {
              id: 's1',
              name: 'Amer Fort Entry',
              category: 'heritage',
              costCategory: 'activities',
              cost: 500,
              order: 0,
            },
            {
              id: 's2',
              name: 'Royal Thali Lunch',
              category: 'food',
              costCategory: 'food',
              cost: 800,
              order: 1,
            },
          ],
        },
        {
          dayNumber: 2,
          theme: 'Bazaars & Crafts',
          dayTransportCost: 300,
          stops: [
            {
              id: 's3',
              name: 'Blue Pottery Workshop',
              category: 'culture',
              costCategory: 'activities',
              cost: 1200,
              order: 0,
            },
            {
              id: 's4',
              name: 'Heritage Haveli Stay',
              category: 'stay',
              costCategory: 'stay',
              cost: 3500,
              order: 1,
            },
          ],
        },
      ],
    });

    trip.recalculateTotalCosts();

    // Verify Day 1: 500 (activities) + 800 (food) + 450 (transport) = 1750
    assert.equal(trip.itinerary[0].dayCost, 1750);

    // Verify Day 2: 1200 (activities) + 3500 (stay) + 300 (transport) = 5000
    assert.equal(trip.itinerary[1].dayCost, 5000);

    // Verify Total: 1750 + 5000 = 6750
    assert.equal(trip.estimatedTotalCost, 6750);

    // Verify Cost Category Breakdown
    assert.equal(trip.costBreakdown.activities, 1700); // 500 + 1200
    assert.equal(trip.costBreakdown.food, 800);
    assert.equal(trip.costBreakdown.stay, 3500);
    assert.equal(trip.costBreakdown.transport, 750); // 450 + 300
  });

  it('Maintains cost integrity when stops are swapped, removed, or added', () => {
    const trip = new Trip({
      title: 'Dynamic Edit Test',
      destination: 'Jaipur',
      itinerary: [
        {
          dayNumber: 1,
          theme: 'Day 1',
          dayTransportCost: 200,
          stops: [
            { id: 's1', cost: 400, costCategory: 'activities', order: 0 },
            { id: 's2', cost: 600, costCategory: 'food', order: 1 },
          ],
        },
      ],
    });

    trip.recalculateTotalCosts();
    assert.equal(trip.itinerary[0].dayCost, 1200); // 400 + 600 + 200
    assert.equal(trip.estimatedTotalCost, 1200);

    // Add Stop 3 (Cost: 1000)
    trip.itinerary[0].stops.push({ id: 's3', cost: 1000, costCategory: 'activities', order: 2 });
    trip.recalculateTotalCosts();

    assert.equal(trip.itinerary[0].dayCost, 2200);
    assert.equal(trip.estimatedTotalCost, 2200);

    // Remove Stop 1 (Cost: 400)
    trip.itinerary[0].stops = trip.itinerary[0].stops.filter((s) => s.id !== 's1');
    trip.recalculateTotalCosts();

    assert.equal(trip.itinerary[0].dayCost, 1800); // 600 + 1000 + 200
    assert.equal(trip.estimatedTotalCost, 1800);
  });
});
