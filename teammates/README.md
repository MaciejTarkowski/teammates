# teammates

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running the Application

This application requires Supabase URL and Anon Key to run. These values must be passed as Dart defines during `flutter run` or `flutter build`.

1.  **Get your Supabase credentials:**
    *   Go to your Supabase project dashboard.
    *   Navigate to `Project Settings` -> `API`.
    *   Copy your `Project URL` and `anon public` key.

2.  **Run in Debug Mode (on emulator/device):**
    Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with your actual credentials.
    ```bash
    flutter run \
      --dart-define=SUPABASE_URL='YOUR_SUPABASE_URL' \
      --dart-define=SUPABASE_ANON_KEY='YOUR_SUPABASE_ANON_KEY' \
      -d emulator-5554 # Or your preferred device ID
    ```

3.  **Build for Release:**
    ```bash
    flutter build apk \
      --dart-define=SUPABASE_URL='YOUR_SUPABASE_URL' \
      --dart-define=SUPABASE_ANON_KEY='YOUR_SUPABASE_ANON_KEY'
    ```
    (Replace `apk` with `ios`, `appbundle`, `web`, etc., as needed.)

## Database Setup

This project requires specific database schema and functions. Please ensure you have applied all SQL scripts located in the `database/scripts/` directory to your Supabase project. These scripts include:

*   `001_create_log_error_function.sql`
*   `002_create_get_my_events_function.sql`
*   `003_create_profiles_table.sql` (updated)
*   `004_create_new_user_trigger.sql` (updated)
*   `005_create_attendance_table_and_trigger.sql`
*   `006_create_get_participants_function.sql` (updated)
*   `007_get_profile_with_email.sql` (updated)

You can apply these scripts using the SQL Editor in your Supabase dashboard.