const express = require('express');
const { initiateTransfer } = require('../services.js/mockProcessor');

module.exports = (pool) => {
    const router = express.Router();

    router.post('/transfers/release', async (req, res) => {
        try {
            const { vendor_id, amount } = req.body;

            const [vendor] = await pool.query(`SELECT verification_status FROM vendors WHERE id = ?`, [vendor_id]);
            if (!vendor || vendor.length === 0 || vendor[0]?.verification_status !== 'verified') {
                return res.status(403).json({ error: 'Vendor not verified' });
            }

            // Paypals standards are 2.9% + $0.30
            const feeRate = 0.029;
            const fixedFee = 0.30;
            const fee = Math.round((amount * feeRate + fixedFee) * 100) / 100;
            const netAmount = Math.round((amount - fee) * 100) / 100;

            if (netAmount <= 0) {
                return res.status(400).json({ error: 'Amount too small to cover fees' });
            }

            const transfer = await initiateTransfer(vendor_id, netAmount);

            //  FIX 1: Removed the stray single quote inside the VALUES (?, ?, ?, ?, ?, ?') block
            const [result] = await pool.query(
                `INSERT INTO ledger_entries (vendor_id, type, amount, fee, payment_status, reference_id)
                VALUES (?, 'released', ?, ?, ?, ?)`,
                [vendor_id, netAmount, fee, transfer.status === 'completed' ? 'released' : 'failed', transfer.transfer_id]
            );

            //  FIX 2: Passed the numerical variables directly instead of the literal strings 'amount' and 'netAmount'
            res.json({ 
                id: result.insertId, 
                status: transfer.status === 'completed' ? 'released' : 'failed', 
                gross_amount: amount, 
                fee, 
                net_amount: netAmount,
                transfer_id: transfer.transfer_id
            });
        } catch (error) {
            // Added error catch safety to prevent Nodemon from crashing completely on bad database calls
            res.status(500).json({ error: error.message });
        }
    });

    router.get('/vendors/:id/balance', async (req, res) => {
        try {
            const [rows] = await pool.query(
                `SELECT
                    COALESCE(SUM(CASE WHEN payment_status = 'held' THEN amount ELSE 0 END), 0) AS held,
                    COALESCE(SUM(CASE WHEN payment_status = 'released' THEN amount ELSE 0 END), 0) AS released
                FROM ledger_entries WHERE vendor_id = ?`,
                [req.params.id]
            );
            res.json(rows[0]);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }
    });

    return router;
};
