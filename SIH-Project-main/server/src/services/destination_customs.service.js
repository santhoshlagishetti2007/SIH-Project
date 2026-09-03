const mongoose = require('mongoose');
const DestinationCustoms = require('../models/destination_customs.model');

class DestinationCustomsService {
  constructor() {
    this._inMemoryCustoms = new Map(
      DestinationCustoms.getSeedData().map((c) => [c.destination.toLowerCase(), c])
    );
  }

  /**
   * Get Destination Customs, Etiquette, Do's & Don'ts, and Scam alerts
   */
  async getDestinationCustoms(destination = 'Jaipur') {
    const d = destination.trim().toLowerCase();

    if (mongoose.connection.readyState === 1) {
      try {
        const count = await DestinationCustoms.countDocuments();
        if (count === 0) {
          await DestinationCustoms.insertMany(DestinationCustoms.getSeedData());
        }

        const found = await DestinationCustoms.findOne({
          destination: new RegExp(`^${d}$`, 'i'),
        });
        if (found) return found;
      } catch (err) {
        console.warn(`[DestinationCustomsService] MongoDB query error: ${err.message}`);
      }
    }

    return this._inMemoryCustoms.get(d) || this._inMemoryCustoms.get('jaipur');
  }

  /**
   * Admin: Update destination customs guide
   */
  async updateDestinationCustoms(destination, data) {
    const d = destination.trim().toLowerCase();

    if (mongoose.connection.readyState === 1) {
      return await DestinationCustoms.findOneAndUpdate(
        { destination: new RegExp(`^${d}$`, 'i') },
        data,
        { new: true, upsert: true }
      );
    }

    const existing = this._inMemoryCustoms.get(d) || {};
    const updated = { ...existing, destination, ...data };
    this._inMemoryCustoms.set(d, updated);
    return updated;
  }

  /**
   * Get all supported destination customs summaries
   */
  async getAllDestinationsCustomsSummary() {
    if (mongoose.connection.readyState === 1) {
      try {
        return await DestinationCustoms.find().select('destination region dressCode tippingNorms commonScams');
      } catch (err) {
        console.warn(`[DestinationCustomsService] list error: ${err.message}`);
      }
    }

    return Array.from(this._inMemoryCustoms.values());
  }
}

const destinationCustomsService = new DestinationCustomsService();

module.exports = destinationCustomsService;
