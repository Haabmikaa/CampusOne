# CampusOne - Smart Campus Companion

## Overview
CampusOne is a smart campus platform built for students, lecturers, staff, and administrators. The project combines a Flutter mobile application with a Next.js admin dashboard so the university community can manage schedules, complaints, announcements, assignments, and campus services in one connected system.

## Platforms
- **Mobile App**: Used by students, lecturers, and staff.
- **Admin Dashboard**: Used by administrators for system-wide control and monitoring.

## Core Features
- **Authentication and Profile Setup**: Role-based access for student, lecturer, staff, and admin users.
- **Schedules and Academic Flow**: Class and exam schedules filtered by department, cohort, section, and group.
- **Complaint Management**: Complaint submission, assignment, tracking, and resolution workflow.
- **Announcements and Broadcasts**: Real-time campus communication for targeted or global audiences.
- **Workspace and Assignments**: Course materials, assignments, submissions, and lecturer follow-up.
- **Campus Assistant and Map**: AI-powered support plus campus navigation.

## Technical Stack
- **Mobile Framework**: Flutter
- **Web Framework**: Next.js
- **State Management**: Riverpod
- **Backend**: Firebase Authentication, Cloud Firestore, Firebase Storage
- **AI**: Google Gemini
- **Navigation**: GoRouter
- **Maps**: Flutter Map with OpenStreetMap

## User Flows

### Student Flow
Students use CampusOne to manage academics, campus information, and support services from one mobile experience.

#### Student Pages
- **Onboarding**: Introduces the platform when the app is opened for the first time.
- **Login and Register**: Provides secure account access and first-time registration.
- **Profile Setup**: Captures department, cohort, year, semester, section, and group for personalized data.
- **Home Dashboard**: Shows quick actions, upcoming classes, and recent announcements.
- **Schedule**: Displays class and exam schedules.
- **Announcements**: Lists academic and campus updates.
- **Workspace**: Gives access to courses, assignments, and submissions.
- **Complaints**: Lets students submit and track issues.
- **AI Assistant**: Answers campus-related questions.
- **Campus Map**: Helps students navigate the university environment.

#### Student Screenshots
<p align="center">
  <img src="screenshots/student/onboarding.jpg" alt="Student Onboarding" width="180">
  <img src="screenshots/student/login.jpg" alt="Student Login" width="180">
  <img src="screenshots/student/register.jpg" alt="Student Register" width="180">
  <img src="screenshots/student/home.jpg" alt="Student Home" width="180">
</p>
<p align="center">
  <img src="screenshots/student/schedule.jpg" alt="Student Schedule" width="180">
  <img src="screenshots/student/announcements.jpg" alt="Student Announcements" width="180">
  <img src="screenshots/student/workspace.jpg" alt="Student Workspace" width="180">
  <img src="screenshots/student/complaints.jpg" alt="Student Complaints" width="180">
</p>
<p align="center">
  <img src="screenshots/student/assistant.jpg" alt="Student Assistant" width="180">
  <img src="screenshots/student/map.jpg" alt="Student Map" width="180">
</p>

### Lecturer Flow
Lecturers use the mobile app to manage course delivery, academic communication, and student follow-up.

#### Lecturer Pages
- **Lecturer Dashboard**: Summarizes teaching activity and quick actions.
- **Workspace Overview**: Shows assigned courses and learning flow.
- **Course Management**: Opens course content and resources.
- **Assignment Management**: Creates and manages assignments for sections and groups.
- **Submissions**: Reviews student uploads and participation.
- **Announcements**: Publishes academic updates and reminders.
- **Notifications**: Surfaces lecturer alerts and actions that need attention.
- **Complaints**: Handles academic-related issues raised by students.
- **Profile**: Maintains lecturer information and account details.

#### Lecturer Screenshots
<p align="center">
  <img src="screenshots/lecturer/dashboard-main.jpg" alt="Lecturer Dashboard" width="180">
  <img src="screenshots/lecturer/dashboard-stats.jpg" alt="Lecturer Stats" width="180">
  <img src="screenshots/lecturer/workspace-overview.jpg" alt="Lecturer Workspace" width="180">
  <img src="screenshots/lecturer/course-management.jpg" alt="Course Management" width="180">
</p>
<p align="center">
  <img src="screenshots/lecturer/assignment-management.jpg" alt="Assignment Management" width="180">
  <img src="screenshots/lecturer/submissions.jpg" alt="Submissions" width="180">
  <img src="screenshots/lecturer/announcements.jpg" alt="Lecturer Announcements" width="180">
  <img src="screenshots/lecturer/notifications.jpg" alt="Lecturer Notifications" width="180">
</p>
<p align="center">
  <img src="screenshots/lecturer/complaints.jpg" alt="Lecturer Complaints" width="180">
  <img src="screenshots/lecturer/profile.jpg" alt="Lecturer Profile" width="180">
</p>

### Staff Flow
Staff members use CampusOne to receive assignments, resolve complaints, and stay updated on operational notices.

#### Staff Pages
- **Staff Dashboard**: Shows work areas and assigned activity.
- **Complaint Management**: Lets staff follow issue details and update progress.
- **Announcements**: Displays campus notices that affect operations.
- **Profile**: Maintains staff identity and notification visibility.

#### Staff Screenshots
<p align="center">
  <img src="screenshots/staff/home.jpg" alt="Staff Home" width="180">
  <img src="screenshots/staff/complaints.jpg" alt="Staff Complaints" width="180">
  <img src="screenshots/staff/announcements.jpg" alt="Staff Announcements" width="180">
  <img src="screenshots/staff/profile.jpg" alt="Staff Profile" width="180">
</p>

### Admin Flow
Administrators use the web dashboard to control users, campus schedules, complaints, broadcasts, and system settings.

#### Admin Pages
- **Admin Login**: Secures access to the dashboard.
- **Dashboard Overview**: Shows metrics and recent system activity.
- **User Management**: Manages students, staff, departments, and catalogs.
- **Schedules**: Publishes class and exam schedules.
- **Complaints**: Assigns and monitors service issues.
- **Broadcasts**: Sends global or targeted messages.
- **Assignments Setup**: Configures sections and groups.
- **Events and Tasks**: Tracks operational and campus activities.
- **Settings and Support**: Controls platform behavior and support access.

#### Admin Screenshots
<p align="center">
  <img src="screenshots/admin/login.png" alt="Admin Login" width="220">
  <img src="screenshots/admin/dashboard.png" alt="Admin Dashboard" width="220">
  <img src="screenshots/admin/users.png" alt="Admin Users" width="220">
</p>
<p align="center">
  <img src="screenshots/admin/schedules.png" alt="Admin Schedules" width="220">
  <img src="screenshots/admin/complaints.png" alt="Admin Complaints" width="220">
  <img src="screenshots/admin/broadcasts.png" alt="Admin Broadcasts" width="220">
</p>
<p align="center">
  <img src="screenshots/admin/assignments.png" alt="Admin Assignments" width="220">
  <img src="screenshots/admin/events-tasks.png" alt="Admin Events and Tasks" width="220">
  <img src="screenshots/admin/settings-support.png" alt="Admin Settings and Support" width="220">
</p>

## Setup Instructions
1. Place `google-services.json` in `android/app`.
2. Configure the required Firebase project settings for mobile and web.
3. Add the Gemini API key where required for the assistant flow.
4. Run `flutter pub get` in the project root.
5. Run the Flutter app with `flutter run`.
6. Run the admin panel from `admin_panel` with `npm install` and `npm run dev`.
