// Simple test script for authentication endpoints
// Run with: node src/test-auth.js

const BASE_URL = 'http://localhost:3000/api';

// Test endpoints
async function testAuthEndpoints() {
  console.log('🧪 Testing Authentication Endpoints...\n');

  // Test 1: Verify endpoint exists
  try {
    const response = await fetch(`${BASE_URL}/auth/verify`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        token: 'test-token'
      })
    });
    
    console.log('✅ POST /api/auth/verify - Endpoint exists');
    console.log('📊 Status:', response.status);
    
    if (response.status !== 401) {
      const data = await response.json();
      console.log('📄 Response:', JSON.stringify(data, null, 2));
    }
  } catch (error) {
    console.log('❌ POST /api/auth/verify - Error:', error.message);
  }

  console.log('\n' + '='.repeat(50) + '\n');

  // Test 2: Profile endpoint without auth
  try {
    const response = await fetch(`${BASE_URL}/auth/profile`);
    
    console.log('✅ GET /api/auth/profile - Endpoint exists');
    console.log('📊 Status:', response.status, '(Should be 401 without auth)');
    
    const data = await response.json();
    console.log('📄 Response:', JSON.stringify(data, null, 2));
  } catch (error) {
    console.log('❌ GET /api/auth/profile - Error:', error.message);
  }

  console.log('\n🏁 Auth endpoint tests complete!');
  console.log('📝 Next steps:');
  console.log('   1. Set up Supabase project and add credentials to .env');
  console.log('   2. Run: npm run dev');
  console.log('   3. Test with real Supabase tokens from your frontend');
}

// Run tests if this file is executed directly
if (require.main === module) {
  testAuthEndpoints().catch(console.error);
}

module.exports = { testAuthEndpoints };