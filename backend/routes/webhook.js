const express = require('express');
const { initiateDeposit } = require('../services.js/mockProcessor');

module.exports = (pool) => {
    const router = express.Router();

    //simulate incoming webhook from a payment processor
    router.post('/webhooks/payment', async (req, res) => {

        const { vendor_id, amount, reference_id } = req.body;
        const event_type = req.body.event_type || 'payment.succeeded'; //UI call

        await pool.query(
            `INSERT INTO processor_records (vendor_id, amount, reference_id, event_type)
            VALUES (?, ?, ?, ?)`,
            [vendor_id, amount, reference_id, event_type]
        );

        //Only creditting the ledger if the processor says it succeeded
        if (event_type === 'payment.failed') {
            return res.json({ status: 'recorded', ledger_updated: 'false'});
        }

        const deposit = await initiateDeposit(vendor_id, amount, reference_id);

        await pool.query(
            `INSERT INTO ledger_entries (vendor_id, type, amount, payment_status, reference_id)
            VALUES (?, 'received', ?, 'held', ?)`,
            [vendor_id, amount, deposit.reference_id]
        );
        
        res.json({ status: 'recorded', ledger_updated: true, transfer_id: deposit.transfer_id});
    });   
    return router;
};