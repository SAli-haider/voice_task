Voice Notes
A Flutter-based mobile application named "Voice Notes" that enables users to manage tasks using voice commands, powered by the Gemini API for natural language processing and ObjectBox for local data persistence.
Features

Voice Command Support: Create, update, or delete tasks using voice input processed by the Gemini API.
Task Management: Add, view, update, and delete tasks with title, description, and datetime.
Local Storage: Persists tasks using ObjectBox, ensuring data is retained across app sessions.
Responsive UI: Modern UI with cards for task display, a floating action button for voice input, and Google Fonts for typography.
Lottie Animations: Visual feedback during voice input with a microphone animation.
Error Handling: User-friendly snackbar notifications for success and error states.

Setup Instructions

Clone the Repository:
git clone https://github.com/username/voice_notes.git
cd voice_notes


Install Flutter:Ensure Flutter is installed (version 3.4.3 or higher). Follow the official Flutter installation guide.

Install Dependencies:Run the following command in the project directory to install dependencies from pubspec.yaml:
flutter pub get


Set Up ObjectBox:

Generate ObjectBox bindings by running:flutter pub run build_runner build


This generates objectbox.g.dart for the ObjectBox database.


Add Gemini API Key:

Obtain an API key from Google Cloud for Gemini API.
Add the API key to lib/main.dart (replace 'your-api-key' in the code).


Add Lottie Animation:

Download a microphone Lottie animation from LottieFiles and place it in assets/mic_lottie.json.


Run the App:
flutter run



How to Use the App

Launch the App: Open the app on your device or emulator.
View Tasks: The main screen displays tasks in a list of cards, showing title, description, and formatted datetime.
Add a Task:  
Tap the floating action button (microphone icon).
Speak a command like: "Create a task to attend meeting and description meeting 
extract overall flutter related journey 
on July 10 2025 at 2 PM."
The app processes the command via the Gemini API and adds the task to the list.


Update a Task:  
Speak a command like: "Update the task attend meeting to attend conference at 10 June 2025 5PM."
The app updates the matching task based on title or datetime.


Delete a Task:  
Speak a command like: "Delete the task attend meeting."
Alternatively, tap the delete icon on a task card to remove it.


Visual Feedback:  
A Lottie animation displays during voice input.
A loading indicator shows while processing the voice command.
Success or error messages appear as snackbars at the bottom of the screen.



LLM Integration
The app integrates with the Gemini API (gemini-1.5-flash model) to process voice commands:

Voice Input: The speech_to_text package captures spoken commands and converts them to text.
API Request: The text is sent to the Gemini API with a prompt requiring a JSON response in the format:{
"action": "create|update|delete",
"title": "task title",
"description": "task description (optional)",
"datetime": "ISO 8601 format (e.g., 2025-07-01T14:30:00)",
"new_title": "new title for update (optional)",
"new_description": "new description for update (optional)",
"new_datetime": "new ISO 8601 datetime for update (optional)"
}


Response Handling: The TaskController parses the JSON response to perform the specified action (create, update, or delete tasks).
Date Parsing: Uses the intl package to parse flexible date formats, falling back to the current time if parsing fails.
Error Handling: Displays snackbar notifications for API errors, invalid responses, or unrecognized commands.

State Management
The app uses GetX for state management due to its simplicity, reactivity, and ease of use:

Reactive State:  
The TaskController manages a reactive list of tasks (RxList<Task>) and boolean flags (isLoading, isVoiceAtive) using Rx observables.
The UI (TaskScreen) uses Obx to automatically rebuild when the task list or flags change.


Why GetX?:  
Lightweight compared to alternatives like Provider or Riverpod.
Provides reactive state management without boilerplate code.
Simplifies dependency injection with Get.put and navigation with Get.snackbar.


Implementation:  
TaskController handles task operations (add, update, delete) and voice command processing.
Changes to tasks, isLoading, or isVoiceAtive trigger automatic UI updates.
ObjectBox persists tasks locally, and TaskController syncs the in-memory tasks list with the database.



Controller-Model-View Pattern

Controller (TaskController): Manages business logic, API calls, voice processing, and state updates.
Model (Task): Defines the data structure for tasks with fields for taskId, title, description, and dateTime, annotate for ObjectBox persistence.
View (TaskScreen): Renders the UI using reusable widgets (CustomText) and reacts to state changes via Obx.

Reusable Widgets

CustomText: A reusable Text widget with customizable font size, weight, color, and alignment, styled with Google Fonts (if configured).
Usage: Simplifies consistent text styling across the app, reducing code duplication.

Screenshots

Main Screen: [Insert screenshot of task list]
Voice Input Active: [Insert screenshot of microphone animation]
Task Created Notification: [Insert screenshot of snackbar]

Demo Video

[Insert link to demo video hosted on GitHub or external platform]

Project Structure
voice_notes/
├── lib/
│   ├── controller/
│   │   └── task_controller.dart
│   ├── model/
│   │   └── task.dart
│   ├── utils/
│   │   ├── extension/
│   │   │   └── date_time.dart
│   │   ├── pallet/
│   │   │   └── color_pallet.dart
│   │   └── widgets/
│   │       └── custom_text.dart
│   ├── task_screen.dart
│   ├── about_screen.dart
│   └── main.dart
├── assets/
│   └── mic_lottie.json
├── pubspec.yaml
└── README.md

