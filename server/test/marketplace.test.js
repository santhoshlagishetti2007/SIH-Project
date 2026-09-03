const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const marketplaceService = require('../src/services/marketplace.service');

describe('Local Finds Marketplace & Vendor Listings Suite', () => {
  it('MarketplaceService.getListings returns destination filtered local finds', async () => {
    const jaipurFinds = await marketplaceService.getListings({ city: 'Jaipur' });
    assert.ok(Array.isArray(jaipurFinds), 'Expected array of listings');
    assert.ok(jaipurFinds.length > 0, 'Expected at least 1 Jaipur local find');

    const first = jaipurFinds[0];
    assert.ok(first.name, 'Listing must have a name');
    assert.ok(first.price > 0, 'Listing price must be greater than 0');
    assert.ok(first.vendorName, 'Listing must have a vendor name');
    assert.ok(first.vendorPhone, 'Listing must have a contact phone');
    assert.equal(first.vendorLocation.city.toLowerCase(), 'jaipur');
  });

  it('MarketplaceService.getListings filters by category', async () => {
    const crafts = await marketplaceService.getListings({ category: 'craft' });
    assert.ok(Array.isArray(crafts));
    assert.ok(crafts.length > 0);
    assert.ok(crafts.every((c) => c.category === 'craft'));
  });

  it('MarketplaceService.createListing creates a new artisan product', async () => {
    const newProduct = await marketplaceService.createListing({
      name: 'Handcrafted Wooden Elephant Figure',
      category: 'gift',
      price: 750,
      originalPrice: 950,
      vendorName: 'Jaipur Wood Carvers Guild',
      vendorPhone: '+919829111222',
      vendorWhatsApp: '+919829111222',
      vendorLocation: {
        city: 'Jaipur',
        state: 'Rajasthan',
        address: 'Tripolia Bazaar, Jaipur',
      },
      description: 'Single block carved wooden elephant with floral jaali work.',
      story: 'Carved by master artisans in Tripolia Bazaar using traditional chisels.',
      regionTags: ['Jaipur', 'Woodcraft', 'Handmade'],
    });

    assert.ok(newProduct.name);
    assert.equal(newProduct.price, 750);
    assert.equal(newProduct.vendorName, 'Jaipur Wood Carvers Guild');
  });

  it('HTTP REST Marketplace endpoints respond with 200/201 via Express', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. GET /api/v1/marketplace/finds
      const res = await fetch(`http://127.0.0.1:${port}/api/v1/marketplace/finds?city=Jaipur`);
      assert.equal(res.status, 200);
      const json = await res.json();
      assert.equal(json.success, true);
      assert.ok(json.data.length > 0);

      // 2. POST /api/v1/marketplace/finds
      const createRes = await fetch(`http://127.0.0.1:${port}/api/v1/marketplace/finds`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: 'Hand-woven Rajasthani Jutti',
          category: 'craft',
          price: 990,
          vendorName: 'Mojari Craft Emporium',
          vendorPhone: '+919829099887',
        }),
      });
      assert.equal(createRes.status, 201);
      const createdJson = await createRes.json();
      assert.equal(createdJson.success, true);
      assert.equal(createdJson.data.name, 'Hand-woven Rajasthani Jutti');
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
