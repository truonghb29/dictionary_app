const express = require('express');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// @desc    Get all words for user
// @route   GET /api/user/words
// @access  Private
router.get('/words', authMiddleware, async (req, res) => {
    try {
        // Find user by ID and select only the words field
        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Format words for the response
        const formattedWords = user.words.map(word => ({
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
// @route   POST /api/user/words
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

        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check if the word already exists
        const existingWordIndex = user.words.findIndex(word => word.term === term.trim());
        if (existingWordIndex !== -1) {
            return res.status(400).json({
                success: false,
                message: 'Word already exists in your dictionary'
            });
        }

        // Create new word
        const newWord = {
            term: term.trim(),
            translations: new Map(Object.entries(translations)),
            example: example || '',
            createdAt: new Date(),
            updatedAt: new Date()
        };

        // Add word to user's words array
        user.words.push(newWord);
        await user.save();

        // Format for response
        const wordResponse = {
            term: newWord.term,
            translations: Object.fromEntries(newWord.translations),
            example: newWord.example,
            createdAt: newWord.createdAt
        };

        res.status(201).json({
            success: true,
            message: 'Word added successfully',
            word: wordResponse
        });
    } catch (error) {
        console.error('Add word error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error adding word'
        });
    }
});

// @desc    Update a word
// @route   PUT /api/user/words/:term
// @access  Private
router.put('/words/:term', authMiddleware, async (req, res) => {
    try {
        const { translations, example } = req.body;
        const termToUpdate = req.params.term;

        if (!translations) {
            return res.status(400).json({
                success: false,
                message: 'Translations are required'
            });
        }

        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Find the word to update
        const wordIndex = user.words.findIndex(word => word.term === termToUpdate);
        if (wordIndex === -1) {
            return res.status(404).json({
                success: false,
                message: 'Word not found'
            });
        }

        // Update the word
        user.words[wordIndex].translations = new Map(Object.entries(translations));
        user.words[wordIndex].example = example || '';
        user.words[wordIndex].updatedAt = new Date();

        await user.save();

        // Format for response
        const updatedWord = {
            term: user.words[wordIndex].term,
            translations: Object.fromEntries(user.words[wordIndex].translations),
            example: user.words[wordIndex].example,
            updatedAt: user.words[wordIndex].updatedAt
        };

        res.json({
            success: true,
            message: 'Word updated successfully',
            word: updatedWord
        });
    } catch (error) {
        console.error('Update word error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error updating word'
        });
    }
});

// @desc    Delete a word
// @route   DELETE /api/user/words/:term
// @access  Private
router.delete('/words/:term', authMiddleware, async (req, res) => {
    try {
        const termToDelete = req.params.term;

        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Initial word count
        const initialWordCount = user.words.length;

        // Remove the word from words array
        user.words = user.words.filter(word => word.term !== termToDelete);

        // Check if any word was removed
        if (user.words.length === initialWordCount) {
            return res.status(404).json({
                success: false,
                message: 'Word not found'
            });
        }

        await user.save();

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

// @desc    Update all words (bulk save)
// @route   PUT /api/user/words
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

        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Replace user's words with new words array
        user.words = words.map(word => ({
            term: word.term,
            translations: new Map(Object.entries(word.translations)),
            example: word.example || '',
            createdAt: word.createdAt || new Date(),
            updatedAt: new Date()
        }));

        await user.save();

        res.json({
            success: true,
            message: 'Words saved successfully',
            count: user.words.length
        });
    } catch (error) {
        console.error('Save words error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error saving words'
        });
    }
});

module.exports = router;
