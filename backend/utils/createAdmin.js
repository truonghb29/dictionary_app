const User = require('../models/User');
const bcrypt = require('bcryptjs');

const createAdminUser = async () => {
    try {
        // Check if admin user already exists
        const adminExists = await User.findOne({ email: 'admin@example.com' });
        
        if (adminExists) {
            console.log('Admin user already exists');
            return;
        }

        // Create admin user
        const adminUser = new User({
            email: 'admin@example.com',
            password: 'admin123', // Will be hashed by the pre-save middleware
            role: 'admin'
        });

        await adminUser.save();
        console.log('Admin user created successfully');
        console.log('Email: admin@example.com');
        console.log('Password: admin123');
        console.log('Role: admin');
    } catch (error) {
        console.error('Error creating admin user:', error);
    }
};

module.exports = { createAdminUser };
