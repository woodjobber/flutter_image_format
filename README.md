# flutter_image_format

A new Flutter project.

## Getting Started

```dart

  void main() async {
    final s.ByteData imageData =
    await s.rootBundle.load('assets/your_image.png');
    final imageInt8List = imageData.buffer.asUint8List();
    
    
    final imageFormat =
    ImageFormatHelper.imageFormatForImageUnit8List(
        imageInt8List);
  }
```