import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageListDialog extends StatefulWidget {
  final List<Map<String, dynamic>> uploads;

  const ImageListDialog({Key? key, required this.uploads}) : super(key: key);

  @override
  _ImageListDialogState createState() => _ImageListDialogState();
}

class _ImageListDialogState extends State<ImageListDialog> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.uploads.asMap().entries.map((entry) {
              final index = entry.key;
              final upload = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(8),
                    child: upload['type'] == 'image'
                        ? Image.file(
                            upload['file'],
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.videocam),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.uploads.removeAt(index);
                        });
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Add Image'),
                    onTap: () {
                      // Implement logic to add image
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text('Add from Gallery'),
                    onTap: () {
                      // Implement logic to add image from gallery
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
