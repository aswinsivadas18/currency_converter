# Currency Converter (Flutter) 💱

A simple, modern currency converter built with Flutter. It uses the public Frankfurter API to fetch currency lists and conversion rates, and demonstrates common Flutter concepts such as state management, input validation, custom dropdowns, and platform icon generation.

---

## 🔍 Project overview

- Name: **currency_converter**
- Platform: Flutter (Android / iOS / Web / Desktop)
- API: https://api.frankfurter.app

---

## ✅ Features

- Convert an amount from one currency to another using live rates
- Custom dropdown showing country flag, currency code and name
- Dropdown menu opens below the field and shows up to 3 scrollable items
- Input validation (required field, numeric-only validation with helpful error messages)
- Clear input button and automatic clearing after conversion
- Reset converted amount button
- Exit confirmation popup on app bar back button
- App launcher icons generated from provided PNG using `flutter_launcher_icons`

---

## 🧩 Key files & structure

- `lib/main.dart` — app entry, disables debug banner
- `lib/screens/currency_converter_material.dart` — main screen and UI logic
- `lib/widgets/currencyDropdown.dart` — custom dropdown widget (uses `showMenu` and scrollable constrained list)
- `lib/services/api_services.dart` — HTTP client code (uses `http` package)
- `lib/models/` — data models (`CurrencyModel`, `ConversionModel`)
- `assets/` — icons and image assets (app icon at `assets/images/app_icon_currency.png`)

---

## 💡 Implementation details & Flutter concepts used

- Widgets & UI
  - `StatefulWidget` for state management on the conversion page
  - `TextField` with `TextEditingController`, `FocusNode`, custom `InputDecoration` for validation visuals
  - Custom dropdown implemented with `GestureDetector` + `showMenu` to control menu position and sizing
  - `InputDecorator` used to render the dropdown field with label and error states
  - `SingleChildScrollView` + `ConstrainedBox` to limit dropdown height and make it scrollable

- Data & networking
  - `http` package to fetch currency list and conversion results
  - Model classes (`CurrencyModel`, `ConversionModel`) to parse JSON responses

- UX & Validation
  - Inline error messages and red borders for invalid inputs
  - Auto-focus on the amount field when validation fails
  - Automatic clearing of input after successful conversion

- Assets & Icons
  - `flutter_launcher_icons` used to generate platform icons from `assets/images/app_icon_currency.png`
  - If using SVGs, a rasterizer (ImageMagick or Inkscape) is needed to convert to PNGs for icon tooling

---

## 🚀 How to run

Prerequisites: Flutter SDK installed (stable channel), Android/iOS toolchains as required.

1. Get packages:

```bash
flutter pub get
```

2. (Optional) If you change the app icon and use an image PNG source, regenerate icons:

```bash
dart run flutter_launcher_icons:main
# or
flutter pub run flutter_launcher_icons:main
```

3. Run the app:

```bash
flutter run
```

> Note: If you use a raw SVG for icons, install ImageMagick or Inkscape on your machine before running the icon generator.

---

## 🧪 Testing

- No unit tests are included by default in this repository. To add tests, create files under `test/` and run:

```bash
flutter test
```

---

## 🤝 Contributing

- Fork the repo, make a branch for your change, and open a PR with a short description of your changes.

---

## 📄 License

- Add your preferred license (e.g., MIT) to the project root as `LICENSE`.

---

If you'd like, I can add a short `CONTRIBUTING.md`, CI config, or a screenshot section with sample images. 🔧
