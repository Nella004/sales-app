require('dotenv').config();
const express = require('express');
const mysql = require('myql2/promise');

const app = express();
app.use(express.json());

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

app.use('/api', require('./routes/vendors')(pool));
app.use('/api', require('./routes/ledger')(pool));

app.listen(300, '0.0.0.0', () => console.log('API running on port 3000'));
