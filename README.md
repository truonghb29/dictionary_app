# Dictionary App - Backend Integration Guide

This Flutter dictionary app now includes a complete backend API built with Node.js, Express, and MongoDB for user authentication and cloud-based word storage.

## 🚀 Backend Features

- **User Authentication**: Register and login with email/password
- **JWT Token-based Security**: Secure API endpoints with JWT tokens
- **Cloud Word Storage**: Store and sync your dictionary words across devices
- **MongoDB Integration**: Reliable data persistence with MongoDB
- **RESTful API**: Clean and well-documented API endpoints

## 📋 Prerequisites

Before running the application, ensure you have the following installed:

- **Flutter SDK** (>=3.7.0)
- **Node.js** (>=16.0.0)
- **MongoDB** (local installation or MongoDB Atlas account)
- **iOS Simulator** or **Android Emulator** for testing

## 🛠 Setup Instructions

### 1. Backend Setup

#### Install Dependencies
```bash
cd backend
npm install
```

#### Configure Environment Variables
The backend uses a `.env` file for configuration. Update the following variables:

```env
# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/dictionary_app
# For MongoDB Atlas: mongodb+srv://username:password@cluster.mongodb.net/dictionary_app

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here_change_this_in_production

# Server Configuration
PORT=3001
NODE_ENV=development

# CORS Configuration
CORS_ORIGIN=http://localhost:3001,http://127.0.0.1:3001
```

#### Start MongoDB (if using local installation)
```bash
# Using Homebrew on macOS
brew services start mongodb-community

# Or start manually
mongod --config /usr/local/etc/mongod.conf
```

#### Start the Backend Server
```bash
cd backend
npm run dev
```

The server will start on `http://localhost:3001` and you should see:
```
🚀 Server running on port 3001
📱 Environment: development
🔗 Health check: http://localhost:3001/api/health
MongoDB Connected: localhost
```

### 2. Flutter App Setup

#### Install Dependencies
```bash
flutter pub get
```

#### Run the App
```bash
flutter run
```

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies
   ```bash
   flutter pub get
   ```
4. Run the app
   ```bash
   flutter run
   ```

## Usage

### Adding a New Word

1. Tap the + button in the bottom right corner
2. Enter the word
3. Add translations in different languages
4. Optionally, add an example sentence
5. Tap "Save Word"

### Editing a Word

1. Find the word in the list
2. Tap the edit (pencil) icon
3. Make your changes
4. Tap "Save Word"

### Deleting a Word

1. Find the word in the list
2. Tap the delete (trash) icon
3. Confirm deletion

### Searching

1. Tap the search icon in the app bar
2. Enter your search term
3. The app will search through all words and translations
