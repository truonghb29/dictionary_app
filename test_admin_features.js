const http = require('http');

const baseUrl = 'http://localhost:3001/api';

// Test admin login and admin features
async function testAdminFeatures() {
    console.log('🧪 Testing Admin Features...\n');

    try {
        // 1. Login as admin
        console.log('1️⃣ Testing admin login...');
        const loginResponse = await makeRequest('POST', '/auth/login', {
            email: 'admin@example.com',
            password: 'admin123'
        });

        if (loginResponse.success) {
            const { token, user } = loginResponse;
            console.log('   ✅ Admin login successful');
            console.log(`   👤 Role: ${user.role}`);
            console.log(`   🔑 Token received`);

            // 2. Test dashboard stats
            console.log('\n2️⃣ Testing dashboard stats...');
            const dashboardResponse = await makeRequest('GET', '/admin/dashboard', null, token);
            
            if (dashboardResponse.success) {
                console.log('   ✅ Dashboard stats retrieved');
                console.log(`   📊 Total Users: ${dashboardResponse.data.overview.totalUsers}`);
                console.log(`   📚 Total Words: ${dashboardResponse.data.overview.totalWords}`);
            } else {
                console.log('   ❌ Dashboard stats failed:', dashboardResponse.message);
            }

            // 3. Test analytics
            console.log('\n3️⃣ Testing analytics...');
            const analyticsResponse = await makeRequest('GET', '/admin/analytics?period=7d', null, token);
            
            if (analyticsResponse.success) {
                console.log('   ✅ Analytics retrieved');
                console.log(`   📈 Period: ${analyticsResponse.data.period}`);
            } else {
                console.log('   ❌ Analytics failed:', analyticsResponse.message);
            }

            // 4. Test users list
            console.log('\n4️⃣ Testing users list...');
            const usersResponse = await makeRequest('GET', '/admin/users?page=1&limit=5', null, token);
            
            if (usersResponse.success) {
                console.log('   ✅ Users list retrieved');
                console.log(`   👥 Users count: ${usersResponse.data.users.length}`);
                console.log(`   📄 Total pages: ${usersResponse.data.pagination.total}`);
            } else {
                console.log('   ❌ Users list failed:', usersResponse.message);
            }

            // 5. Test save analytics
            console.log('\n5️⃣ Testing save analytics...');
            const saveAnalyticsResponse = await makeRequest('POST', '/admin/analytics/save', null, token);
            
            if (saveAnalyticsResponse.success) {
                console.log('   ✅ Analytics saved successfully');
            } else {
                console.log('   ❌ Save analytics failed:', saveAnalyticsResponse.message);
            }

        } else {
            console.log('   ❌ Admin login failed:', loginResponse.message);
        }

        console.log('\n🎉 Admin testing completed!');

    } catch (error) {
        console.error('❌ Error during admin testing:', error.message);
    }
}

// Helper function to make HTTP requests
function makeRequest(method, endpoint, data = null, token = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 3001,
            path: `/api${endpoint}`,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                ...(token && { Authorization: `Bearer ${token}` })
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            
            res.on('data', (chunk) => {
                body += chunk;
            });
            
            res.on('end', () => {
                try {
                    const response = JSON.parse(body);
                    resolve(response);
                } catch (error) {
                    reject(new Error(`Failed to parse response: ${body}`));
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        if (data) {
            req.write(JSON.stringify(data));
        }

        req.end();
    });
}

// Run the test
testAdminFeatures();
