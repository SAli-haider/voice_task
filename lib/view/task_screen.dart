import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voice_notes/controller/tash_controller.dart';
import 'package:voice_notes/utils/extension/date_time.dart';
import 'package:voice_notes/utils/pallet/color_pallet.dart';

import '../utils/widgets/custom_text.dart';

class TaskScreen extends StatelessWidget {
  TaskScreen({super.key});
  final TaskController controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Voice Task Manager',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        backgroundColor: ColorPallet.accentColor,
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return Card(
                color: ColorPallet.cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: CustomText(
                    text: task.title,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorPallet.textColor,
                  ),
                  subtitle: Column(
                    children: [
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: task.description,
                          fontSize: 12,
                          textAlign: TextAlign.start,
                          color: ColorPallet.textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: CustomText(
                          text: task.dateTime.toFormattedString(),
                          fontSize: 11,
                          textAlign: TextAlign.right,
                          fontWeight: FontWeight.w400,
                          color: ColorPallet.textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon:
                        const Icon(Icons.delete, color: ColorPallet.textColor),
                    onPressed: () => controller.deleteTask(task.taskId),
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPallet.accentColor,
        onPressed: () => controller.listenAndProcessCommand(),
        child: Obx(() {
          if (controller.isLoading.value && !controller.isVoiceAtive.value) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          } else if (controller.isVoiceAtive.value) {
            return Lottie.asset("assets/mic_lottie.json");
          } else {
            return const Icon(Icons.mic, color: Colors.white);
          }
        }),
      ),
    );
  }
}
