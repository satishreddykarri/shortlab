# ShortLab frontend

ShortLab's Flutter Web client. It currently includes a responsive landing page,
account registration, and email verification. Login and URL management will be
added in later steps.

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

Registration and email verification use the Go backend routes
`POST /api/auth/register` and `POST /api/auth/verify-email`.
Login uses `POST /api/auth/login`. The JWT is held only in memory and is lost
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
