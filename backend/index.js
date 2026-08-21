require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mysql = require('mysql2/promise');
const errorHandler = require('./middleware/errorHandler.js');

const app = express();

app.use(helmet());


app.use(express.json({ limit: '100kb' }));

const moneyMovementLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 30, //30 requests/minute per IP
    standardHeaders: true,
    legacyHeaders: false,
    message: { error: 'Too many requests - please slow down.'},
});
app.use('/api/transfers', moneyMovementLimiter);
app.use('/api/webhooks', moneyMovementLimiter);

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

app.use('/api', require('./routes/vendor.js')(pool));
app.use('/api', require('./routes/ledger.js')(pool));
app.use('/api', require('./routes/webhook.js')(pool));
app.use('/api', require('./routes/reconcile.js')(pool));

app.use(errorHandler);

app.listen(3000, '0.0.0.0', () => console.log('API running on port 3000'));
