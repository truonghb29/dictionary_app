const express = require('express');
const User = require('../models/User');
const Analytics = require('../models/Analytics');
const adminMiddleware = require('../middleware/admin');

const router = express.Router();

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard
// @access  Private (Admin only)
router.get('/dashboard', adminMiddleware, async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const startOfWeek = new Date(today);
        startOfWeek.setDate(today.getDate() - 7);

        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

        // Get basic stats
        const totalUsers = await User.countDocuments();
        const totalUsersThisMonth = await User.countDocuments({
            createdAt: { $gte: startOfMonth }
        });

        const totalUsersThisWeek = await User.countDocuments({
            createdAt: { $gte: startOfWeek }
        });

        // Get total words across all users
        const wordStats = await User.aggregate([
            {
                $project: {
                    wordCount: { $size: "$words" }
                }
            },
            {
                $group: {
                    _id: null,
                    totalWords: { $sum: "$wordCount" },
                    avgWordsPerUser: { $avg: "$wordCount" }
                }
            }
        ]);

        // Get recent activity
        const recentUsers = await User.find()
            .sort({ createdAt: -1 })
            .limit(5)
            .select('email createdAt lastLogin');

        // Get most active users (by word count)
        const topUsers = await User.aggregate([
            {
                $project: {
                    email: 1,
                    wordCount: { $size: "$words" },
                    lastLogin: 1
                }
            },
            { $sort: { wordCount: -1 } },
            { $limit: 5 }
        ]);

        res.json({
            success: true,
            data: {
                overview: {
                    totalUsers,
                    totalUsersThisMonth,
                    totalUsersThisWeek,
                    totalWords: wordStats[0]?.totalWords || 0,
                    avgWordsPerUser: Math.round(wordStats[0]?.avgWordsPerUser || 0)
                },
                recentUsers,
                topUsers
            }
        });
    } catch (error) {
        console.error('Dashboard stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error fetching dashboard data'
        });
    }
});

// @desc    Get analytics data for charts
// @route   GET /api/admin/analytics
// @access  Private (Admin only)
router.get('/analytics', adminMiddleware, async (req, res) => {
    try {
        const { period = '7d' } = req.query;
        
        let startDate;
        const endDate = new Date();
        
        switch (period) {
            case '7d':
                startDate = new Date();
                startDate.setDate(endDate.getDate() - 7);
                break;
            case '30d':
                startDate = new Date();
                startDate.setDate(endDate.getDate() - 30);
                break;
            case '90d':
                startDate = new Date();
                startDate.setDate(endDate.getDate() - 90);
                break;
            default:
                startDate = new Date();
                startDate.setDate(endDate.getDate() - 7);
        }

        // Get daily user registrations
        const userRegistrations = await User.aggregate([
            {
                $match: {
                    createdAt: { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$createdAt" },
                        month: { $month: "$createdAt" },
                        day: { $dayOfMonth: "$createdAt" }
                    },
                    count: { $sum: 1 }
                }
            },
            {
                $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
            }
        ]);

        // Get words added over time
        const wordsOverTime = await User.aggregate([
            { $unwind: "$words" },
            {
                $match: {
                    "words.createdAt": { $gte: startDate, $lte: endDate }
                }
            },
            {
                $group: {
                    _id: {
                        year: { $year: "$words.createdAt" },
                        month: { $month: "$words.createdAt" },
                        day: { $dayOfMonth: "$words.createdAt" }
                    },
                    count: { $sum: 1 }
                }
            },
            {
                $sort: { "_id.year": 1, "_id.month": 1, "_id.day": 1 }
            }
        ]);

        // Get most popular words
        const popularWords = await User.aggregate([
            { $unwind: "$words" },
            {
                $group: {
                    _id: "$words.term",
                    count: { $sum: 1 }
                }
            },
            { $sort: { count: -1 } },
            { $limit: 10 }
        ]);

        res.json({
            success: true,
            data: {
                userRegistrations,
                wordsOverTime,
                popularWords,
                period
            }
        });
    } catch (error) {
        console.error('Analytics error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error fetching analytics'
        });
    }
});

// @desc    Get all users (with pagination)
// @route   GET /api/admin/users
// @access  Private (Admin only)
router.get('/users', adminMiddleware, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const users = await User.find()
            .select('-password')
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit);

        const total = await User.countDocuments();

        // Add word count to each user
        const usersWithStats = users.map(user => ({
            ...user.toObject(),
            wordCount: user.words.length
        }));

        res.json({
            success: true,
            data: {
                users: usersWithStats,
                pagination: {
                    current: page,
                    total: Math.ceil(total / limit),
                    count: users.length,
                    totalUsers: total
                }
            }
        });
    } catch (error) {
        console.error('Get users error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error fetching users'
        });
    }
});

// @desc    Update user role
// @route   PUT /api/admin/users/:id/role
// @access  Private (Admin only)
router.put('/users/:id/role', adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;
        const { role } = req.body;

        if (!['user', 'admin'].includes(role)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid role. Must be "user" or "admin"'
            });
        }

        const user = await User.findByIdAndUpdate(
            id,
            { role },
            { new: true, select: '-password' }
        );

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'User role updated successfully',
            user
        });
    } catch (error) {
        console.error('Update user role error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error updating user role'
        });
    }
});

// @desc    Delete user
// @route   DELETE /api/admin/users/:id
// @access  Private (Admin only)
router.delete('/users/:id', adminMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        // Prevent admin from deleting themselves
        if (id === req.user._id.toString()) {
            return res.status(400).json({
                success: false,
                message: 'Cannot delete your own account'
            });
        }

        const user = await User.findByIdAndDelete(id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'User deleted successfully'
        });
    } catch (error) {
        console.error('Delete user error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error deleting user'
        });
    }
});

// @desc    Save daily analytics
// @route   POST /api/admin/analytics/save
// @access  Private (Admin only)
router.post('/analytics/save', adminMiddleware, async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Calculate stats for today
        const totalUsers = await User.countDocuments();
        const newUsers = await User.countDocuments({
            createdAt: { 
                $gte: today, 
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) 
            }
        });

        const wordStats = await User.aggregate([
            {
                $project: {
                    wordCount: { $size: "$words" }
                }
            },
            {
                $group: {
                    _id: null,
                    totalWords: { $sum: "$wordCount" }
                }
            }
        ]);

        const wordsAdded = await User.aggregate([
            { $unwind: "$words" },
            {
                $match: {
                    "words.createdAt": { 
                        $gte: today, 
                        $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) 
                    }
                }
            },
            {
                $group: {
                    _id: null,
                    count: { $sum: 1 }
                }
            }
        ]);

        const activeUsers = await User.countDocuments({
            lastLogin: { 
                $gte: today, 
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) 
            }
        });

        // Save or update analytics for today
        const analytics = await Analytics.findOneAndUpdate(
            { date: today },
            {
                totalUsers,
                newUsers,
                totalWords: wordStats[0]?.totalWords || 0,
                wordsAdded: wordsAdded[0]?.count || 0,
                activeUsers,
                userLoginCount: activeUsers // Simplified for now
            },
            { upsert: true, new: true }
        );

        res.json({
            success: true,
            message: 'Analytics saved successfully',
            data: analytics
        });
    } catch (error) {
        console.error('Save analytics error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error saving analytics'
        });
    }
});

module.exports = router;
