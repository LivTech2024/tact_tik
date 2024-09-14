import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoGrid extends StatefulWidget {
  final List<Map<String, dynamic>> displayVideo;
  final Function(int) onDelete; // Callback function to handle delete action

  VideoGrid({required this.displayVideo, required this.onDelete});

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant VideoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayVideo.length != oldWidget.displayVideo.length) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    // Dispose of existing controllers
    for (var controller in _controllers) {
      controller.dispose();
    }

    // Initialize new controllers
    _controllers = widget.displayVideo.map((video) {
      final url = video['url'];
      if (url != null && url.isNotEmpty) {
        final controller = VideoPlayerController.network(url);
        controller.initialize().then((_) {
          if (mounted) {
            setState(() {}); // Refresh the UI when the controller is ready
          }
        }).catchError((error) {
          print('Error initializing video controller: $error');
        });
        return controller;
      } else {
        // Handle null or empty URL case
        return VideoPlayerController.network(''); // Placeholder
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: widget.displayVideo.length,
            itemBuilder: (context, index) {
              if (index >= _controllers.length) {
                return Center(child: CircularProgressIndicator());
              }
              final controller = _controllers[index];

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.black,
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: controller.value.isInitialized
                          ? Image(
                              image: NetworkImage(
                                controller.dataSource,
                                // Optional, if required by the server
                              ),
                              fit: BoxFit.cover,
                            )
                          : Center(
                              // child:
                              // CircularProgressIndicator()

                              ), // Placeholder while loading
                    ),
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          widget.onDelete(index); // Call the delete callback
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
