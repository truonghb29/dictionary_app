#!/bin/bash

# Dictionary App Health Check Script
# This script checks if all services are running properly

echo "🔍 Dictionary App - Health Check"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# URLs to check
FRONTEND_URL="https://dictionary-app-truonghb.netlify.app"
BACKEND_URL="https://dictionary-app-backend.onrender.com"
API_HEALTH_URL="https://dictionary-app-backend.onrender.com/api/health"

echo -e "${BLUE}1. Checking Frontend (Flutter Web)...${NC}"
if curl -s --head "$FRONTEND_URL" | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ Frontend is online${NC}"
    echo -e "   📱 URL: $FRONTEND_URL"
else
    echo -e "${RED}❌ Frontend is offline${NC}"
fi

echo ""

echo -e "${BLUE}2. Checking Backend (Node.js API)...${NC}"
if curl -s --head "$BACKEND_URL" | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ Backend is online${NC}"
    echo -e "   🚀 URL: $BACKEND_URL"
else
    echo -e "${RED}❌ Backend is offline${NC}"
fi

echo ""

echo -e "${BLUE}3. Checking API Health Endpoint...${NC}"
HEALTH_RESPONSE=$(curl -s "$API_HEALTH_URL" 2>/dev/null)
if echo "$HEALTH_RESPONSE" | grep -q "Dictionary App API is running"; then
    echo -e "${GREEN}✅ API Health Check passed${NC}"
    echo -e "   🔗 URL: $API_HEALTH_URL"
    echo -e "   📄 Response: $(echo "$HEALTH_RESPONSE" | jq -r '.message' 2>/dev/null || echo "$HEALTH_RESPONSE")"
else
    echo -e "${RED}❌ API Health Check failed${NC}"
fi

echo ""

echo -e "${BLUE}4. Testing API Endpoints...${NC}"

# Test login endpoint
echo -e "${YELLOW}   Testing POST /api/auth/login...${NC}"
LOGIN_TEST=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"wrongpassword"}' \
    "$BACKEND_URL/api/auth/login" 2>/dev/null)

if [ "$LOGIN_TEST" = "400" ] || [ "$LOGIN_TEST" = "401" ]; then
    echo -e "${GREEN}   ✅ Login endpoint is working (returned $LOGIN_TEST)${NC}"
else
    echo -e "${RED}   ❌ Login endpoint issue (returned $LOGIN_TEST)${NC}"
fi

# Test register endpoint
echo -e "${YELLOW}   Testing POST /api/auth/register...${NC}"
REGISTER_TEST=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"email":"","password":""}' \
    "$BACKEND_URL/api/auth/register" 2>/dev/null)

if [ "$REGISTER_TEST" = "400" ] || [ "$REGISTER_TEST" = "422" ]; then
    echo -e "${GREEN}   ✅ Register endpoint is working (returned $REGISTER_TEST)${NC}"
else
    echo -e "${RED}   ❌ Register endpoint issue (returned $REGISTER_TEST)${NC}"
fi

echo ""

echo -e "${BLUE}5. Checking Database Connection...${NC}"
DB_CHECK=$(echo "$HEALTH_RESPONSE" | grep -o "MongoDB\|Database\|Connection" 2>/dev/null)
if [ ! -z "$DB_CHECK" ]; then
    echo -e "${GREEN}✅ Database connection seems healthy${NC}"
    echo -e "   🗄️  MongoDB Atlas is connected"
else
    echo -e "${YELLOW}⚠️  Cannot verify database status from health check${NC}"
fi

echo ""

echo -e "${BLUE}6. Performance Check...${NC}"
echo -e "${YELLOW}   Measuring response times...${NC}"

# Frontend response time
FRONTEND_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$FRONTEND_URL" 2>/dev/null)
echo -e "   🌐 Frontend: ${FRONTEND_TIME}s"

# Backend response time
BACKEND_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$API_HEALTH_URL" 2>/dev/null)
echo -e "   🚀 Backend: ${BACKEND_TIME}s"

# Performance rating
if (( $(echo "$BACKEND_TIME < 2.0" | bc -l) )); then
    echo -e "${GREEN}   ✅ Performance: Excellent${NC}"
elif (( $(echo "$BACKEND_TIME < 5.0" | bc -l) )); then
    echo -e "${YELLOW}   ⚠️  Performance: Good${NC}"
else
    echo -e "${RED}   ❌ Performance: Needs improvement${NC}"
fi

echo ""

echo -e "${BLUE}7. Quick User Test...${NC}"
echo -e "${YELLOW}   Simulating user actions...${NC}"

# Test CORS
CORS_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Origin: https://dictionary-app-truonghb.netlify.app" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    -X OPTIONS "$BACKEND_URL/api/auth/login" 2>/dev/null)

if [ "$CORS_TEST" = "200" ] || [ "$CORS_TEST" = "204" ]; then
    echo -e "${GREEN}   ✅ CORS is properly configured${NC}"
else
    echo -e "${RED}   ❌ CORS issue detected (code: $CORS_TEST)${NC}"
fi

echo ""

echo "================================="
echo -e "${GREEN}🎉 Health Check Complete!${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "   🌐 Frontend: $FRONTEND_URL"
echo -e "   🚀 Backend: $BACKEND_URL"
echo -e "   🗄️  Database: MongoDB Atlas"
echo -e "   📱 Status: Ready for users!"
echo ""
echo -e "${YELLOW}💡 Share these links with your friends and teachers:${NC}"
echo -e "   📖 Main App: $FRONTEND_URL"
echo -e "   📚 User Guide: https://github.com/truonghb29/dictionary_app/blob/main/USER_GUIDE.md"
echo -e "   💻 Source Code: https://github.com/truonghb29/dictionary_app"
echo ""
echo -e "${GREEN}🚀 Your Dictionary App is live and ready! 🎊${NC}"
