const express = require('express');
const { isNonEmptyString, isOneOf, requireValidIdParam } = require('../middleware/validate');

module.exports = (pool) => {
    const router = express.Router();

    router.post('/vendors', async (req, res, next) => {
        try{
            const { name, business_info } = req.body;

            if(!isNonEmptyString(name, 255)) {
                return res.status(400).json({ error: 'Vendor name is required and must be under 255 characters'});
            }

            if (business_info !== undefined && business_info !== null) {
                if (typeof business_info !== 'string' || business_info.length > 1000) {
                    return res.status(400).json({ error: 'Business info must be string under 1000 characters'});
                }
            }

            const account_number = 'ACCT-' + Date.now().toString(36).toUpperCase();

            const [result] = await pool.query(
                `INSERT INTO vendors (name, business_info, id_number, verification_status)
                VALUES (?, ?, ?, 'pending')`,
                [name.trim(), business_info || null, account_number]
            );
            await pool.query(
                `INSERT INTO bank_accounts (owner_type, vendor_id, balance) VALUES ('vendor', ?, 0.00)`,
                [result.insertId]
            )
            res.json({ id: result.insertId, name: name.trim(), account_number, verification_status: 'pending' });
        } catch (err) {
            next(err);
        }
    });

    router.patch('/vendors/:id/verify', requireValidIdParam, async (req, res, next) => {
        try{ 
            const { status } = req.body;
            const allowedStatuses = ['verified', 'unverified', 'pending'];
            if(!isOneOf(status, allowedStatuses)) {
                return res.status(400).json({ error: `status must be one of: ${allowedStatuses.join(', ')}` });
            }

            const [result] = await pool.query(
                'UPDATE vendors SET verification_status = ? WHERE id = ?', 
                [status, req.params.id]
            );
            if (result.affectedRows === 0) {
                return res.status(400).json({ error: 'Vendor not found'});
            }
            res.json({ id: req.params.id, verification_status: status });
        } catch (err) {
            next(err);
        }
    });

    router.get('/vendors', async (req, res, next) => {
        try{
            const [rows] = await pool.query('SELECT * FROM vendors');
            res.json(rows);
        } catch (err) {
            next(err);
        }
    });

    return router;
};