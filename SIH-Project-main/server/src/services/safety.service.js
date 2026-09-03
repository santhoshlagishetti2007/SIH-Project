const mongoose = require('mongoose');
const SafetySession = require('../models/safety_session.model');

class SafetyService {
  constructor() {
    this._inMemorySessions = new Map();
  }

  /**
   * Trigger emergency SOS alert with live location link broadcast
   */
  async triggerSos({
    userId = 'guest_user',
    userName = 'Traveler',
    userPhone = '+919876543210',
    location = { lat: 26.9124, lng: 75.7873, accuracy: 10, speed: 0, battery: 85, address: 'Jaipur, Rajasthan' },
    emergencyContacts = [],
    autoDialNumber = '112',
  }) {
    const sessionId = `sos_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    const trackingUrl = `/live-track/${sessionId}`;

    const sessionData = {
      sessionId,
      userId,
      userName,
      userPhone,
      sessionType: 'sos_alert',
      isActive: true,
      currentLocation: {
        lat: location.lat || 26.9124,
        lng: location.lng || 75.7873,
        accuracy: location.accuracy || 10,
        speed: location.speed || 0,
        battery: location.battery || 85,
        address: location.address || 'Live Location',
      },
      locationHistory: [
        {
          lat: location.lat || 26.9124,
          lng: location.lng || 75.7873,
          speed: location.speed || 0,
          timestamp: new Date(),
        },
      ],
      emergencyContacts: Array.isArray(emergencyContacts) ? emergencyContacts : [],
      sosTriggeredAt: new Date(),
      lastPingAt: new Date(),
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
    };

    let session;
    if (mongoose.connection.readyState === 1) {
      try {
        const doc = new SafetySession(sessionData);
        session = await doc.save();
      } catch (err) {
        console.warn(`[SafetyService] MongoDB save error: ${err.message}`);
      }
    }

    if (!session) {
      this._inMemorySessions.set(sessionId, sessionData);
      session = sessionData;
    }

    // Prepare simulated SMS notifications for contacts
    const notificationsSent = (emergencyContacts || []).map((contact) => ({
      contactName: contact.name,
      contactPhone: contact.phone,
      message: `🚨 EMERGENCY SOS from ${userName}! View live map: http://localhost:5000/live-track/${sessionId} | Coordinates: ${sessionData.currentLocation.lat}, ${sessionData.currentLocation.lng}`,
      status: 'dispatched',
    }));

    return {
      success: true,
      sessionId,
      trackingUrl,
      publicTrackingUrl: `http://localhost:5000/live-track/${sessionId}`,
      googleMapsUrl: `https://www.google.com/maps/search/?api=1&query=${sessionData.currentLocation.lat},${sessionData.currentLocation.lng}`,
      contactsNotifiedCount: notificationsSent.length,
      notifications: notificationsSent,
      emergencyHelpline: autoDialNumber || '112',
      session,
    };
  }

  /**
   * Start a Live Trip Sharing session ("Share My Trip")
   */
  async startTripShare({
    userId = 'guest_user',
    userName = 'Traveler',
    userPhone = '+919876543210',
    location = { lat: 26.9124, lng: 75.7873, accuracy: 10, speed: 0, battery: 90, address: 'Trip Start Location' },
    emergencyContacts = [],
    durationHours = 12,
  }) {
    const sessionId = `trip_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    const trackingUrl = `/live-track/${sessionId}`;

    const sessionData = {
      sessionId,
      userId,
      userName,
      userPhone,
      sessionType: 'trip_share',
      isActive: true,
      currentLocation: {
        lat: location.lat || 26.9124,
        lng: location.lng || 75.7873,
        accuracy: location.accuracy || 10,
        speed: location.speed || 0,
        battery: location.battery || 90,
        address: location.address || 'Active Trip Sharing',
      },
      locationHistory: [
        {
          lat: location.lat || 26.9124,
          lng: location.lng || 75.7873,
          speed: location.speed || 0,
          timestamp: new Date(),
        },
      ],
      emergencyContacts: Array.isArray(emergencyContacts) ? emergencyContacts : [],
      lastPingAt: new Date(),
      expiresAt: new Date(Date.now() + durationHours * 60 * 60 * 1000),
    };

    let session;
    if (mongoose.connection.readyState === 1) {
      try {
        const doc = new SafetySession(sessionData);
        session = await doc.save();
      } catch (err) {
        console.warn(`[SafetyService] MongoDB save error: ${err.message}`);
      }
    }

    if (!session) {
      this._inMemorySessions.set(sessionId, sessionData);
      session = sessionData;
    }

    return {
      success: true,
      sessionId,
      trackingUrl,
      publicTrackingUrl: `http://localhost:5000/live-track/${sessionId}`,
      session,
    };
  }

  /**
   * Periodic live location update from mobile device (e.g. every 10s)
   */
  async updateLiveLocation({ sessionId, lat, lng, speed = 0, battery = 80, address = '' }) {
    if (mongoose.connection.readyState === 1) {
      try {
        const session = await SafetySession.findOne({ sessionId });
        if (session) {
          session.currentLocation = {
            lat: Number(lat),
            lng: Number(lng),
            speed: Number(speed),
            battery: Number(battery),
            address: address || session.currentLocation.address,
            accuracy: 10,
          };
          session.locationHistory.push({
            lat: Number(lat),
            lng: Number(lng),
            speed: Number(speed),
            timestamp: new Date(),
          });
          session.lastPingAt = new Date();
          await session.save();
          return session;
        }
      } catch (err) {
        console.warn(`[SafetyService] updateLiveLocation MongoDB error: ${err.message}`);
      }
    }

    const inMem = this._inMemorySessions.get(sessionId);
    if (inMem) {
      inMem.currentLocation = {
        lat: Number(lat),
        lng: Number(lng),
        speed: Number(speed),
        battery: Number(battery),
        address: address || inMem.currentLocation.address,
        accuracy: 10,
      };
      inMem.locationHistory.push({
        lat: Number(lat),
        lng: Number(lng),
        speed: Number(speed),
        timestamp: new Date(),
      });
      inMem.lastPingAt = new Date();
      return inMem;
    }

    return null;
  }

  /**
   * Stop an active sharing or SOS session
   */
  async stopSession({ sessionId, userId }) {
    if (mongoose.connection.readyState === 1) {
      try {
        const query = { sessionId };
        if (userId) query.userId = userId;
        const updated = await SafetySession.findOneAndUpdate(
          query,
          { isActive: false, lastPingAt: new Date() },
          { new: true }
        );
        if (updated) return updated;
      } catch (err) {
        console.warn(`[SafetyService] stopSession MongoDB error: ${err.message}`);
      }
    }

    const inMem = this._inMemorySessions.get(sessionId);
    if (inMem) {
      inMem.isActive = false;
      inMem.lastPingAt = new Date();
      return inMem;
    }

    return { sessionId, isActive: false };
  }

  /**
   * Get active session by ID for web tracking viewer
   */
  async getSession(sessionId) {
    if (mongoose.connection.readyState === 1) {
      try {
        const session = await SafetySession.findOne({ sessionId });
        if (session) return session;
      } catch (err) {
        console.warn(`[SafetyService] getSession MongoDB error: ${err.message}`);
      }
    }

    if (this._inMemorySessions.has(sessionId)) {
      return this._inMemorySessions.get(sessionId);
    }

    // Default mock session for direct testing
    return {
      sessionId,
      userName: 'Amrut (Traveler)',
      userPhone: '+919829012345',
      sessionType: 'sos_alert',
      isActive: true,
      currentLocation: {
        lat: 26.9124,
        lng: 75.7873,
        accuracy: 8,
        speed: 12,
        battery: 88,
        address: 'Pink City, Jaipur, Rajasthan',
      },
      locationHistory: [
        { lat: 26.9050, lng: 75.7800, speed: 18, timestamp: new Date(Date.now() - 60000) },
        { lat: 26.9124, lng: 75.7873, speed: 12, timestamp: new Date() },
      ],
      emergencyContacts: [
        { name: 'Family Contact', phone: '+919829099887', relation: 'parent' },
      ],
      sosTriggeredAt: new Date(),
      lastPingAt: new Date(),
    };
  }
}

const safetyService = new SafetyService();

module.exports = safetyService;
