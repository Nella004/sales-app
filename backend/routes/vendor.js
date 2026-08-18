const express = require('express');

module.exports = (pool) => {
    const router = express.Router();

    router.post('/vendors', async (req, res) => {
        const { name, business_info, id_number } = req.body;
        const [result] = await pool.query(
            `INSERT INTO vendors (name, business_info, id_number, verification_status)
            VALUES (?, ?, ?, 'pending')`,
            [name, business_info, id_number]
        );
        res.json({ id: result.insertId, name, verification_status: 'pending' });
    });

    router.patch('/vendors/ :id/verify', async (req, res) => {
        const { status } = req.body;
        await pool.query(`UPDATE vendors SET verification_status = ? WHERE id = ?`, [status, req.params.id]);
        res.json({ id: req.params.id, verification_status: status });
    });

    router.get('/vendors', async (req, res) => {
        const [rows] = await pool.query('SELECT * FROM vendors');
        res.json(rows);
    });

    return router;
};