/// PhotoSync Configuration
///
/// Set [useLocalBackend] to `true` to connect to a backend running on your local
/// network (laptop). Your phone/other devices must be on the same WiFi network.
///
/// When `useLocalBackend` is `true`:
///   - Set [localHost] to your laptop's local IP address (e.g., '192.168.1.100')
///   - The app will use `http://[localHost]:8000` as the backend base URL
///
/// When `useLocalBackend` is `false`:
///   - The app will use the production Render-hosted backend
///
/// To find your laptop's local IP:
///   - Windows: Open CMD and run `ipconfig` -> look for "IPv4 Address"
///   - macOS/Linux: Run `ifconfig` or `ip addr` in terminal
///
/// IMPORTANT: The backend server must be running with `--host 0.0.0.0`
///   so it accepts connections from other devices on your network.
///   Run: `cd backend && uvicorn main:app --host 0.0.0.0 --port 8000 --reload`
// Quick top-level config values used by the app and by api.dart
const bool useLocalBackend = true; // set to false to use production backend
const String localHost = '192.168.1.76'; // replace with your PC IPv4 when using a phone - DEFAULT: use localhost for web/desktop
const String prodHost = 'https://photosync-4pj7.onrender.com';

String get apiBase => useLocalBackend ? 'http://$localHost:8000' : prodHost;

/// Connection timeout configuration
const Duration connectionTimeout = Duration(seconds: 30); // Increased from 15s for slower networks

class AppConfig {
  /// Set to `true` to use the local backend, `false` for production (Render)
  static const bool useLocalBackend = true;

  /// Your laptop's local IP address (only used when [useLocalBackend] is true)
  /// Use '192.168.1.76' for local development (web/desktop).
  /// When using a phone, replace with your laptop's actual IPv4 address from `ipconfig`/`ifconfig`.
  static const String localHost = '192.168.1.76';

  /// Production backend URL (Render)
  static const String productionUrl = 'https://photosync-4pj7.onrender.com';

  /// Computed base URL based on configuration
  static String get baseUrl {
    if (useLocalBackend) {
      return 'http://$localHost:8000';
    }
    return productionUrl;
  }
}
