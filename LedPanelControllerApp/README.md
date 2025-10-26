# LED Panel Controller (Flutter)

A Flutter-based mobile companion app for the ESP32-powered LED signage system. The app lets authenticated operators connect to the controller over Wi-Fi, preview their message on a virtual 16×96 LED wall, and send updates with optional animations.

## Features
- Connect to your ESP32 signage controller via HTTPS or HTTP.
- Optional API key header for simple authentication.
- Compose, validate, and preview scrolling messages before sending.
- Choose from predefined animation hints (scroll, blink, slide).
- Built with Material 3 widgets and Provider-based state management.

## Getting Started
1. Ensure the Flutter SDK (3.13 or newer) is installed.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a connected device or emulator:
   ```bash
   flutter run
   ```

## Configuring the ESP32 Firmware
Expose two HTTP endpoints from the ESP32 firmware or a proxy server:
- `GET /health` – returns 200 OK when the signage controller is reachable.
- `POST /message` – accepts `{ "text": "...", "animation": "scroll-left" }` payloads and updates the display.

If you require API-key protection, validate the `X-API-Key` header against server-side secrets.

## Customising Animations
Update the `animations` list in `lib/screens/message_screen.dart` to align with the effects supported by your firmware.

## License
This project is distributed for demonstration purposes within the Android Mini Projects repository.
