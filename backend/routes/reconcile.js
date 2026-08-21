const express = require('express');

module.exports = (pool) => {
    const router = express.Router();

    router.get('/reconcile', async (req, res, next) => {
        try{
            const [mismatches] = await pool.query(`
            SELECT
                p.reference_id,
                p.vendor_id,
                p.amount AS processor_amount,
                l.amount AS ledger_amount,
                CASE
                    WHEN l.amount IS NULL THEN 'missing_in_ledger'
                    WHEN l.amount != p.amount THEN 'amount_mismatch'
                    ELSE 'ok'
                END AS status
            FROM processor_records p
            LEFT JOIN ledger_entries l
                ON l.reference_id = p.reference_id AND l.type = 'received'
            HAVING status != 'ok'
            `);

            res.json({ mismatch_count: mismatches.length, mismatches });
        } catch (err) {
            next(err);
        }
    });

    return router;
};