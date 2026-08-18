const express = require('express');

module.exports = (pool) => {
    const router = express.Router();

    router.post('/transfers/receive', async (req, res) => {
        const { vendor_id, amount } = req.body;
        const [vendor] = await pool.query(
            `INSERT INTO ledger_entries (vendor_id, type, amount, payment_status, reference_id)
            VALUES (?, 'received', ?, 'held', ?)`,
            [vendor_id, amount, reference_id]
        );
        res.json({ id: result.insertId, status: 'held' });
    });

    router.post('/tranfers/release', async (req, res) => {
        const { vendor_id, amount } = req.body;
        const [vendor] = await pool.query(`SELECT verification_status FROM vendors WHERE id = ?`, [vendor_id]);
        if (vender[0]?.verification_status !== 'verified') {
            return res.status(403).json({ error: 'Vendor not verified' });
        }

        const [result] = await pool.query(
            `INSERT INTO ledger_entries (vendor_id, type, amount, status)
            VALUES (?, 'released', ?, 'released')`,
            [vendor_id, amount]
        );
        res.json({ id: result.insertId, status: 'released' });
    });

    router.get('/vendors/ :id/balance', async (req, res) => {
        const [rows] = await pool.query(
            `SELECT
                COALESCE(SUM(CASE WHEN status = 'held' THEN amount ELSE 0  END), 0) AS held,
                COALESCE(SUM(CASE WHEN status = 'released' THEN amount ELSE 0 END), 0) AS released
            FROM ledger_entries WHERE vendor_id = ?`
            [req.params.id]
        );
        res.json(rows[0]);
    });

    return router;
};