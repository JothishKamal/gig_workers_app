# Gig Workers Task Management App

A robust, production-ready Task Management application built with Flutter, designed for Gig Workers to organize their daily tasks efficiently.

## Features

### Core Functionality

* **User Authentication**: Secure Login and Sign Up using **Firebase Authentication**.
* **Task Management**: Create, Read, Update, and Delete (CRUD) tasks.
* **Real-time & Offline**: Powered by **Cloud Firestore** with **Offline Persistence** enabled.
* **Optimistic UI**: Instant interactions (Add, Delete, Update) with automatic background sync and exponential backoff for network retries.

### User Experience (UX)

* **Animations**:
  * **Smooth Page Transitions**: Custom Slide+Fade effects between screens.
  * **Staggered Lists**: Tasks cascade gently into view.
  * **Interactive Elements**: Animated Theme Toggle (Sun/Moon rotation).
* **Gestures**:
  * **Swipe Right**: Mark as Complete (Green Check).
  * **Swipe Left**: Delete Task (Red Circle).
* **Theming**: Seamless **Dark/Light Mode** toggle with persistent state.

### Organization

* **Filtering**: Filter tasks by Priority (High/Medium/Low) or Status (Completed).
* **Searching**: Real-time search by task title or description.
* **Sorting**: Tasks are automatically sorted by Due Date (Earliest to Latest).

## Technology Stack

* **Framework**: [Flutter](https://flutter.dev/)
* **Language**: Dart
* **State Management**: [Riverpod](https://riverpod.dev/) (Providers, StateNotifiers)
* **Architecture**: **Clean Architecture** (Presentation, Domain, Data layers)
* **Backend**:
  * Firebase Authentication
  * Cloud Firestore
* **Routing**: [GoRouter](https://pub.dev/packages/go_router)
* **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
* **Utils**: `equatable`, `intl`, `uuid`, `gap`, `google_fonts`.

## Project Structure

The project follows a strict Clean Architecture pattern:

```
lib/
├── core/                   # Global utilities, theme, errors, usecases
├── features/
│   ├── auth/               # Authentication Feature
│   │   ├── data/           # Repositories & Data Sources
│   │   ├── domain/         # Entities & UseCases
│   │   └── presentation/   # Pages (Login/Signup) & Providers
│   ├── tasks/              # Task Management Feature
│   │   ├── data/           # Repositories & Data Sources
│   │   ├── domain/         # Entities & UseCases (Get, Add, Update, Delete)
│   │   └── presentation/   # Pages (List, Add/Edit), Widgets (TaskItem), Providers
├── main.dart               # App Entry point & Global Config
```

## Getting Started

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
* [Firebase CLI](https://firebase.google.com/docs/cli) installed and logged in.

### Installation

1. **Clone the repository**:

    ```bash
    git clone https://github.com/yourusername/gig_workers_app.git
    cd gig_workers_app
    ```

2. **Install Dependencies**:

    ```bash
    flutter pub get
    ```

3. **Firebase Setup**:

   #### Option A: Quick Setup (Automated)

    If you have Firebase CLI installed:

    ```bash
    npm install -g firebase-tools
    firebase login
    flutterfire configure
    ```

    This will automatically generate `lib/firebase_options.dart`.

   #### Option B: Manual Setup (Using Your Own Firebase Project)

    1. **Create a Firebase Project**:
       * Go to [Firebase Console](https://console.firebase.google.com/)
       * Click "Add Project" and follow the setup wizard

    2. **Add Apps to Your Firebase Project**:
       * **For Android**:
         * Click "Add App" → Select Android
         * Register app with package name: `com.example.gig_workers_app`
         * Download `google-services.json`
         * Place it in `android/app/` directory

       * **For iOS** (if needed):
         * Click "Add App" → Select iOS
         * Register app with bundle ID: `com.example.gigWorkersApp`
         * Download `GoogleService-Info.plist`
         * Place it in `ios/Runner/` directory

    3. **Enable Firebase Services**:
       * **Authentication**:
         * Go to Authentication → Sign-in method
         * Enable "Email/Password" provider

       * **Firestore Database**:
         * Go to Firestore Database → Create database
         * Start in **Production mode** (recommended) or Test mode
         * Choose a location closest to your users
         * **Important**: Create a composite index for queries:
           * Collection: `tasks`
           * Fields: `userId` (Ascending), `dueDate` (Ascending)
           * Or wait for the error in console and click the provided link

       * **Firestore Rules** (For production):

         ```javascript
         rules_version = '2';
         service cloud.firestore {
           match /databases/{database}/documents {
             match /tasks/{taskId} {
               allow read, write: if request.auth != null && 
                                     request.auth.uid == resource.data.userId;
               allow create: if request.auth != null && 
                                request.auth.uid == request.resource.data.userId;
             }
           }
         }
         ```

    4. **Generate Flutter Configuration** (if using manual setup):

       ```bash
       flutterfire configure
       ```

       Select your existing Firebase project from the list.

    > **Note**: The `google-services.json` and `GoogleService-Info.plist` files are already in `.gitignore` to prevent accidental commits.

4. **Run the App**:

    ```bash
    flutter run
    ```

## Screenshots

| Login Page | Task List (Dark) | Add Task (Light) |
|:---:|:---:|:---:|
| <img src="https://github.com/JothishKamal/gig_workers_app/blob/main/screenshots/login.png?raw=true" width="200" height="400"> | <img src="https://github.com/JothishKamal/gig_workers_app/blob/main/screenshots/task_list.png?raw=true" width="200" height="400"> | <img src="https://github.com/JothishKamal/gig_workers_app/blob/main/screenshots/add_task.png?raw=true" width="200" height="400"> |
