import 'dart:io';

class TagController {

  List<String> tags = [];
  List<ImageTags> imagesWithTags = [];

  void addImages(List<File> imageFiles) {
    for (var file in imageFiles) {
      imagesWithTags.add(ImageTags([])..image = file);
    }
  }

  void addGlobalTag(String tagName) {

    int i;
    for (i = 0; i < tags.length; i++) {

      if (tagName == tags[i]) break;
    }
    if (i < tags.length) return; // existing tag

    tags.add(tagName);
  }

  void removeGlobalTagByIndex(int tagIndex) {

    if (tagIndex < 0 || tagIndex >= tags.length) return;

    for (int i = 0, j; i < imagesWithTags.length; i++) {

      for (j = 0; j < imagesWithTags[i].tags.length; j++) {

        if (tags[tagIndex] == imagesWithTags[i].tags[j]) {

          imagesWithTags[i].tags.removeAt(j);
          break;
        }
      }
    }

    tags.removeAt(tagIndex);
  }

  void addTagToImageByIndex(int imageIndex, String tagName) {

    if (imageIndex < 0 || imageIndex >= imagesWithTags.length) return;

    int i;
    for (i = 0; i < imagesWithTags[imageIndex].tags.length; i++) {

      if (tagName == imagesWithTags[imageIndex].tags[i]) break;
    }
    if (i < imagesWithTags[imageIndex].tags.length) return; // existing tag

    imagesWithTags[imageIndex].tags.add(tagName);
  }

  void removeImageTagByIndex(int imageIndex, int tagIndex) {

    if (imageIndex < 0 || imageIndex >= imagesWithTags.length) return;
    
    int i;
    for (i = 0; i < imagesWithTags[imageIndex].tags.length; i++) {

      if (tags[tagIndex] == imagesWithTags[imageIndex].tags[i]) break;
    }
    if (i >= imagesWithTags[imageIndex].tags.length) return; // non-existing tag

    imagesWithTags[imageIndex].tags.removeAt(i);
  }
}

class ImageTags {
  File? image;
  final List<String> tags;

  ImageTags(this.tags);
}