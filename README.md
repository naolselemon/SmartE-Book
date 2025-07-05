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

## 📁 Project Structure

```
.
.
- assets/
├── fonts/
├── images/
├── audio/
```
.
.
- lib/
├── controller/
│   ├── book_services.dart
│   ├── file_download_services.dart
│   ├── search_history_services.dart
│   ├── search_service.dart
│   ├── user_services.dart
- ├── model/
│   ├── book.dart
│   ├── bookwithrating.dart
│   ├── favorite.dart
│   ├── review.dart
│   ├── user.dart
- ├── view_models/
│   ├── auth_view_model.dart
│   ├── book_view_model.dart
- ├── views/
│   ├── Providers/
│   │   ├── books_provider.dart
│   │   ├── search_providers.dart
│   │   ├── setting_provider.dart
│   │   ├── user_provider.dart
├   ├── screens/
│   │   ├── authentication_pages/     
│   │   │   ├── app_bar.dart
│   │   │   ├── signin.dart
│   │   │   ├── signup.dart
│   │   │   ├── splas_page.dart
│   │   ├── dashbord_pages/
│   │   │   ├── drawerComponent/
│   │   │   │   ├── paymentMethod.dart
│   │   │   │   ├── profile.dart
│   │   │   │   ├── setting.dart
│   │   │   ├── audioplaypage.dart
│   │   │   ├── bookdetailpage.dart
│   │   │   ├── dashboard_page.dart
│   │   │   ├── drawerpage.dart
│   │   │   ├── homepage.dart
│   │   │   ├── librarypage.dart
│   │   │   ├── pdfviewpage.dart
│   │   │   ├── reviewpage.dart
│   │   ├── searchpages/
│   │   │   ├── search.dart
│   │   │   ├── searchpage.dart
- ├   ├── widgets/
│   │   ├── authentication_widgets/
│   │   │   ├── password_textfield.dart
│   │   │   ├── textfield.dart
│   │   ├── dashboard_widgets/ 
│   │   │   ├── audioplayerwidget.dart
│   │   │   ├── bookdetailcontainer.dart
│   │   │   ├── sectiontitle.dart
│   │   ├── search_widgets/ 
│   │   │   ├── authors_images.dart
│   │   │   ├── book_coverpage.dart
│   │   │   ├── catagories_card.dart
│   ├── app_theme.dart
.
.
.



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


