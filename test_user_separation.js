const axios = require('axios');

const BASE_URL = 'http://localhost:3001/api';

// Test user separation
async function testUserSeparation() {
    console.log('=== TESTING USER SEPARATION ===\n');

    try {
        // Create first user
        console.log('1. Creating first user (user1@test.com)...');
        const user1Response = await axios.post(`${BASE_URL}/auth/register`, {
            email: 'user1@test.com',
            password: 'password123'
        });
        const user1Token = user1Response.data.token;
        console.log('✅ User1 created successfully');

        // Add word for user1
        console.log('2. Adding word "hello" for user1...');
        await axios.post(`${BASE_URL}/user/words`, {
            term: 'hello',
            translations: { 'vi': 'xin chào' },
            example: 'Hello world!'
        }, {
            headers: { Authorization: `Bearer ${user1Token}` }
        });
        console.log('✅ Word added for user1');

        // Get user1's words
        const user1Words = await axios.get(`${BASE_URL}/user/words`, {
            headers: { Authorization: `Bearer ${user1Token}` }
        });
        console.log(`✅ User1 has ${user1Words.data.words.length} word(s): ${user1Words.data.words.map(w => w.term).join(', ')}`);

        // Create second user
        console.log('\n3. Creating second user (user2@test.com)...');
        const user2Response = await axios.post(`${BASE_URL}/auth/register`, {
            email: 'user2@test.com',
            password: 'password123'
        });
        const user2Token = user2Response.data.token;
        console.log('✅ User2 created successfully');

        // Get user2's words (should be empty)
        const user2WordsEmpty = await axios.get(`${BASE_URL}/user/words`, {
            headers: { Authorization: `Bearer ${user2Token}` }
        });
        console.log(`✅ User2 has ${user2WordsEmpty.data.words.length} word(s) (should be 0): ${user2WordsEmpty.data.words.map(w => w.term).join(', ')}`);

        // Add different word for user2
        console.log('4. Adding word "goodbye" for user2...');
        await axios.post(`${BASE_URL}/user/words`, {
            term: 'goodbye',
            translations: { 'vi': 'tạm biệt' },
            example: 'Goodbye friend!'
        }, {
            headers: { Authorization: `Bearer ${user2Token}` }
        });
        console.log('✅ Word added for user2');

        // Get final word counts
        const user1WordsFinal = await axios.get(`${BASE_URL}/user/words`, {
            headers: { Authorization: `Bearer ${user1Token}` }
        });
        const user2WordsFinal = await axios.get(`${BASE_URL}/user/words`, {
            headers: { Authorization: `Bearer ${user2Token}` }
        });

        console.log('\n=== FINAL RESULTS ===');
        console.log(`User1 words: ${user1WordsFinal.data.words.map(w => w.term).join(', ')}`);
        console.log(`User2 words: ${user2WordsFinal.data.words.map(w => w.term).join(', ')}`);

        if (user1WordsFinal.data.words.length === 1 && 
            user2WordsFinal.data.words.length === 1 &&
            user1WordsFinal.data.words[0].term === 'hello' &&
            user2WordsFinal.data.words[0].term === 'goodbye') {
            console.log('\n🎉 SUCCESS: Users have separate word lists!');
        } else {
            console.log('\n❌ FAILED: Users are sharing words');
        }

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
    }
}

testUserSeparation();
