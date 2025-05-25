const mongoose = require('mongoose');

const WordSchema = new mongoose.Schema({
    term: {
        type: String,
        required: [true, 'Please provide a term'],
        trim: true
    },
    translations: {
        type: Map,
        of: String,
        required: [true, 'Please provide translations']
    },
    example: {
        type: String,
        trim: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Update the updatedAt field before saving
WordSchema.pre('save', function (next) {
    this.updatedAt = Date.now();
    next();
});

// Create compound index for user and term (prevents duplicate terms per user)
WordSchema.index({ userId: 1, term: 1 }, { unique: true });

module.exports = mongoose.model('Word', WordSchema);
