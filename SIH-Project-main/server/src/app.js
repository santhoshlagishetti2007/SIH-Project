const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const envConfig = require('./config/env.config');
const apiV1Router = require('./api/v1/routes');
const { errorHandler, notFoundHandler } = require('./api/v1/middlewares/error.middleware');
const { requestLogger } = require('./api/v1/middlewares/logger.middleware');

const app = express();

// Security HTTP headers
app.use(helmet());

// Cross-Origin Resource Sharing
app.use(
  cors({
    origin: envConfig.corsOrigin === '*' ? true : envConfig.corsOrigin.split(','),
    credentials: true,
  })
);

// Body Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request Logging
if (envConfig.isDevelopment) {
  app.use(morgan('dev'));
} else {
  app.use(requestLogger);
}

// Root ping
app.get('/', (_req, res) => {
  res.status(200).json({
    name: 'Sanchari API Service',
    description: 'AI-Powered Travel Companion Backend',
    version: '1.0.0',
    healthCheck: `${envConfig.apiPrefix}/health`,
  });
});

// API Routes
app.use(envConfig.apiPrefix, apiV1Router);
if (envConfig.apiPrefix !== '/api') {
  app.use('/api', apiV1Router);
}

// 404 & Global Error Handling
app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
