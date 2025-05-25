const express = require('express');
const Word = require('../models/Word');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// @desc    Get all words for user
// @route   GET /api/dictionary/words
// @access  Private
router.get('/words', authMiddleware, async (req, res) => {
    try {
        const words = await Word.find({ userId: req.user._id }).sort({ createdAt: -1 });

        // Convert to format expected by Flutter app
        const formattedWords = words.map(word => ({
            term: word.term,
            translations: Object.fromEntries(word.translations),
            example: word.example || '',
            createdAt: word.createdAt,
            updatedAt: word.updatedAt
        }));

        res.json({
            success: true,
            words: formattedWords
        });
    } catch (error) {
        console.error('Get words error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error fetching words'
        });
    }
});

// @desc    Add a new word
// @route   POST /api/dictionary/words
// @access  Private
router.post('/words', authMiddleware, async (req, res) => {
    try {
        const { term, translations, example } = req.body;

        if (!term || !translations) {
            return res.status(400).json({
                success: false,
                message: 'Term and translations are required'
            });
        }

        // Check if word already exists for this user
        const existingWord = await Word.findOne({
            userId: req.user._id,
            term: term.trim()
        });

        if (existingWord) {
            return res.status(400).json({
                success: false,
                message: 'Word already exists in your dictionary'
            });
        }

        const word = await Word.create({
            term: term.trim(),
            translations,
            example: example || '',
            userId: req.user._id
        });

        res.status(201).json({
            success: true,
            message: 'Word added successfully',
            word: {
                term: word.term,
                translations: Object.fromEntries(word.translations),
                example: word.example,
                createdAt: word.createdAt
            }
        });
    } catch (error) {
        console.error('Add word error:', error);
        if (error.code === 11000) {
            res.status(400).json({
                success: false,
                message: 'Word already exists in your dictionary'
            });
        } else {
            res.status(500).json({
                success: false,
                message: 'Server error adding word'
            });
        }
    }
});

// @desc    Update all words (bulk save)
// @route   PUT /api/dictionary/words
// @access  Private
router.put('/words', authMiddleware, async (req, res) => {
    try {
        const { words } = req.body;

        if (!Array.isArray(words)) {
            return res.status(400).json({
                success: false,
                message: 'Words must be an array'
            });
        }

        // Delete all existing words for this user
        await Word.deleteMany({ userId: req.user._id });

        // Add new words
        const wordsToInsert = words.map(word => ({
            term: word.term,
            translations: new Map(Object.entries(word.translations)),
            example: word.example || '',
            userId: req.user._id
        }));

        if (wordsToInsert.length > 0) {
            await Word.insertMany(wordsToInsert);
        }

        res.json({
            success: true,
            message: 'Words saved successfully',
            count: wordsToInsert.length
        });
    } catch (error) {
        console.error('Save words error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error saving words'
        });
    }
});

// @desc    Delete a word
// @route   DELETE /api/dictionary/words
// @access  Private
router.delete('/words', authMiddleware, async (req, res) => {
    try {
        const { term } = req.body;

        if (!term) {
            return res.status(400).json({
                success: false,
                message: 'Term is required'
            });
        }

        const deletedWord = await Word.findOneAndDelete({
            userId: req.user._id,
            term: term.trim()
        });

        if (!deletedWord) {
            return res.status(404).json({
                success: false,
                message: 'Word not found'
            });
        }

        res.json({
            success: true,
            message: 'Word deleted successfully'
        });
    } catch (error) {
        console.error('Delete word error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error deleting word'
        });
    }
});

module.exports = router;
