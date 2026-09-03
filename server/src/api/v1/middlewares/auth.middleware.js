const { getFirebaseAuth } = require('../../../config/firebase.config');

/**
 * Middleware to verify Firebase JWT ID Token
 */
const verifyAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing or malformed Authorization header. Expected Bearer <token>',
        },
        timestamp: new Date().toISOString(),
      });
    }

    const token = authHeader.split('Bearer ')[1].trim();

    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'Bearer token payload is empty.',
        },
        timestamp: new Date().toISOString(),
      });
    }

    // Developer test / offline mock token handling
    if (token.startsWith('mock-dev-token') || token.startsWith('dev-token-') || token === 'mock-dev-token') {
      const devUid = token.startsWith('dev-token-')
        ? token.replace('dev-token-', '')
        : 'dev-user-001';

      req.user = {
        uid: devUid,
        email: `${devUid}@sanchari.app`,
        name: 'Sanchari Dev User',
        firebase: { sign_in_provider: 'dev_mock' },
      };
      return next();
    }

    const auth = getFirebaseAuth();

    if (!auth) {
      if (process.env.NODE_ENV === 'development' || !process.env.NODE_ENV || process.env.NODE_ENV === 'test') {
        req.user = {
          uid: 'dev-user-001',
          email: 'dev@sanchari.app',
          name: 'Sanchari Dev User',
          firebase: { sign_in_provider: 'dev_mock' },
        };
        return next();
      }

      return res.status(503).json({
        success: false,
        error: {
          code: 'AUTH_SERVICE_UNAVAILABLE',
          message: 'Firebase Auth is not initialized on the server.',
        },
        timestamp: new Date().toISOString(),
      });
    }

    const decodedToken = await auth.verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'INVALID_TOKEN',
        message: 'Invalid or expired Firebase ID token',
        details: error.message,
      },
      timestamp: new Date().toISOString(),
    });
  }
};

module.exports = {
  verifyAuth,
};
