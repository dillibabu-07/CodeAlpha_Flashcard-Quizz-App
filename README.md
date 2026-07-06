# FlashMaster – Smart Flashcard Quiz App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-blue?style=flat-square&logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/SQLite-Local%20DB-green?style=flat-square&logo=sqlite" alt="SQLite"/>
  <img src="https://img.shields.io/badge/Material-Design%203-orange?style=flat-square" alt="Material Design 3"/>
</div>

A production-ready **flashcard quiz application** for students — built with Flutter, Material Design 3, and SQLite. Created for the **CodeAlpha Internship Task 1**.

---

## ✨ Features

### Core
- 📚 **Flashcard Management** – Add, Edit, Delete, Duplicate flashcards
- 📂 **Categories** – Organize cards into unlimited color-coded categories with icons
- 🎴 **Study Mode** – Animated 3D card flip, swipe navigation, shuffle & restart
- 🧠 **Quiz Mode** – Auto-generated MCQ with timer, scoring, and instant feedback
- 📊 **Statistics Dashboard** – Charts, streaks, accuracy, and weekly progress
- ❤️ **Favorites** – Bookmark important cards
- 🔍 **Search** – Real-time search by question, answer, category, or tag

### UI/UX
- Material Design 3 with rounded cards and soft shadows
- **Dark Mode / Light Mode / System Theme**
- Gradient headers with decorative overlays
- 3D animated card flip (AnimationController + Matrix4 perspective)
- Swipe left/right to navigate flashcards
- **Confetti animation** after quiz completion (≥60% score)
- Animated bottom navigation bar with active indicator
- Pull-to-refresh on all major screens
- Smooth Hero animations and transitions
- Empty state screens for every list

### Data
- **Offline-first** SQLite storage
- Pre-loaded sample data: 8 categories, 45+ flashcards
- JSON Export / Import
- Reset all data

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp + routing + bottom nav
├── constants/                   # Colors, strings, sizes
├── theme/                       # Light & dark ThemeData
├── models/                      # Category, Flashcard, QuizResult, StudyHistory
├── database/                    # DatabaseHelper + DAOs
├── providers/                   # Theme, Category, Flashcard, Study, Quiz, Stats
├── services/                    # SampleData, Export, Import, Notifications
├── screens/                     # All 13 screens
├── widgets/                     # Reusable widgets (flip card, stat card, etc.)
├── animations/                  # ConfettiOverlay
└── utils/                       # Extensions, validators
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Material Design 3) |
| Language | Dart 3.x (Null Safe) |
| State Management | Provider 6.x |
| Local Database | SQLite (sqflite + path) |
| Charts | fl_chart |
| Fonts | Google Fonts (Poppins + Inter) |
| Animations | Confetti, Flutter animations |
| Persistence | SharedPreferences |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x+ installed
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)

### Setup

```bash
# Clone the project
cd C:\Users\USER\.gemini\antigravity\scratch\flashmaster

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| Splash | Logo animation, data initialization |
| Home | Welcome, stats row, quick actions, recent cards |
| Categories | Color-coded grid, add/edit/delete categories |
| Category Detail | Cards in a category with study/quiz quick launch |
| Flashcards | List with search, sort, filter, swipe-to-delete |
| Add/Edit Card | Form with category, difficulty, tags, favorite |
| Study Mode | 3D flip card, swipe navigation, progress bar |
| Quiz Mode | MCQ with timer, scoring, instant feedback |
| Quiz Result | Confetti, score breakdown, question review |
| Statistics | Overview grid, weekly chart, recent results |
| Favorites | Bookmarked cards |
| Search | Real-time search with history |
| Settings | Theme, export/import, reset, about |

---

## 🎨 Color Palette

| Role | Color |
|------|-------|
| Primary | `#2563EB` |
| Secondary | `#3B82F6` |
| Accent / Success | `#10B981` |
| Easy | `#10B981` |
| Medium | `#F59E0B` |
| Hard | `#EF4444` |
| Light BG | `#F8FAFC` |
| Dark BG | `#0F172A` |

---

## 📊 Database Schema

```sql
-- Categories
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon_code INTEGER NOT NULL,
  color_hex TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- Flashcards
CREATE TABLE flashcards (
  id TEXT PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category_id TEXT REFERENCES categories(id) ON DELETE CASCADE,
  difficulty TEXT NOT NULL DEFAULT 'medium',
  tags TEXT NOT NULL DEFAULT '',
  is_favorite INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Quiz Results
CREATE TABLE quiz_results (...);

-- Study History
CREATE TABLE study_history (...);
```

---

## 📦 Sample Data

On first launch, the app automatically seeds:

- **8 Categories**: Java, Python, Data Structures, DBMS, OS, AI/ML, Mathematics, General Knowledge
- **45+ Flashcards** covering Easy → Hard difficulty across all categories

---

## 📝 License

This project is created for the **CodeAlpha Flutter Internship** - Task 1: Flashcard Quiz App.

---

<div align="center">
  Made with ❤️ using Flutter
</div>
