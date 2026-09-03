const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const localGroupService = require('../src/services/local_group.service');

describe('Local Community Groups & Admin Verification Suite', () => {
  it('LocalGroupService.getGroups filters by destination and category', async () => {
    const jaipurGroups = await localGroupService.getGroups({ city: 'Jaipur' });
    assert.ok(Array.isArray(jaipurGroups));
    assert.ok(jaipurGroups.length >= 2);
    assert.ok(jaipurGroups.every((g) => g.city.toLowerCase() === 'jaipur'));
    assert.ok(jaipurGroups.every((g) => g.verificationStatus === 'verified'));

    const photoGroups = await localGroupService.getGroups({ category: 'photography' });
    assert.ok(Array.isArray(photoGroups));
    assert.ok(photoGroups.length >= 1);
    assert.equal(photoGroups[0].category, 'photography');
  });

  it('LocalGroupService.createGroup creates pending group and admin verify approves it', async () => {
    const newGroup = await localGroupService.createGroup({
      name: 'Jaipur Sunset Cycling Tribe',
      city: 'Jaipur',
      description: 'Community bicycle rides around Jal Mahal and heritage tracks.',
      category: 'hiking_nature',
      leadName: 'Aditya Sen',
      leadPhone: '+919829077665',
      meetingPoint: 'Jal Mahal Promenade',
      schedule: 'Every Sunday 5:30 PM',
      documentType: 'Aadhaar Card KYC',
      documentId: 'AADHAAR-8839-XXXX',
    });

    assert.ok(newGroup);
    assert.equal(newGroup.name, 'Jaipur Sunset Cycling Tribe');
    assert.equal(newGroup.verificationStatus, 'pending');
    assert.equal(newGroup.verificationDetails.documentId, 'AADHAAR-8839-XXXX');

    // Admin verifies group
    const verifiedGroup = await localGroupService.approveOrRejectGroup(newGroup.id || newGroup._id, {
      status: 'verified',
      reviewerNotes: 'Verified organizer Aadhaar identity and non-commercial cycling club charter.',
      verifiedBy: 'admin_officer_sanchari',
    });

    assert.ok(verifiedGroup);
    assert.equal(verifiedGroup.verificationStatus, 'verified');
    assert.equal(verifiedGroup.verificationDetails.verifiedBy, 'admin_officer_sanchari');
  });

  it('LocalGroupService.requestToJoinGroup attaches traveler message to group lead', async () => {
    const groups = await localGroupService.getGroups({ city: 'Jaipur' });
    const targetGroup = groups[0];
    const groupId = targetGroup.id || targetGroup._id;

    const joinResult = await localGroupService.requestToJoinGroup(groupId, {
      userId: 'traveler_amrut_99',
      userName: 'Amrut',
      userPhone: '+919876543210',
      message: 'Hi Vikramaditya! I am visiting Jaipur this weekend and would love to join the photowalk.',
    });

    assert.ok(joinResult);
    assert.equal(joinResult.success, true);
    assert.equal(joinResult.leadName, targetGroup.leadName);
    assert.equal(joinResult.joinRequest.userName, 'Amrut');
  });

  it('HTTP REST Local Groups endpoints respond with 200/201 via Express', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. GET /api/v1/groups?city=Jaipur
      const listRes = await fetch(`http://127.0.0.1:${port}/api/v1/groups?city=Jaipur`);
      assert.equal(listRes.status, 200);
      const listJson = await listRes.json();
      assert.equal(listJson.success, true);
      assert.ok(listJson.data.length > 0);

      const sampleGroup = listJson.data[0];
      const sampleId = sampleGroup.id || sampleGroup._id;

      // 2. GET /api/v1/groups/:id
      const detailRes = await fetch(`http://127.0.0.1:${port}/api/v1/groups/${sampleId}`);
      assert.equal(detailRes.status, 200);
      const detailJson = await detailRes.json();
      assert.equal(detailJson.success, true);
      assert.equal(detailJson.data.name, sampleGroup.name);

      // 3. POST /api/v1/groups/:id/join
      const joinRes = await fetch(`http://127.0.0.1:${port}/api/v1/groups/${sampleId}/join`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          userName: 'Rohan',
          message: 'Can I join this weekend walk?',
        }),
      });
      assert.equal(joinRes.status, 200);
      const joinJson = await joinRes.json();
      assert.equal(joinJson.success, true);
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
