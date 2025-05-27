const mongoose = require('mongoose');

const AnalyticsSchema = new mongoose.Schema({
    date: {
        type: Date,
        required: true,
        unique: true
    },
    totalUsers: {
        type: Number,
        default: 0
    },
    newUsers: {
        type: Number,
        default: 0
    },
    totalWords: {
        type: Number,
        default: 0
    },
    wordsAdded: {
        type: Number,
        default: 0
    },
    activeUsers: {
        type: Number,
        default: 0
    },
    userLoginCount: {
        type: Number,
        default: 0
    },
    popularWords: [{
        term: String,
        frequency: Number
    }],
    languageStats: {
        type: Map,
        of: Number,
        default: new Map()
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Index for efficient date queries
AnalyticsSchema.index({ date: -1 });

module.exports = mongoose.model('Analytics', AnalyticsSchema);
