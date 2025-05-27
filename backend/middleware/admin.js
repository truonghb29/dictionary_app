const authMiddleware = require('./auth');

const adminMiddleware = async (req, res, next) => {
    // First check authentication
    await authMiddleware(req, res, (err) => {
        if (err) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required'
            });
        }

        // Check if user has admin role
        if (req.user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'Admin access required'
            });
        }

        next();
    });
};

module.exports = adminMiddleware;
