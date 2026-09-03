const mongoose = require('mongoose');
const LocalGroup = require('../models/local_group.model');

class LocalGroupService {
  constructor() {
    this._inMemoryGroups = LocalGroup.getSeedData().map((g, idx) => ({
      id: `group_${idx + 1}`,
      _id: `group_${idx + 1}`,
      ...g,
      joinRequests: [],
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  }

  /**
   * Get public community groups with destination and category filters
   */
  async getGroups({ city, category, status = 'verified', search } = {}) {
    if (mongoose.connection.readyState === 1) {
      try {
        const count = await LocalGroup.countDocuments();
        if (count === 0) {
          await LocalGroup.insertMany(LocalGroup.getSeedData());
        }

        const query = {};
        if (status && status !== 'all') {
          query.verificationStatus = status;
        }
        if (city && city.toLowerCase() !== 'all') {
          query.city = new RegExp(city, 'i');
        }
        if (category && category.toLowerCase() !== 'all') {
          query.category = category.toLowerCase();
        }
        if (search) {
          const s = new RegExp(search, 'i');
          query.$or = [{ name: s }, { description: s }, { tags: s }, { leadName: s }];
        }

        return await LocalGroup.find(query).sort({ membersCount: -1 });
      } catch (err) {
        console.warn(`[LocalGroupService] MongoDB query error: ${err.message}`);
      }
    }

    // In-memory fallback
    return this._inMemoryGroups.filter((g) => {
      if (status && status !== 'all' && g.verificationStatus !== status) return false;
      if (city && city.toLowerCase() !== 'all' && g.city.toLowerCase() !== city.toLowerCase()) return false;
      if (category && category.toLowerCase() !== 'all' && g.category.toLowerCase() !== category.toLowerCase()) return false;
      if (search) {
        const term = search.toLowerCase();
        const matchName = g.name.toLowerCase().includes(term);
        const matchDesc = g.description.toLowerCase().includes(term);
        const matchTag = g.tags.some((t) => t.toLowerCase().includes(term));
        if (!matchName && !matchDesc && !matchTag) return false;
      }
      return true;
    });
  }

  /**
   * Get single group by ID
   */
  async getGroupById(id) {
    if (mongoose.connection.readyState === 1) {
      try {
        if (mongoose.isValidObjectId(id)) {
          const group = await LocalGroup.findById(id);
          if (group) return group;
        }
      } catch (err) {
        console.warn(`[LocalGroupService] findById error: ${err.message}`);
      }
    }

    return this._inMemoryGroups.find((g) => g.id === id || g._id === id);
  }

  /**
   * Submit a new community group (starts as 'pending' verification)
   */
  async createGroup(data) {
    const newGroupData = {
      name: data.name,
      city: data.city || 'Jaipur',
      description: data.description,
      category: data.category || 'heritage_walk',
      leadName: data.leadName,
      leadContact: {
        phone: data.leadPhone || data.leadContact?.phone || '+919876543210',
        email: data.leadEmail || data.leadContact?.email || 'lead@sanchari.local',
        whatsapp: data.leadWhatsapp || data.leadContact?.whatsapp || '+919876543210',
      },
      meetingPoint: data.meetingPoint || 'City Center',
      schedule: data.schedule || 'Weekend Morning',
      coverPhoto: data.coverPhoto || 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
      tags: Array.isArray(data.tags) ? data.tags : ['Community Walk', 'Non-Commercial'],
      verificationStatus: 'pending',
      verificationDetails: {
        documentType: data.documentType || 'Aadhaar Photo ID',
        documentId: data.documentId || 'SUBMITTED-PENDING-CHECK',
        reviewerNotes: 'Awaiting admin document verification and charter review.',
        verifiedAt: null,
        verifiedBy: null,
      },
      membersCount: 1,
      maxMembers: data.maxMembers ? parseInt(data.maxMembers, 10) : 50,
      joinRequests: [],
    };

    if (mongoose.connection.readyState === 1) {
      try {
        const doc = new LocalGroup(newGroupData);
        return await doc.save();
      } catch (err) {
        console.warn(`[LocalGroupService] MongoDB create error: ${err.message}`);
      }
    }

    const inMem = {
      id: `group_${Date.now()}`,
      _id: `group_${Date.now()}`,
      ...newGroupData,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this._inMemoryGroups.push(inMem);
    return inMem;
  }

  /**
   * Admin Approval Step: Verify or Reject a Community Group
   */
  async approveOrRejectGroup(id, { status = 'verified', reviewerNotes = 'Verified organizer credentials', verifiedBy = 'admin_security' } = {}) {
    if (mongoose.connection.readyState === 1) {
      try {
        if (mongoose.isValidObjectId(id)) {
          const updated = await LocalGroup.findByIdAndUpdate(
            id,
            {
              verificationStatus: status,
              'verificationDetails.reviewerNotes': reviewerNotes,
              'verificationDetails.verifiedAt': status === 'verified' ? new Date() : null,
              'verificationDetails.verifiedBy': verifiedBy,
            },
            { new: true }
          );
          if (updated) return updated;
        }
      } catch (err) {
        console.warn(`[LocalGroupService] approve error: ${err.message}`);
      }
    }

    const group = this._inMemoryGroups.find((g) => g.id === id || g._id === id);
    if (group) {
      group.verificationStatus = status;
      group.verificationDetails = {
        ...group.verificationDetails,
        reviewerNotes,
        verifiedAt: status === 'verified' ? new Date() : null,
        verifiedBy,
      };
      return group;
    }

    return null;
  }

  /**
   * Traveler request to join / message group lead
   */
  async requestToJoinGroup(id, { userId = 'traveler_user', userName = 'Traveler', userPhone = '', message = 'Hi! I would love to join your upcoming community walk.' } = {}) {
    const joinReq = {
      userId,
      userName,
      userPhone,
      message,
      requestedAt: new Date(),
      status: 'pending',
    };

    let group = null;
    if (mongoose.connection.readyState === 1) {
      try {
        if (mongoose.isValidObjectId(id)) {
          group = await LocalGroup.findByIdAndUpdate(
            id,
            { $push: { joinRequests: joinReq } },
            { new: true }
          );
        }
      } catch (err) {
        console.warn(`[LocalGroupService] join request error: ${err.message}`);
      }
    }

    if (!group) {
      group = this._inMemoryGroups.find((g) => g.id === id || g._id === id);
      if (group) {
        group.joinRequests.push(joinReq);
      }
    }

    if (!group) return null;

    return {
      success: true,
      message: `Join request & message successfully dispatched to ${group.leadName}`,
      groupName: group.name,
      leadName: group.leadName,
      leadContact: group.leadContact,
      joinRequest: joinReq,
    };
  }

  /**
   * Admin: Get all pending group submissions awaiting verification
   */
  async getAdminPendingGroups() {
    return this.getGroups({ status: 'pending' });
  }
}

const localGroupService = new LocalGroupService();

module.exports = localGroupService;
