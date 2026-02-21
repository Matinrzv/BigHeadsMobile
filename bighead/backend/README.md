# BigHeads Realtime Backend

This backend is a pure-Dart HTTP + WebSocket server with file persistence.

## Run

```bash
cd bighead
dart run backend/server.dart 8080
```

## Endpoints

- `POST /auth/register`
- `POST /auth/login`
- `GET /users/find?email=...`
- `POST /contacts/add`
- `GET /contacts`
- `POST /messages/send`
- `GET /messages/history?peerUserId=...`
- `GET /ws?token=...` (WebSocket)

## Client setup in app

In login screen, set `Server URL` to your machine IP, for example:

- `http://192.168.1.10:8080`

Both phones must use the same server URL.
