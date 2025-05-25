# Dictionary App Backend

A Node.js/Express backend with MongoDB for the Flutter Dictionary App.

## Prerequisites

- Node.js (v16 or higher)
- MongoDB (local installation or MongoDB Atlas)
- npm or yarn

## Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
   - Copy `.env.example` to `.env` if needed
   - Update the MongoDB connection string
   - Generate a secure JWT secret

## MongoDB Setup Options

### Option 1: Local MongoDB
1. Install MongoDB locally
2. Start MongoDB service:
   ```bash
   brew services start mongodb/brew/mongodb-community
   ```
3. Use connection string: `mongodb://localhost:27017/dictionary_app`

### Option 2: MongoDB Atlas (Cloud)
1. Create account at https://www.mongodb.com/atlas
2. Create a new cluster
3. Get connection string and update `.env`
4. Example: `mongodb+srv://username:password@cluster.mongodb.net/dictionary_app`

## Running the Server

### Development (with auto-restart):
```bash
npm run dev
```

### Production:
```bash
npm start
```

The server will run on http://localhost:3000

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile (protected)
- `POST /api/auth/reset-password` - Reset password

### Dictionary
- `GET /api/dictionary/words` - Get all words for user (protected)
- `POST /api/dictionary/words` - Add new word (protected)
- `PUT /api/dictionary/words` - Bulk save words (protected)
- `DELETE /api/dictionary/words` - Delete word (protected)

### Health Check
- `GET /api/health` - Server health status

## Environment Variables

```
MONGODB_URI=mongodb://localhost:27017/dictionary_app
JWT_SECRET=your_super_secret_jwt_key_here
PORT=3000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000,http://127.0.0.1:3000
```

## Database Schema

### User Model
- email (String, unique, required)
- password (String, hashed, required)
- createdAt (Date)
- lastLogin (Date)

### Word Model
- term (String, required)
- translations (Map of String to String)
- example (String)
- userId (ObjectId, reference to User)
- createdAt (Date)
- updatedAt (Date)

## Flutter App Integration

Make sure your Flutter app's `AuthService` points to the correct backend URL:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For Android emulator, use:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

For iOS simulator, use:
```dart
static const String baseUrl = 'http://127.0.0.1:3000/api';
```
