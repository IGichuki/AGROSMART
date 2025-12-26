
# AGROSMART – Onion Farm Monitor

AGROSMART is a modern Flutter mobile application designed for onion farm monitoring, featuring Firebase integration, role-based authentication, and a user-friendly dashboard for both farmers and admins.

## Features Implemented

- **Flutter + Firebase Integration**
  - Firebase Auth (email/password)
  - Cloud Firestore (user data)
- **Role-Based Login**
  - Separate dashboards for Admin and Farmer roles
- **2-Step Verification**
  - Email verification during registration
- **Modern User Dashboard**
  - Custom navigation bar and reusable dashboard scaffold
  - Pages: Dashboard, Analytics, Irrigation, Settings, Profile
  - Navigation between pages with persistent user info
- **Admin Dashboard**
  - Admin-specific features and management tools
- **Custom App Icon**
  - Agricultural theme icon set via `flutter_launcher_icons`
- **UI/UX**
  - Clean, modern design with consistent theming
  - FontAwesome icons for visual clarity

## Project Structure

- `lib/main.dart` – App entry, routing, and theme
- `lib/screens/` – All major screens (login, signup, dashboards, analytics, etc.)
- `lib/widgets/` – Reusable widgets (e.g., custom text fields)
- `assets/` – App icon and images

## Getting Started

1. **Install dependencies:**
   ```sh
   flutter pub get
   ```
2. **Run the app:**
   ```sh
   flutter run
   ```
3. **Firebase setup:**
   - Ensure your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place.

## How It Works

- **Login/Signup:** Users register and log in with email/password. 2-step verification is enforced.
- **Role Selection:** On login, users are routed to either the Admin or Farmer dashboard based on their role in Firestore.
- **Dashboard Navigation:** Users can switch between Dashboard, Analytics, Irrigation, Settings, and Profile pages. Navigation preserves user info (e.g., last name).
- **Admin Dashboard:** Admins can manage farmers, configure thresholds, and view analytics.

## Dependencies
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `font_awesome_flutter`
- `flutter_launcher_icons`

## To Do / Next Steps
- Add more analytics and irrigation features
- Enhance profile management
- Add push notifications
- Polish UI and add more widgets

---

*This README reflects the current state of the project as of August 29, 2025. Update as new features are added!*
