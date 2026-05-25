# CampusOne - Smart Campus Companion

## Overview
CampusOne is a premium, production-grade Flutter application designed to be the ultimate companion for university students. It integrates campus management systems, real-time data, and AI-driven assistance into a single, cohesive experience.

## Feature Modules
- **Home Dashboard**: Live personalized stats (classes today, pending issues) and latest announcements.
- **Complaint Management**: Multi-step submission form with media support and real-time status tracking.
- **AI Assistant**: Personalized campus assistant powered by Google Gemini.
- **Smart Schedule**: Real-time timetable synchronized with the student's ID.
- **Interactive Map**: Campus navigation with building markers and geolocation support.
- **Admin Panel**: System-wide analytics and management tools.
- **Staff Directory**: Live-searchable staff contact database.

## Technical Stack
- **Framework**: Flutter (Material 3)
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Generative AI (Gemini)
- **Maps**: Flutter Map (OpenStreetMap)
- **Navigation**: GoRouter (Listenable-based refresh)

## Setup Instructions
1. Ensure `google-services.json` is in the `android/app` directory.
2. Ensure `YOUR_GEMINI_API_KEY` is set in `assistant_screen.dart`.
3. Run `flutter pub get`.
4. Run `flutter run`.
