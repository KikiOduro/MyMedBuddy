# MyMedBuddy

**MyMedBuddy** is a personal health and medication management app built with Flutter. It helps users track their medications, health logs, appointments, and daily wellness tips. Designed for offline and online use, the app uses persistent storage, real-time API integration, and reactive state management for a smooth and personalized experience.

---

## ✨ Features

- **User Onboarding**
  - Captures name, age, medical condition, and medication reminder preferences using Forms
  - Stores data with `SharedPreferences`
  - Automatically skips onboarding after first launch

- **Multi-Screen Navigation**
  - Home screen with responsive dashboard
  - Medication Schedule
  - Health Logs
  - Appointment Scheduler
  - Profile with editable user data
  - Dark/Light mode toggle and notification preferences

- **Health Logs**
  - Track symptoms, pain scale, vitals, and notes
  - Daily log badge + history
  - State stored with `Riverpod` + persistent using `SharedPreferences`

- **Medication Management**
  - Suggests medications based on stored health condition
  - Fetches real drug names using the RxNav API
  - Allows user to set time and track taken meds

- **Appointments**
  - Schedule future appointments with date and time
  - Upcoming appointments shown on Home screen

- **Profile Page**
  - View/edit name, age, condition
  - Health tip of the day (randomized offline tips)
  - Notification toggle and dark mode switch

---

## 📦 Packages Used

| Package                 | Purpose                                       |
|-------------------------|-----------------------------------------------|
| `flutter_riverpod`      | State management (HealthLogProvider)          |
| `provider`              | Theme management                              |
| `shared_preferences`    | Local persistent storage                      |
| `http`                  | Fetch drug data from RxNav API                |

---

## 🧱 Project Structure

> Note: Some features (like custom widgets and services) were implemented **within screens** instead of splitting into folders like `/widgets` and `/services`. However, structure is modular and organized for clarity.


_This app was built as part of a coursework submission for Ashesi University's Mobile Development module._
## How to Run the App

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/KikiOduro/MyMedBuddy.git
   cd MyMedBuddy
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```

4. **Simulator or Device:**
   Ensure you have a connected emulator or physical device.

---
