# Campus Reports Campus Incident Reporting App

Flutter app where students report campus issues (facilities, water, electricity,
safety, sanitation) and authorized staff review them and update their status.

## Tech
- Flutter + Riverpod (Notifier / AsyncNotifier / StreamProvider)
- Firebase Authentication (email + password)
- Cloud Firestore (users, incidents, incidents/{id}/statusHistory)
- Cloudinary (incident photos, unsigned uploads; the image URL is stored in Firestore)

## Why Cloudinary instead of Firebase Storage
Firebase Storage now requires the paid Blaze plan with a payment card. The course
facilitator approved using another cloud service for image storage, so photos are
uploaded to Cloudinary's free plan and only the returned HTTPS URL is saved in the
incident document.

## Architecture
```
lib/
  core/          theme, config, utils, reusable widgets
  models/        AppUser, Incident, StatusEntry
  repositories/  AuthRepository, IncidentRepository (Firebase data access)
  services/      ImageUploadService (Cloudinary upload)
  providers/     Riverpod providers + controllers (state management)
  screens/       auth, home (student), staff, incidents, profile, shared
```
UI -> providers/controllers -> repositories/services -> Firebase / Cloudinary.

## Roles
- `student` (default on registration): create reports, view own reports.
- `staff`: view all reports, update status. Granted by editing `users/{uid}.role`
  to `staff` in the Firebase console. Enforced by `firestore.rules`.

## Setup
1. `flutter pub get`
2. `dart pub global activate flutterfire_cli && flutterfire configure`
3. Enable Email/Password sign-in and create Firestore in the Firebase console.
4. Publish `firestore.rules` in the Firestore Rules tab.
5. Create a free Cloudinary account, add an **unsigned** upload preset, and put the
   cloud name and preset name in `lib/core/config.dart`.
6. `flutter run` on an emulator or device.

## Tests
`flutter test`
