const express = require('express');
const { initiateTransfer, initiateDeposit } = require('../services.js/mockProcessor');
const { isPositiveInt, isValidAmount, requireValidIdParam } = require('../middleware/validate');

module.exports = (pool) => {
    const router = express.Router();

    router.post('/transfers/send', async (req, res, next) => {
            const { buyer_id, vendor_id, amount: rawAmount } = req.body;

            if(!isPositiveInt(buyer_id)) {
                return res.status(400).json({ error: 'Invalid buyer_id' });
            }
            if(!isPositiveInt(vendor_id)) {
                return res.status(400).json({ error: 'Invalid vendor_id' });
            }
            if(!isValidAmount(rawAmount)) {
                return res.status(400).json({ error: 'Invalid amount' });
            }

            //input validation
            const amount = Number(rawAmount);

            const conn = await pool.getConnection();
            try {
                await conn.beginTransaction();

                const [vendorRows] = await conn.query(
                    `SELECT verification_status FROM vendors WHERE id = ? FOR UPDATE`,
                    [vendor_id]
                );

                if (!vendorRows.length) {
                    await conn.rollback();
                    return res.status(404).json({ error: 'Vendor not found' });
                }
                if (vendorRows[0].verification_status !=='verified') {
                    await conn.rollback();
                    return res.status(403).json({ error: 'Vendor not verified - cannot receive funds'});
                }

                const [buyerRows] = await conn.query(
                    `SELECT balance FROM bank_accounts WHERE owner_type = 'buyer' FOR UPDATE`,
                    [buyer_id]
                );
                if (!buyerRows.length) {
                    await conn.rollback();
                    return res.status(403).json({ error: 'Buyer account not found'});
                }

                const buyerBalance = Number(buyerRows[0].balance);
                if (buyerBalance < amount) {
                    await conn.rollback();
                    return res.status(400).json({ error: 'Insufficient buyer funds'});
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
                const deposit = await initiateDeposit(vendor_id, amount, null);

                await conn.query(
                    `INSERT INTO ledger_entries (vendor_id, type, amount, payment_status, reference_id) VALUES (?, 'received', ?, 'held', ?)`,
                    [vendor_id, amount, deposit.transfer_id]
                );
                await conn.query(
                    `INSERT INTO ledger_entries (vendor_id, type, amount, fee, payment_status, reference_id) VALUES (?, 'released', ?, ?, 'released', ?)`,
                    [vendor_id, netAmount, fee, transfer.transfer_id]
                );
                await conn.query(`UPDATE bank_accounts SET balance = balance - ? WHERE owner_type = 'buyer'`, [amount]);

                await conn.query(
                    `UPDATE bank_accounts SET balance = balance + ? WHERE owner_type = 'vendor' and vendor_id = ?`,
                    [netAmount, vendor_id]
                );

                await conn.commit();

                res.json({
                    transfer_id: transfer.transfer_id,
                    gross_amount: amount,
                    fee,
                    net_amount: netAmount,
                    status: 'completed',
                });

            } catch (err) {
                await conn.rollback();
                    next(err);
            } finally {
                conn.release();
            }
    });


    router.get('/vendors/:id/balance', requireValidIdParam, async (req, res, next) => {
        try {
            const [rows] = await pool.query(
                `SELECT
                    COALESCE(SUM(CASE WHEN payment_status = 'held' THEN amount ELSE 0 END), 0) AS held,
                    COALESCE(SUM(CASE WHEN payment_status = 'released' THEN amount ELSE 0 END), 0) AS released
                FROM ledger_entries WHERE vendor_id = ?`,
                [req.params.id]
            );
            const held = Number(rows[0].held);
            const released = Number(rows[0].released);
            res.json({ held, released, available: Math.round((held - released) * 100) / 100});
        } catch (err) {
            next(err);
        }
    });

    router.get('/vendors/:id/transactions', requireValidIdParam, async (req, res, next) => {
        try{
            const [rows] = await pool.query(
                `SELECT id, type, amount, fee, payment_status, reference_id, created_at
                FROM ledger_entries WHERE vendor_id = ? ORDER BY created_at DESC`,
                [req.params.id]
            );
            res.json(rows);
        } catch (err) {
            next(err);
        }
    });


    router.get('/vendors/:id/bank-balance', requireValidIdParam, async (req, res, next) =>{
        try {
            const [rows] = await pool.query(
                `SELECT balance FROM bank_accounts WHERE owner_type = 'vendor' AND vendor_id = ?`,
                [req.params.id]
            );
            res.json({ balance: rows[0]?.balance ?? 0});
        } catch (err) {
            next(err);
        }
    });

    return router;
};
