# Campus Reports Campus Incident Reporting App

Flutter app where students report campus issues (facilities, water, electricity,
safety, sanitation) and authorized staff review them and update their status.

## Tech
- Flutter + Riverpod (Notifier / AsyncNotifier / StreamProvider)
- Firebase Authentication (email + password)
- Cloud Firestore (users, incidents, incidents/{id}/statusHistory)
- Firebase Storage (incident photos)

## Architecture
```
lib/
  core/          theme, utils, reusable widgets
  models/        AppUser, Incident, StatusEntry
  repositories/  AuthRepository, IncidentRepository (only layer touching Firebase)
  providers/     Riverpod providers + controllers (state management)
  screens/       auth, home (student), staff, incidents, profile, shared
```
UI -> providers/controllers -> repositories -> Firebase.

## Roles
- `student` (default on registration): create reports, view own reports.
- `staff`: view all reports, update status. Granted by editing `users/{uid}.role`
  to `staff` in the Firebase console. Enforced by `firestore.rules`.

## Setup
1. `flutter pub get`
2. `dart pub global activate flutterfire_cli && flutterfire configure`
3. Enable Email/Password sign-in, create Firestore + Storage in the Firebase console.
4. Deploy `firestore.rules` and `storage.rules` (console Rules tab or `firebase deploy --only firestore:rules,storage`).
5. `flutter run` on an emulator or device.

## Tests
`flutter test`
