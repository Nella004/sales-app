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

        //Paypals standards are 2.9% + $0.30
        const feeRate = 0.029;
        const fixedFee = 0.30;
        const fee = Math.round((amount * feeRate + fixedFee) * 100) / 100;
        const netAmount = Math.round((amount - fee) * 100) / 100;

        if (netAmount <= 0) {
            return res.status(400).json({ error: 'Amount too small to cover fees' });
        }

        const [result] = await pool.query(
            `INSERT INTO ledger_entries (vendor_id, type, amount, fee, status)
            VALUES (?, 'released', ?, ?, 'released')`,
            [vendor_id, netAmount, fee]
        );
        res.json({ id: result.insertId, status: 'released', gross_amount: 'amount', fee, net_amount: 'netAmount' });
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