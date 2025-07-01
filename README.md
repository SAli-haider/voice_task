# 🎤 Voice Notes

**Voice Notes** is an innovative mobile application built with **Flutter** that revolutionizes task management through **voice-driven interactions**. By integrating advanced technologies such as the **Gemini API** and **ObjectBox**, it offers a seamless and intuitive experience for managing tasks through natural language.

---

## 🧠 Core Technologies

| Technology         | Purpose                                |
|--------------------|----------------------------------------|
| **Flutter**         | Cross-platform UI development          |
| **GetX**            | State management and dependency injection |
| **Gemini API**      | Natural language processing (`gemini-1.5-flash`) |
| **ObjectBox**       | Local database for offline task storage |
| **speech_to_text**  | Voice-to-text conversion               |

---

##  Key Features

### 1. Voice Command Intelligence
- **Functionality**: Create, update, and delete tasks entirely through voice.
- **Tech Stack**: Gemini API processes natural language input.
- **Supported Commands**:
    - "Create a task..."
    - "Update the task..."
    - "Delete the task..."
- **Parsing**: Extracts task title, description, and datetime from conversational input.

### 2. Task Management Capabilities
- **Task Attributes**:
    - `title`
    - `description`
    - `datetime`
- **Interaction Methods**:
    - Voice commands
    - Traditional touch UI

### 3.  Data Persistence
- **Storage**: Powered by ObjectBox
- **Benefits**:
    - Offline-first experience
    - High-performance local database
    - Data persists across app sessions

### 4. User Interface
- **Design Elements**:
    - Responsive layout with card-based task views
    - Floating action button (FAB) for initiating voice input
- **Visual Enhancements**:
    - Google Fonts for clean typography
    - Lottie animations for real-time voice feedback
    - Snackbar alerts for success and error notifications

---

## Technical Architecture

### State Management (GetX)
- **Reactive State**:
    - Real-time UI updates via `RxList<Task>` and observables
- **Dependency Injection**:
    - Simplified using `Get.put()` and `Get.find()`
- **Minimal Boilerplate**:
    - Quick to scale and manage

### Voice Processing Workflow
1. Capture speech via `speech_to_text`
2. Convert to text
3. Send to Gemini API with prompt
4. Receive structured JSON response:
   ```json
   {
     "action": "create|update|delete",
     "title": "...",
     "description": "...",
     "datetime": "2025-07-01T14:30:00",
     "new_title": "...",
     "new_description": "...",
     "new_datetime": "..."
   }
   ```
5. Parse and execute corresponding task operation
6. Update local database
7. Notify user with visual feedback

### Error Handling
- Snackbar alerts for feedback
- Graceful fallbacks for invalid input or parsing failures

---

## Development Setup

### Prerequisites
- Flutter SDK (3.22.2)
- Gemini API key

### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/SAli-haider/voice_task.git
cd voice_notes

# 2. Install dependencies
flutter pub get

# 3. Generate ObjectBox bindings
flutter pub run build_runner build

# 4. Configure Gemini API Key
# → Open lib/main.dart and replace 'your-api-key'

# 5. Add Lottie animation
# → Place mic_lottie.json in assets/mic_lottie.json

# 6. Run the app
flutter run
```

---

##  Usage Scenarios

###  Creating a Task
- **Action**: Tap the mic icon
- **Command**:  
  `"Create a task to attend meeting on July 10 2025 at 2 PM, Descrption progress millestone"`

###  Updating a Task
- **Command**:  
  `"Update the task attend meeting to attend conference at 10 June 2025 5 PM"`

### Deleting a Task
- **Command**:  
  `"Delete the task attend meeting"`
- **Alternate**: Use delete icon on the task card

---


---

##  Demo & Screenshots

📂 [View on Google Drive](https://drive.google.com/drive/folders/1thEnLnr0kFod10AjTKQKfTmvOzFxHY2i?usp=drive_link)

---



---

## 📄 License

This project is licensed under the MIT License.  
See the `LICENSE` file for more information.

---