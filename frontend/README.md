# ShortLab frontend

ShortLab's Flutter Web client. It includes a responsive landing page, account
registration and login, and URL management.

## Run locally

From this directory:

```sh
flutter pub get
flutter run -d chrome
```

During development, the API base URL defaults to `http://localhost:8080`. To
use another backend URL, provide it at build/run time:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

Registration uses `POST /api/auth/register` and can be followed immediately by
login using `POST /api/auth/login`. The JWT is held only in memory and is lost
when the browser page reloads; it is not written to browser storage.

For a release build, set `API_BASE_URL` to the deployed backend URL:

```sh
flutter build web --dart-define=API_BASE_URL=https://your-backend.example
```

Do not put backend credentials or secrets in this frontend configuration.

## Validate

```sh
flutter analyze
flutter test
flutter build web
```
