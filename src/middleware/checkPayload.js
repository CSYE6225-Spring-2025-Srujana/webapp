const checkPayload = (req, res, next) => {
    const contentLength = req.get('Content-Length');
    if (
        (contentLength && contentLength !== '0') ||
        Object.keys(req.body).length > 0 || 
        Object.keys(req.query).length > 0 ||
        Object.keys(req.params).length > 0
      ) {
      return res.status(400).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
      }).end();
    }
    next();
  };
  
module.exports = { checkPayload };