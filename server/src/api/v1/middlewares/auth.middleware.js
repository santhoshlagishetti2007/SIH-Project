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

    const token = authHeader.split('Bearer ')[1];
    const auth = getFirebaseAuth();

    if (!auth) {
      // In local dev without active Firebase admin credentials, allow a mock bypass if configured
      if (process.env.NODE_ENV === 'development' && token === 'mock-dev-token') {
        req.user = {
          uid: 'dev-user-001',
          email: 'dev@sanchari.app',
          name: 'Sanchari Dev User',
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
