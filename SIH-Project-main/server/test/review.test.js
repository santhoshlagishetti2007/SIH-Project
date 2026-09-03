const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const http = require('http');
const app = require('../src/app');
const reviewService = require('../src/services/review.service');

describe('Universal Cross-Feature Reviews & Moderation Suite', () => {
  it('ReviewService.getReviews computes average rating, count, and star breakdown', async () => {
    const summary = await reviewService.getReviews({ targetId: 'eat_rawat_kachori' });
    assert.ok(summary);
    assert.equal(summary.targetId, 'eat_rawat_kachori');
    assert.ok(summary.totalReviews >= 2);
    assert.ok(summary.averageRating >= 4.0 && summary.averageRating <= 5.0);
    assert.ok(summary.ratingBreakdown);
    assert.ok(summary.ratingBreakdown[5] >= 1);
  });

  it('ReviewService.createReview creates a new review and updates rating average', async () => {
    const newRev = await reviewService.createReview({
      targetType: 'group',
      targetId: 'group_test_photowalk',
      userId: 'user_priya_101',
      userName: 'Priya',
      rating: 5,
      text: 'Super friendly group! Had so much fun exploring sunrise spots.',
      photos: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?w=600'],
    });

    assert.ok(newRev);
    assert.equal(newRev.rating, 5);
    assert.equal(newRev.userName, 'Priya');
    assert.equal(newRev.isHidden, false);

    const summary = await reviewService.getReviews({ targetId: 'group_test_photowalk' });
    assert.equal(summary.totalReviews, 1);
    assert.equal(summary.averageRating, 5.0);
  });

  it('ReviewService.reportReview auto-hides review after 3 reports', async () => {
    const testRev = await reviewService.createReview({
      targetType: 'place',
      targetId: 'place_spam_test',
      userId: 'spammer_1',
      userName: 'Spammer',
      rating: 1,
      text: 'Spam text with inappropriate promotions.',
    });

    const revId = testRev.id || testRev._id;

    // Report 1
    const rep1 = await reviewService.reportReview(revId, { userId: 'user_a' });
    assert.equal(rep1.isHidden, false);
    assert.equal(rep1.reportCount, 1);

    // Report 2
    const rep2 = await reviewService.reportReview(revId, { userId: 'user_b' });
    assert.equal(rep2.isHidden, false);
    assert.equal(rep2.reportCount, 2);

    // Report 3 (Threshold reached -> Auto-hide)
    const rep3 = await reviewService.reportReview(revId, { userId: 'user_c' });
    assert.equal(rep3.isHidden, true);
    assert.equal(rep3.reportCount, 3);

    // Ensure hidden review is excluded from public query
    const publicQuery = await reviewService.getReviews({ targetId: 'place_spam_test' });
    assert.equal(publicQuery.totalReviews, 0);
  });

  it('HTTP REST Review endpoints respond with 200/201 via Express (both /api/v1/reviews and /api/reviews)', async () => {
    const server = http.createServer(app);
    await new Promise((resolve) => server.listen(0, resolve));
    const port = server.address().port;

    try {
      // 1. GET /api/v1/reviews?targetId=eat_rawat_kachori
      const resV1 = await fetch(`http://127.0.0.1:${port}/api/v1/reviews?targetId=eat_rawat_kachori`);
      assert.equal(resV1.status, 200);
      const jsonV1 = await resV1.json();
      assert.equal(jsonV1.success, true);
      assert.ok(jsonV1.data.averageRating > 0);

      // 2. GET /api/reviews?targetId=eat_rawat_kachori (Root alias)
      const resAlias = await fetch(`http://127.0.0.1:${port}/api/reviews?targetId=eat_rawat_kachori`);
      assert.equal(resAlias.status, 200);
      const jsonAlias = await resAlias.json();
      assert.equal(jsonAlias.success, true);

      // 3. POST /api/v1/reviews
      const postRes = await fetch(`http://127.0.0.1:${port}/api/v1/reviews`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          targetType: 'eatery',
          targetId: 'eat_rawat_kachori',
          userName: 'Traveler Ankit',
          rating: 5,
          text: 'Incredible taste and authentic flavours!',
        }),
      });
      assert.equal(postRes.status, 201);
      const postJson = await postRes.json();
      assert.equal(postJson.success, true);
      assert.ok(postJson.data.id || postJson.data._id);
    } finally {
      await new Promise((resolve) => server.close(resolve));
    }
  });
});
