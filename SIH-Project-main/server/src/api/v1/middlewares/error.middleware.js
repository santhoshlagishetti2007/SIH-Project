/**
 * 404 Not Found Middleware
 */
const notFoundHandler = (req, res, _next) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'ROUTE_NOT_FOUND',
      message: `The requested endpoint ${req.method} ${req.originalUrl} was not found on this server.`,
    },
    timestamp: new Date().toISOString(),
  });
};

/**
 * Global Error Handler Middleware
 */
const errorHandler = (err, req, res, _next) => {
  const statusCode = err.statusCode || err.status || 500;
  const isDev = process.env.NODE_ENV === 'development';

  console.error(`[Error] ${req.method} ${req.originalUrl}:`, err);

  res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_SERVER_ERROR',
      message: err.message || 'An unexpected error occurred.',
      details: isDev ? err.stack : undefined,
    },
    timestamp: new Date().toISOString(),
  });
};

module.exports = {
  notFoundHandler,
  errorHandler,
};
