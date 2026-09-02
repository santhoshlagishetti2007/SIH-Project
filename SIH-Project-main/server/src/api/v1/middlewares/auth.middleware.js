const { getFirebaseAuth } = require('../../../config/firebase.config');

/**
 * Middleware to verify Firebase JWT ID Token and attach user claims to req.user
 */
const verifyAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing or malformed Authorization header. Expected: Bearer <firebase_id_token>',
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

    // Developer test / offline bypass handling
    if (token.startsWith('mock-dev-token') || token.startsWith('dev-token-')) {
      const devUid = token.startsWith('dev-token-')
        ? token.replace('dev-token-', '')
        : 'dev-user-001';

      req.user = {
        uid: devUid,
        email: `${devUid}@sanchari.app`,
        name: 'Sanchari Dev Traveler',
        firebase: { sign_in_provider: 'dev_mock' },
      };
      return next();
    }

    const auth = getFirebaseAuth();

    if (!auth) {
      // In local dev without active Firebase admin credentials, allow structured dev tokens
      if (process.env.NODE_ENV === 'development' || !process.env.NODE_ENV) {
        req.user = {
          uid: 'dev-user-001',
          email: 'dev@sanchari.app',
          name: 'Sanchari Dev Traveler',
          firebase: { sign_in_provider: 'dev_mock' },
        };
        return next();
      }

      return res.status(503).json({
        success: false,
        error: {
          code: 'AUTH_SERVICE_UNAVAILABLE',
          message: 'Firebase Auth is not initialized on the server. Please configure service account credentials.',
        },
        timestamp: new Date().toISOString(),
      });
    }

    const decodedToken = await auth.verifyIdToken(token);
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || '',
      phone: decodedToken.phone_number || '',
      name: decodedToken.name || '',
      picture: decodedToken.picture || null,
      firebase: decodedToken.firebase || {},
    };

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
