import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:tag_picker/widget_slider.dart';

import 'main.dart';

class FolderPickerWidget extends StatelessWidget {

  static Future<String?> pickFolder() async {

    final String? directoryPath = await getDirectoryPath();
    return directoryPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Folder Picker Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            String? result = await pickFolder();
            if (result != null) {

              WidgetSlider.switchScreenSimple(context, MainPage(result));
            }
          },
          child: Text('Select folder'),
        ),
      ),
    );
  }
}