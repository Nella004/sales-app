function errorHandler(err, req, res, next) {
    console.error('[ERROR]', req.method, req.originalUrl, err);
    res.status(500).json({error: 'Something went wrong. Please try again.'});
}

module.exports = errorHandler;