# 🌸 MindEase: A Holistic Mindfulness & Wellness Ecosystem

**MindEase** is a sophisticated Flutter-based application designed to bridge the gap between technology and mental well-being. By combining real-time data tracking with interactive "Zen" experiences, MindEase empowers users to manage stress, monitor emotional patterns, and achieve daily mindfulness goals.

---

## 🚀 Vision & Leadership
* **Hifza Nazir (Lead Developer & Designer):** Primary architect behind the app's logic, UI/UX design, and core mindfulness features.
* **Tahir Ahmad (Team Member):** Instrumental in technical collaboration, testing, and implementation support.

---

## ✨ Comprehensive Visual Tour

### 📱 1. Authentication & Onboarding
A seamless entry into your personal sanctuary using **Firebase Authentication**.
| Welcome | Onboarding 1 | Onboarding 2 | Onboarding 3 | Login/Signup |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/auth_welcome.jpeg" width="160"> | <img src="screenshots/auth_onboarding1.jpeg" width="160"> | <img src="screenshots/auth_onboarding2.jped" width="160"> | <img src="screenshots/auth_onboarding3.jpeg" width="160"> | <img src="screenshots/auth_login.jpeg" width="160"> |

---

### 📊 2. Dashboard & Progress Intelligence
The central hub for tracking streaks, notifications, and real-time progress.
| Main Dashboard | Progress Stats | Streak System | Notifications |
|:---:|:---:|:---:|:---:|
| <img src="screenshots/dash_main.png" width="160"> | <img src="screenshots/dash_progress_stats.png" width="160"> | <img src="screenshots/dash_streaks.png" width="160"> | <img src="screenshots/dash_notifications.png" width="160"> |



---

### 🧘 3. Wellness & Emotional Intelligence
Granular mood tracking and secure journaling for self-reflection.
| Mood Selection | Mood History | Journal List | New Entry | Journal Detail |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/mood_select.png" width="160"> | <img src="screenshots/mood_history.png" width="160"> | <img src="screenshots/journal_list.png" width="160"> | <img src="screenshots/journal_new_entry.png" width="160"> | <img src="screenshots/journal_detail.png" width="160"> |

---

### 🌈 4. Activities & Affirmations
Daily inspiration and peaceful sounds to keep your mind at ease.
| Activities Page | Games Hub | Peaceful Sounds | Daily Affirmations | Quote Card |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/activities_page.png" width="160"> | <img src="screenshots/act_games.png" width="160"> | <img src="screenshots/act_peaceful_sounds.png" width="160"> | <img src="screenshots/affirmation_daily.png" width="160"> | <img src="screenshots/quote_card.png" width="160"> |

---

### 🎮 5. Zen Games (Stress Relief)
Interactive and focus-driven games designed to lower cortisol levels.
| Aqua Guardian | Zen Memory | Stress Fighter | Neon Odyssey | Color Harmony |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/game_aqua_guardian.png" width="160"> | <img src="screenshots/game_zen_memory.png" width="160"> | <img src="screenshots/game_stress_fighter.png" width="160"> | <img src="screenshots/game_neon_odyssey.png" width="160"> | <img src="screenshots/game_color_harmony.png" width="160"> |

---

### 🎨 6. Profile & Settings
Managing your personal journey and application preferences.
| Profile Main | Edit Profile | Settings | About MindEase | Help & Support |
|:---:|:---:|:---:|:---:|:---:|
| <img src="screenshots/profile_main.png" width="160"> | <img src="screenshots/profile_edit.png" width="160"> | <img src="screenshots/settings_general.png" width="160"> | <img src="screenshots/about_mindease.png" width="160"> | <img src="screenshots/help_support.png" width="160"> |

---

## 🛠️ Technical Architecture

### **Backend: Firebase Infrastructure ☁️**
The app utilizes a robust Firebase backend to ensure data integrity and real-time updates.
| Auth Console | Firestore DB | App Structure |
|:---:|:---:|:---:|
| <img src="screenshots/firebase_auth_console.png" width="250"> | <img src="screenshots/firestore_database.png" width="250"> | <img src="screenshots/app_structure.png" width="250"> |

### **Core Stack**
* **Frontend:** Flutter & Dart
* **State Management:** Provider/Bloc for reactive UI updates.
* **Database:** Cloud Firestore (NoSQL).
* **Security:** Firebase Authentication & Firestore Security Rules.

---

## 📁 Project Directory Structure
```text
lib/
├── games/          # Innovative Zen activities & game logic engines
├── services/       # Firebase Auth, Firestore, and Notification logic
├── screens/        # Dashboard, Wellness Tools, and Settings UI
├── models/         # Data blueprints for Moods, Goals, and Users
├── widgets/        # Reusable custom UI components (Glassmorphism)
└── main.dart       # App initialization and Theme configuration
