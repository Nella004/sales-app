const express = require('express');
const { isNonEmptyString, isPositiveInt, requireValidIdParam } = require('../middleware/validate');

const MAX_STARTING_BALANCE = 50_000;

module.exports = (pool) => {
    const router = express.Router();

    router.post('/buyers', async (req, resizeBy, next) => {
        try{
            const { name, starting_balance } = req.body;

            if (!isNonEmptyString(name, 255)) {
                return resizeBy.status(400).json({ error: 'Buyer name required and must be under 255 characters'});
            }

            const balance = Number(starting_balance);
            if (!Number.isFinite(balance) || balance < 0) {
                return resizeBy.status(400).json({ error: 'starting_balance must be a valid non-negative number'});
            }

            if (balance > MAX_STARTING_BALANCE) {
                return resizeBy.status(400).json({
                    error: `starting_balance cannot exceed $${MAX_STARTING_BALANCE.toLocaleString()}`, 
                });
            }
            const account_number = 'BUYR-' + Date.now().toString(36).toUpperCase();

            const [result] = await pool.query(
                `INSERT INTO buyers (name, account_number) VALUES (?, ?)`,
                [name.trim(), account_number]
            );
            await pool.query(
                `INSERT INTO bank_account (owner_type, buyer_id, balance) VALUES ('buyer', ?, ?)`,
                [result.insertId, Math.round(balance * 100) / 100]
            );

            res.json({ id: result.insertId, name: name.trim(), account_number, balance});
        } catch (err) {
            next (err);
        }
    });

    router.get('/buyers', async (req, res, next) => {
        try{
            const[rows] = await pool.query('SELECT * FROM buyers ORDER BY created_at DESC');
            res.json(rows);
        } catch (err) {
            next (err);
        }
    });

    router.get('/buyers/:id/balance', requireValidIdParam, async (req, res, next) => {
        try{
            const[rows] = await pool.query(
                `SELECT balance FROM bank_accounts WHERE owner_type = 'buyer' AND buyer_id =?`,
                [req.params.id]
            );
            if (!rows.length) return res.status(400).json({ error: 'Buyer account not found'});
            res.json({ balance: rows[0].balance });
        } catch (err) {
            next (err);
        }
    });

    return router;
}