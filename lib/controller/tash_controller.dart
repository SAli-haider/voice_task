import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_notes/main.dart';
import 'package:voice_notes/model/task.dart';
import 'package:voice_notes/objectbox.g.dart';

import '../utils/const_file.dart';

class TaskController extends GetxController {
  final taskBox = objectBox.store.box<Task>();
  @override
  void onInit() {
    tasks.value = taskBox.getAll();
    super.onInit();
  }

  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  var isVoiceAtive = false.obs;
  final SpeechToText _speech = SpeechToText();

  Future<void> listenAndProcessCommand() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          isVoiceAtive.value = false;
        }
      },
      finalTimeout: const Duration(seconds: 5),
      onError: (error) {
        print('Speech error: $error');
        isVoiceAtive.value = false;
        Get.snackbar('Error', 'Speech recognition error: ${error.errorMsg}',
            snackPosition: SnackPosition.BOTTOM);
      },
    );

    if (available) {
      isVoiceAtive.value = true;

      await _speech.listen(
        listenOptions: SpeechListenOptions(
          partialResults: true,
          autoPunctuation: true,
          listenMode: ListenMode.dictation,
          // pauseFor: const Duration(seconds: 3), // Pause detection delay
          // listenFor: const Duration(seconds: 15), // Max listening duration
          onDevice: false, // Use cloud-based recognition if available
          cancelOnError: false, // Continue listening on minor errors
        ),
        onResult: (result) async {
          if (result.finalResult) {
            final voiceText = result.recognizedWords;
            if (voiceText.isNotEmpty) {
              _speech.stop();
              isVoiceAtive.value = false;
              isLoading.value = true;
              try {
                final llmResponse = await sendToGemini(voiceText);
                print("Raw LLM response:\n$llmResponse");
                handleLLMResponse(llmResponse);
              } catch (e) {
                print("Error in sendToGemini: $e");
                Get.snackbar('Error', 'Failed to process voice command: $e',
                    snackPosition: SnackPosition.BOTTOM);
              } finally {
                isLoading.value = false;
              }
            } else {
              _speech.stop();
              isVoiceAtive.value = false;
              Get.snackbar('Error', 'No speech detected',
                  snackPosition: SnackPosition.BOTTOM);
            }
          } else {
            // Optionally handle partial results for real-time feedback
            print("Partial result: ${result.recognizedWords}");
          }
        },
      );
    } else {
      Get.snackbar('Error', 'Speech recognition not available',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<String> sendToGemini(String voiceText) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "You are a task manager assistant. Respond ONLY in JSON with the following structure:\n"
                    "{\n"
                    "  \"action\": \"create|update|delete\",\n"
                    "  \"title\": \"task title\",\n"
                    "  \"description\": \"task description (optional)\",\n"
                    "  \"datetime\": \"ISO 8601 format (e.g., 2025-07-01T14:30:00)\",\n"
                    "  \"new_title\": \"new title for update (optional)\",\n"
                    "  \"new_description\": \"new description for update (optional)\",\n"
                    "  \"new_datetime\": \"new ISO 8601 datetime for update (optional)\"\n"
                    "}\n"
                    "Ensure all fields are strings and datetime is in ISO 8601 format. Do not include code block markers (```).\n"
                    "User command: $voiceText"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'API request failed: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'];
  }

  void handleLLMResponse(String responseJson) {
    // Handle various response formats
    String cleanedJson = responseJson.trim();
    if (responseJson.contains('```json')) {
      cleanedJson =
          responseJson.replaceAll('```json', '').replaceAll('```', '').trim();
    } else if (responseJson.contains('```')) {
      cleanedJson = responseJson.replaceAll('```', '').trim();
    }

    print("Cleaned JSON:\n$cleanedJson");

    try {
      final data = jsonDecode(cleanedJson);
      final action = (data['action'] ?? '').toString().toLowerCase().trim();
      final title = (data['title'] ?? '').toString().trim();

      if (action.isEmpty || title.isEmpty) {
        throw Exception('Missing action or title in response');
      }

      if (action == 'create') {
        addTask(Task(
          taskId: UniqueKey().toString(),
          title: title,
          description: (data['description'] ?? '').toString().trim(),
          dateTime: data['datetime'] != null
              ? parseFlexibleDate(data['datetime'])
              : DateTime.now(),
        ));

        Get.snackbar('Success', 'Task "$title" created',
            snackPosition: SnackPosition.BOTTOM);
      } else if (action == 'delete') {
        final task = findTask(title, data['datetime']);
        if (task != null) {
          deleteTask(task.taskId);
          Get.snackbar('Success', 'Task "$title" deleted',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', 'Task "$title" not found',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else if (action == 'update') {
        final task = findTask(title, data['datetime']);
        if (task != null) {
          updateTask(
            task.taskId,
            Task(
              taskId: task.taskId,
              title: (data['new_title'] ?? task.title).toString().trim(),
              description: (data['new_description'] ?? task.description)
                  .toString()
                  .trim(),
              dateTime: data['new_datetime'] != null
                  ? parseFlexibleDate(data['new_datetime'])
                  : task.dateTime,
            ),
          );
          Get.snackbar('Success', 'Task "$title" updated',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.snackbar('Error', 'Task "$title" not found',
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        throw Exception('Unknown action: $action');
      }
    } catch (e) {
      print("Failed to parse LLM response: $e");
      Get.snackbar('Error', 'Failed to process response: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Task? findTask(String title, String? datetime) {
    final lowerTitle = title.toLowerCase().trim();
    DateTime? parsedDateTime;
    if (datetime != null && datetime.isNotEmpty) {
      try {
        parsedDateTime = parseFlexibleDate(datetime);
      } catch (_) {
        parsedDateTime = null;
      }
    }

    return tasks.firstWhereOrNull((t) {
      final matchesTitle = t.title.toLowerCase().trim() == lowerTitle;
      if (parsedDateTime == null) return matchesTitle;
      // Allow a 1-hour window for datetime matching to handle minor variations
      final matchesDate =
          t.dateTime.difference(parsedDateTime).inMinutes.abs() < 60;
      return matchesTitle || matchesDate;
    });
  }

  DateTime parseFlexibleDate(String? input) {
    if (input == null || input.isEmpty) return DateTime.now();

    // Try parsing various date formats
    try {
      return DateTime.parse(input).toLocal();
    } catch (_) {
      try {
        final formats = [
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd',
          'dd-MM-yyyy',
          'MM/dd/yyyy',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-dd HH:mm',
        ];
        for (var format in formats) {
          try {
            return DateFormat(format).parse(input).toLocal();
          } catch (_) {}
        }
      } catch (_) {}
    }

    // Fallback to current time if parsing fails
    print("Failed to parse date: $input, using current time");
    return DateTime.now();
  }

  void addTask(Task task) {
    tasks.add(task);
    objectBox.store.box<Task>().put(task);
    sortTasks();
  }

  void deleteTask(String id) {
    final task = taskBox.query(Task_.taskId.equals(id)).build().findFirst();
    if (task != null) taskBox.remove(task.id);
    tasks.removeWhere((task) => task.taskId == id);
  }

  void updateTask(String taskId, Task updatedTask) {
    final index = tasks.indexWhere((task) => task.taskId == taskId);
    if (index != -1) {
      tasks[index] = updatedTask;
      sortTasks();
    }
    final existingTask =
        taskBox.query(Task_.taskId.equals(taskId)).build().findFirst();

    if (existingTask != null) {
      existingTask.title = updatedTask.title;
      existingTask.description = updatedTask.description;
      existingTask.dateTime = updatedTask.dateTime;

      taskBox.put(existingTask);
    }
  }

  void sortTasks() {
    tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
}
