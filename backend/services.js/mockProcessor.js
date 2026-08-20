//attempt at a payment processor like Stripe
//sending money out (payout) and receiving money in (deposit)
function generateTransferId(prefix) {
    const random = Math.random().toString(36).slice(2, 10);
    return `${prefix}_${Date.now()}_${random}`;
}

function delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

//Simulates initiating an outbound transfer to a vendors account
async function initiateTransfer(vendorId, amount) {
    const transferId = generateTransferId('txn_out');

    //real world processing latency(remember bank rails are NOT instant)
    await delay(400);

    return{
        transfer_id: transferId,
        vendor_Id: vendorId,
        amount,
        status: 'completed',
        processed_at: new Date().toISOString(),
    };
}


//simulates inbound payment from a buyer/processor
async function initiateDeposit(vendorId, amount, referenceId) {
    const transferId = generateTransferId('txn_in');

    await delay(300);

    return {
        transfer_id: transferId,
        vendor_id: vendorId,
        amount,
        reference_id: referenceId || transferId,
        status: 'completed',
        processed_at: new Date().toISOString,
    };
}

module.exports = { initiateTransfer, initiateDeposit };