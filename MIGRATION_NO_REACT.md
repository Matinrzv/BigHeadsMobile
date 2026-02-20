# BigHeadsMobile - No React Migration Plan

## Current App (React Native) Summary
- Platform: React Native 0.84 (`react-native-ble-plx`)
- Main feature set:
1. BLE permission request (Android runtime permissions)
2. BLE scan by service UUID (`4fdb7f0a-96e4-4ecf-8d2b-6f57494701a1`)
3. Connect to selected peer
4. Listen for notifications and parse JSON envelope
5. Send text message envelope (base64 encoded JSON)
6. Minimal chat UI (peers list + message list + composer)

## BLE Protocol Details To Preserve
- Service UUID: `4fdb7f0a-96e4-4ecf-8d2b-6f57494701a1`
- Write characteristic UUID: `4fdb7f0b-96e4-4ecf-8d2b-6f57494701a1`
- Notify characteristic UUID: `4fdb7f0c-96e4-4ecf-8d2b-6f57494701a1`
- Outbound payload shape:
1. JSON object: `{ kind: "mesh", env: <envelope> }`
2. Base64 encoded before BLE write
- Inbound payload shape:
1. Base64 decode BLE notification value
2. Parse JSON
3. Read `packet.env`

## Option A: Flutter (Recommended for Android + iOS)
### Why
- Cross-platform replacement for React Native
- Fast to keep current product scope on both Android and iOS
- BLE ecosystem is mature enough (`flutter_reactive_ble`)

### Suggested Stack
- UI: Flutter (Material 3)
- BLE: `flutter_reactive_ble`
- State: `riverpod` (or `provider` for simpler MVP)
- Serialization: `dart:convert` (json + base64)

### Migration Work Items
1. Create Flutter app module
2. Implement `BleTransport` in Dart preserving UUID/protocol
3. Build same MVP screen:
   - buttons: permission/scan/stop/connect/send
   - peers horizontal list
   - chat list
4. Add Android permissions in `AndroidManifest.xml`
5. Add iOS Bluetooth usage descriptions in `Info.plist`
6. Test on 2 real devices for scan/connect/send/receive

### Estimated Effort
- MVP parity: 2-4 days
- Stabilization + edge cases: 2-3 days

## Option B: Native Kotlin (Android only)
### Why
- Best Android performance/control
- No cross-platform support (iOS rewrite needed separately in Swift)

### Suggested Stack
- UI: Jetpack Compose
- BLE: Android `BluetoothLeScanner` + `BluetoothGatt`
- State: `ViewModel` + `StateFlow`
- Serialization: `kotlinx.serialization` + base64

### Migration Work Items
1. Remove React host/activity wiring
2. Build Compose screen for current MVP UX
3. Implement BLE manager with scan/connect/notify/write
4. Implement envelope encode/decode and chat state
5. Runtime permission flow for Android 12+
6. Device testing (API 24+)

### Estimated Effort
- MVP parity (Android only): 2-5 days
- Hardening BLE behavior: 2-4 days

## Recommended Decision
- If you want **both Android and iOS**: choose **Flutter**
- If you want **Android only** and max native control: choose **Kotlin**

## Practical Next Step
- Freeze React Native code as reference.
- Start fresh app shell in selected stack.
- Port BLE transport first, then UI.
