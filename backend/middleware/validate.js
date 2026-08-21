function isPositiveInt(value) {
    const n = Number(value);
    return Number.isInteger(n) && n > 0;
}

function isValidAmount(value) { //rejects infinity, negative, 0, and unreasonable large value
    const n = Number(value);
    return Number.isFinite(n) && n > 0 && n<=1_000_000;
}

function isNonEmptyString(value, maxLength = 255) {
    return typeof value === 'string' && value.trim().length > 0 && value.length <= maxLength;
}

function isOneOf(value, allowedValues) {
    return allowedValues.includes(value);
}

function requireValidIdParam (req, res, next) {
    if (!isPositiveInt(req.params.id)) {
        return res.status(400).json({error: 'Invalid id parameter' });
    }
    next();
}

module.exports = { isPositiveInt, isValidAmount, isNonEmptyString, isOneOf, requireValidIdParam };