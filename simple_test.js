console.log('=== TESTING USER SEPARATION ===');

// Test with curl commands
const { exec } = require('child_process');
const util = require('util');
const execAsync = util.promisify(exec);

async function test() {
    try {
        // Register user1
        console.log('1. Registering user1...');
        const user1Reg = await execAsync(`curl -s -X POST http://localhost:3001/api/auth/register -H "Content-Type: application/json" -d '{"email":"user1@test.com","password":"password123"}'`);
        const user1Data = JSON.parse(user1Reg.stdout);
        console.log('✅ User1 registered:', user1Data.user.email);
        const token1 = user1Data.token;

        // Add word for user1
        console.log('2. Adding word for user1...');
        await execAsync(`curl -s -X POST http://localhost:3001/api/user/words -H "Content-Type: application/json" -H "Authorization: Bearer ${token1}" -d '{"term":"hello","translations":{"vi":"xin chào"},"example":"Hello world!"}'`);
        console.log('✅ Word added for user1');

        // Register user2
        console.log('3. Registering user2...');
        const user2Reg = await execAsync(`curl -s -X POST http://localhost:3001/api/auth/register -H "Content-Type: application/json" -d '{"email":"user2@test.com","password":"password123"}'`);
        const user2Data = JSON.parse(user2Reg.stdout);
        console.log('✅ User2 registered:', user2Data.user.email);
        const token2 = user2Data.token;

        // Check user2's words (should be empty)
        console.log('4. Checking user2 words (should be empty)...');
        const user2Words = await execAsync(`curl -s -X GET http://localhost:3001/api/user/words -H "Authorization: Bearer ${token2}"`);
        const user2WordsData = JSON.parse(user2Words.stdout);
        console.log(`✅ User2 has ${user2WordsData.words.length} words (should be 0)`);

        // Add different word for user2
        console.log('5. Adding word for user2...');
        await execAsync(`curl -s -X POST http://localhost:3001/api/user/words -H "Content-Type: application/json" -H "Authorization: Bearer ${token2}" -d '{"term":"goodbye","translations":{"vi":"tạm biệt"},"example":"Goodbye!"}'`);
        console.log('✅ Word added for user2');

        // Final check
        console.log('6. Final verification...');
        const user1Final = await execAsync(`curl -s -X GET http://localhost:3001/api/user/words -H "Authorization: Bearer ${token1}"`);
        const user2Final = await execAsync(`curl -s -X GET http://localhost:3001/api/user/words -H "Authorization: Bearer ${token2}"`);
        
        const user1FinalData = JSON.parse(user1Final.stdout);
        const user2FinalData = JSON.parse(user2Final.stdout);

        console.log(`User1 words: ${user1FinalData.words.map(w => w.term).join(', ')}`);
        console.log(`User2 words: ${user2FinalData.words.map(w => w.term).join(', ')}`);

        if (user1FinalData.words.length === 1 && user2FinalData.words.length === 1 &&
            user1FinalData.words[0].term === 'hello' && user2FinalData.words[0].term === 'goodbye') {
            console.log('\n🎉 SUCCESS: Users have separate word lists!');
        } else {
            console.log('\n❌ FAILED: Users are sharing words or counts are wrong');
        }

    } catch (error) {
        console.error('❌ Test failed:', error.message);
    }
}

test();
