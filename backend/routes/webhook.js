const express = require('express');

module.exports = (pool) => {
    const router = express.Router();

    //simulate incoming webhook from a payment processor
    router.post('/webhooks/payment', async (req, res) => {
        const { vendor_id, amount, reference_id, event_type } = req.body;

        await pool.query(
            `INSERT INTO processor_records (vendor_id, amount, reference_id, event_type)
            VALUES (?, ?, ?, ?)`,
            [vendor_id, amount, reference_id, event_type || 'payment.succeeded']
        );

        //Only creditting the ledger if the processor says it succeeded
        if (event_type === 'payment.failed') {
            return res.json({ status: 'recorded', ledger_updated: 'false'});
        }

        await pool.query(
            `INSERT INTO ledger_entries (vendor_id, type, amount, status, reference_id)
            VALUES (?, 'received', ?, 'held', ?)`,
            [vendor_id, amount, reference_id]
        );
        
        res.json({ status: 'recorded', ledger_updated: true});
    });   
    return router;
};