# 📚 Smart E-Book - AI Powered Mobile Application With Assistive Features for Visually Impaired Individuals

**Smart Ebook** is a cross-platform mobile application designed for an enhanced ebook reading experience to address visually impaired individuals. It features PDF support, Machine Learning Model( google-mlkit-text-recognition) is used for text extraction, Gemini AI for user specific recommendation which is based on user behaviour or search history stored in the database.

---

## 🚀 Overview

Smart Ebook is a  mobile application for buying and reading ebooks with extended features such as:

- PDF viewing
- AI based text extraction and audio generation
- Integrated Gemini AI for recommendation
- Audio playback
- Appwrite cloud backend integration
- Multi-language support
- Secure local storage
- Ratings and user engagement
- Chapa Payment System

---

##  Features
-  **Text Extraction** – support text extraction via [`google-mlkit-text-recognition`] model
-  **Recommendation** – Recommend users based on their search history via [`Gemini AI`] model
-  **Ebook Reading** – Supports PDFs via [`pdfx`]
-  **Audio Playback** – Listen to audio via [`audioplayers`]
-  **Cloud Sync** – Integrated with Appwrite backend
-  **Cross-platform** – Android and iOS support
-  **Localization** – Multi-language support via `flutter_localizations`
-  **Secure Storage** – Uses `shared_preferences` for local data
-  **Rating System** – Users can rate books

---


## 🛠️ Installation

### Prerequisites

- Flutter SDK (compatible with Dart 3.7.0+)
- Dart SDK
- Android Studio or Xcode

### Setup Instructions

```bash
git clone https://github.com/naolselemon/SmartE-Book.git
cd smart-ebook
flutter pub get
```

1. Create a `.env` file in the root directory with your Appwrite credentials:

2. Then run the app:
   ```bash
   flutter run
   ```

---

## 📦 Dependencies

### Main Packages

- `google-mlkit` – for text extraction and audio generation
- `gemini 1.5 Model` –  for user specific recommendation
- `flutter_riverpod` – State management
- `appwrite` – Backend integration
- `pdfx` – PDF rendering
- `audioplayers` – Audio playback
- `google_fonts` – Custom fonts
- `flutter_dotenv` – Env config
- `shared_preferences` – Local storage
- `permission_handler` – Permissions

### Dev Dependencies

- `build_runner` – Codegen
- `riverpod_generator` – Riverpod auto gen

---

## ⚙️ Configuration

Before first run:
- Set up Appwrite backend
- Create `.env` with `APPWRITE_ENDPOINT` and `APPWRITE_PROJECT_ID`
- Ensure all asset paths in `pubspec.yaml` are valid

---

## 🛠 Building the App

### Android:
```bash
flutter build apk --release
```

### iOS:
```bash
flutter build ios --release
```

---

## 🤝 Contributing

We welcome contributions!  
Please follow best practices, test your changes, and submit PRs to the `develop` branch.


---

## 🧰 Support

For questions or issues, open an issue on [GitHub](https://github.com/naolselemon/SmartE-Book/issues).


