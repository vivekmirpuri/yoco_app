# Yoco Firebase Studio

A comprehensive Flutter application that demonstrates Firebase integration for creative project management and asset organization. This app showcases various Firebase services including Authentication, Firestore, Storage, and Analytics.

## 🚀 Features

### 🔐 Authentication
- Email/password authentication
- User registration and login
- Profile management with photo upload
- Secure sign-out functionality

### 📁 Project Management
- Create, edit, and delete projects
- Project categorization and tagging
- Project status tracking (active, archived, draft, completed)
- Search and filter projects

### 🎨 Asset Management
- Upload various file types (images, videos, audio, documents)
- Asset organization by project
- File type detection and categorization
- Asset metadata tracking
- Grid and list view options

### 📊 Analytics Dashboard
- Project performance metrics
- Asset distribution statistics
- Storage usage tracking
- Recent activity feed
- Time-based filtering

### 🛠️ Studio Tools
- Photo editor integration
- Video editor tools
- Audio editing capabilities
- Design tools
- Settings and configuration

### 📱 Modern UI/UX
- Material Design 3 implementation
- Responsive design
- Dark/light theme support
- Smooth animations and transitions
- Intuitive navigation

## 🏗️ Architecture

### Services
- **AuthService**: Handles Firebase Authentication
- **FirestoreService**: Manages Firestore database operations
- **StorageService**: Handles Firebase Storage operations

### Models
- **Project**: Project data model with metadata
- **Asset**: Asset data model with file information

### Screens
- **LoginScreen**: Authentication interface
- **HomeScreen**: Dashboard with quick actions
- **StudioScreen**: Project and asset management
- **AnalyticsScreen**: Statistics and metrics
- **ProfileScreen**: User profile and settings

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Firebase project with the following services enabled:
  - Authentication
  - Firestore Database
  - Storage
  - Analytics

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd yoco_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Storage, and Analytics
   - Download the Firebase configuration files
   - Update the Firebase configuration in `lib/main.dart`

4. **Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users can only access their own data
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Users can only access their own projects
       match /projects/{projectId} {
         allow read, write: if request.auth != null && 
           resource.data.userId == request.auth.uid;
       }
       
       // Users can only access assets from their projects
       match /assets/{assetId} {
         allow read, write: if request.auth != null && 
           resource.data.userId == request.auth.uid;
       }
       
       // Analytics data
       match /analytics/{docId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Storage Security Rules**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       // Users can only access their own files
       match /users/{userId}/{allPaths=**} {
         allow read, write: if request.auth != null && 
           request.auth.uid == userId;
       }
       
       // Project assets
       match /projects/{projectId}/{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

6. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Usage

### Getting Started
1. Launch the app and create an account or sign in
2. Create your first project from the home screen
3. Upload assets to your projects
4. Explore the analytics dashboard
5. Customize your profile and settings

### Project Management
- **Create Projects**: Use the "New Project" quick action or the + button in the Studio tab
- **Organize Assets**: Upload files and organize them by project
- **Track Progress**: Monitor project status and asset counts
- **Search**: Use the search bar to find specific projects

### Asset Management
- **Upload Files**: Support for images, videos, audio, and documents
- **View Assets**: Grid view with thumbnails and metadata
- **Filter Assets**: Filter by file type within projects
- **Asset Details**: Tap assets to view details and options

## 🔧 Configuration

### Environment Variables
The app uses Firebase configuration that should be updated in `lib/main.dart`:

```dart
FirebaseOptions(
  apiKey: "your-api-key",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "your-sender-id",
  appId: "your-app-id",
  measurementId: "your-measurement-id",
)
```

### Customization
- **Theme**: Modify colors and styling in `lib/main.dart`
- **Features**: Enable/disable features in the service classes
- **UI**: Customize widgets and screens as needed

## 📊 Firebase Services Used

### Authentication
- Email/password authentication
- User profile management
- Secure session handling

### Firestore
- User profiles and settings
- Project data and metadata
- Asset information and metadata
- Analytics event logging

### Storage
- Profile picture uploads
- Project asset storage
- File organization by user and project

### Analytics
- User engagement tracking
- Feature usage analytics
- Custom event logging

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
firebase deploy
```

### Mobile Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the Firebase documentation
- Review Flutter documentation

## 🔮 Future Enhancements

- [ ] Real-time collaboration features
- [ ] Advanced editing tools
- [ ] Cloud rendering capabilities
- [ ] AI-powered asset tagging
- [ ] Advanced analytics and reporting
- [ ] Mobile-specific optimizations
- [ ] Offline support
- [ ] Multi-language support

---

**Built with ❤️ using Flutter and Firebase**
