import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class CustomPhotoView extends StatefulWidget {
  const CustomPhotoView({Key? key, required this.imageUrl}) : super(key: key);
  final String imageUrl;
  @override
  _CustomPhotoViewState createState() => _CustomPhotoViewState();
}

class _CustomPhotoViewState extends State<CustomPhotoView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.imageUrl);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(
        child: PhotoView(
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
          imageProvider: NetworkImage(widget.imageUrl),
        ),
      ),
    );
  }
}

