const express = require('express');
const { initiateDeposit } = require('../services.js/mockProcessor');
const { isPositiveInt, isValidAmount, isOneOf } = require('../middleware/validate');

module.exports = (pool) => {
    const router = express.Router();

    //simulate incoming webhook from a payment processor
    router.post('/webhooks/payment', async (req, res) => {
        try{
            const { vendor_id, amount, reference_id } = req.body;
            const event_type = req.body.event_type || 'payment.succeeded'; //UI call

             if(!isPositiveInt(vendor_id)) {
                return res.status(400).json({ error: 'Invalid vendor_id' });
            }
            if(!isValidAmount(rawAmount)) {
                return res.status(400).json({ error: 'Invalid amount' });
            }
            if(!isOneOf(event_type, ['payment.succeeded', 'payment.failed'])) {
                return res.status(400).json({ error: 'Invalid event_type' });
            }

            if (reference_id !== undefined && reference_id !== null) {
                if (typeof reference_id !== 'string' || reference_id.length > 100) {
                    return res.status(400).json({ error: 'reference_id must be a string under 100 characters' });
                }
            }

            await pool.query(
                `INSERT INTO processor_records (vendor_id, amount, reference_id, event_type)
                VALUES (?, ?, ?, ?)`,
                [vendor_id, amount, reference_id || null, event_type]
            );

            //Only creditting the ledger if the processor says it succeeded
            if (event_type === 'payment.failed') {
                return res.json({ status: 'recorded', ledger_updated: 'false'});
            }

            const deposit = await initiateDeposit(vendor_id, amount, reference_id);

            await pool.query(`UPDATE bank_accounts SET balance = balance - ? WHERE owner_type = 'buyer'`, [amount]);

            await pool.query(
                `INSERT INTO ledger_entries (vendor_id, type, amount, payment_status, reference_id)
                VALUES (?, 'received', ?, 'held', ?)`,
                [vendor_id, amount, deposit.reference_id]
            );
            
            res.json({ status: 'recorded', ledger_updated: true, transfer_id: deposit.transfer_id});
        } catch (err) {
            next(err);
        }
    });   
    return router;
};