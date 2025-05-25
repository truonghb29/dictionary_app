#!/usr/bin/env node

// Simple test script to verify backend authentication works
const http = require('http');
const https = require('https');

const baseUrl = 'http://localhost:3001/api';

// Test registration
async function testRegistration() {
    return new Promise((resolve, reject) => {
        const testEmail = `test${Date.now()}@example.com`;
        const testPassword = 'testpassword123';

        const data = JSON.stringify({
            email: testEmail,
            password: testPassword
        });

        const options = {
            hostname: 'localhost',
            port: 3001,
            path: '/api/auth/register',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        };

        const req = http.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                try {
                    const parsed = JSON.parse(responseData);
                    console.log('✅ Registration Test:', parsed.success ? 'PASSED' : 'FAILED');
                    console.log('   Response:', parsed.message);
                    if (parsed.token) {
                        console.log('   Token received:', parsed.token.substring(0, 20) + '...');
                    }
                    resolve(parsed);
                } catch (error) {
                    console.log('❌ Registration Test: FAILED - Invalid JSON response');
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.log('❌ Registration Test: FAILED - Network error');
            console.log('   Error:', error.message);
            reject(error);
        });

        req.write(data);
        req.end();
    });
}

// Test health endpoint
async function testHealth() {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 3001,
            path: '/api/health',
            method: 'GET'
        };

        const req = http.request(options, (res) => {
            let responseData = '';

            res.on('data', (chunk) => {
                responseData += chunk;
            });

            res.on('end', () => {
                try {
                    const parsed = JSON.parse(responseData);
                    console.log('✅ Health Check Test:', parsed.success ? 'PASSED' : 'FAILED');
                    console.log('   Server Status:', parsed.message);
                    console.log('   Environment:', parsed.environment);
                    resolve(parsed);
                } catch (error) {
                    console.log('❌ Health Check Test: FAILED - Invalid JSON response');
                    reject(error);
                }
            });
        });

        req.on('error', (error) => {
            console.log('❌ Health Check Test: FAILED - Network error');
            console.log('   Error:', error.message);
            reject(error);
        });

        req.end();
    });
}

async function runTests() {
    console.log('🧪 Testing Dictionary App Backend...\n');

    try {
        await testHealth();
        console.log('');
        await testRegistration();
        console.log('\n✅ All tests completed!');
    } catch (error) {
        console.log('\n❌ Test suite failed:', error.message);
    }
}

runTests();
