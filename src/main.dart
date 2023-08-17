import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:tag_picker/tag.dart';
import 'package:tag_picker/widget_slider.dart';
import 'package:window_size/window_size.dart';

import 'folder_picker.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Tag Picker");
    setWindowMinSize(const Size(300, 200));
  }

  runApp(
    MaterialApp(
      home: FolderPickerWidget(),
    ),
  );
}

class MainPage extends StatefulWidget {
  
  final String dirPath;
  MainPage(this.dirPath);

  @override
  _MainPageState createState() => _MainPageState(dirPath);
}

class _MainPageState extends State<MainPage> {

  final String dirPath;

  _MainPageState(this.dirPath);

  final TagController tagController = TagController();
  int currentIndex = 0;

  TextEditingController tagTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  loadImages() async {
    try {
      final dir = Directory(dirPath);
      final imageFiles = dir.listSync().where((entity) {
        return entity is File && (entity.path.endsWith(".png") || entity.path.endsWith(".jpg"));
      }).map((e) => e as File).toList();

      tagController.addImages(imageFiles);
    } catch (e) {
      print('Error loading images: $e');
    }
  }

  saveImageTags(String destinationFolder) async {
    
    for (int i = 0; i < tagController.imagesWithTags.length; i++) {

      String fileName = "${basenameWithoutExtension(tagController.imagesWithTags[i].image!.path)}.txt";
      final String filePath = '$destinationFolder/$fileName';
      
      final File file = File(filePath);
      final String data = tagController.imagesWithTags[i].tags.join(", ");
      
      await file.writeAsString(data);
    }
  }

  final double elementsPadding = 8.0;

  @override
  Widget build(BuildContext context) {

    if (tagController.imagesWithTags.isEmpty) {

      Timer(const Duration(milliseconds: 2500), () {

        WidgetSlider.switchScreenSimple(context, FolderPickerWidget());
      });

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: const Text("Folder not contains .png images"),
      );
    }

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    int flexesForImage = max(height - 50.0, 0.0).floor();
    int flexesTags = max(height - 50.0, 0.0).floor();

    return Scaffold(
      appBar: AppBar(
        title: Text("${currentIndex + 1} / ${tagController.imagesWithTags.length} [${tagController.imagesWithTags[currentIndex].tags.length}]"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {

            String? exportFolder = await FolderPickerWidget.pickFolder();
            if (exportFolder != null) saveImageTags(exportFolder);

          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 170, 170, 170),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(elementsPadding, elementsPadding, elementsPadding / 2.0, elementsPadding),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: tagTextController,
                          decoration: InputDecoration(
                            labelText: "Enter tag",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                if (tagTextController.text.isNotEmpty) {
                                  setState(() {
                                    tagController.addGlobalTag(tagTextController.text);
                                    tagTextController.clear();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tagController.tags.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (tagController.imagesWithTags[currentIndex].tags.contains(tagController.tags[index])) {

                                      tagController.removeImageTagByIndex(currentIndex, index);
                                    }
                                    else {

                                      tagController.addTagToImageByIndex(currentIndex, tagController.tags[index]);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (tagController.imagesWithTags[currentIndex].tags.contains(tagController.tags[index])) ? Colors.green : Colors.grey,
                                    borderRadius: const BorderRadius.all(Radius.circular(8))
                                  ),
                                  child: ListTile(
                                    title: Text(tagController.tags[index]),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          tagController.removeGlobalTagByIndex(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(elementsPadding / 2.0, elementsPadding, elementsPadding, elementsPadding),
                child: Column(
                  children: [
                    Expanded(
                      flex: flexesForImage,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: elementsPadding),
                        child: Container(
                          constraints: const BoxConstraints.expand(),
                          color: Colors.white,
                          child: Center(
                            child: (tagController.imagesWithTags.isEmpty)
                              ? const CircularProgressIndicator()
                              : Image.file(
                                  tagController.imagesWithTags[currentIndex].image!,
                                  fit: BoxFit.scaleDown,
                                ),
                            ),
                          ),
                      ),
                    ),
                    Expanded(
                      flex: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: elementsPadding / 2.0),
                              child: Container(
                                constraints: const BoxConstraints.expand(),
                                color: Colors.blue,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_left),
                                  onPressed: () {
                                    if (currentIndex > 0) {
                                      setState(() {
                                        currentIndex--;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: elementsPadding / 2.0),
                              child: Container(
                                constraints: const BoxConstraints.expand(),
                                color: Colors.blue,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_right),
                                  onPressed: () {
                                    if (currentIndex < tagController.imagesWithTags.length - 1) {

                                      if (tagController.imagesWithTags[currentIndex + 1].tags.isEmpty && tagController.imagesWithTags[currentIndex].tags.isNotEmpty) {

                                        tagController.imagesWithTags[currentIndex + 1].tags.addAll(tagController.imagesWithTags[currentIndex].tags);
                                      }

                                      setState(() {
                                        currentIndex++;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}