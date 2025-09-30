import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_sticker_app/component/main_app_bar.dart';
import 'package:photo_sticker_app/component/main_footer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_sticker_app/model/sticker_model.dart';
import 'package:photo_sticker_app/component/emotion_sticker.dart';
import 'package:flutter/rendering.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  Set<StickerModel> stickers = {};
  String? selectedID;
  GlobalKey imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          renderBody(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MainAppBar(
              onPickImage: onPickImage,
              onSaveImage: onSaveImage,
              onDeleteImage: onDeleteImage,
            ),
          ),
          if (image != null)
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: MainFooter(onEmoticonTap: onEmoticonTap),
            ),
        ],
      ),
    );
  }

  Widget renderBody() {
    if (image != null) {
      return RepaintBoundary(
        key: imgKey,
        child: Positioned.fill(
          child: InteractiveViewer(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(image!.path), fit: BoxFit.cover),
                ...stickers.map(
                  (sticker) => Center(
                    child: EmotionSticker(
                      key: ObjectKey(sticker.id),
                      onTransform: () {
                        onTransForm(sticker.id);
                      },
                      imgPath: sticker.imgPath,
                      isSelected: selectedID == sticker.id,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
          onPressed: onPickImage,
          child: Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onEmoticonTap(int index) async {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(id: Uuid().v4(), imgPath: 'asset/img/emoticon_$index.png'),
      };
    });
  }

  void onTransForm(String id) {
    setState(() {
      selectedID = id;
    });
  }

  void onPickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      this.image = image;
    });
  }

  void onSaveImage() async {
    RenderRepaintBoundary boundary =
        imgKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List pngBytes = byteData!.buffer.asUint8List();

    await ImageGallerySaverPlus.saveImage(pngBytes, quality: 100);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("저장되었습니다!")));
  }

  void onDeleteImage() async {
    setState(() {
      stickers = stickers.where((sticker) => sticker.id != selectedID).toSet();
    });
  }
}
