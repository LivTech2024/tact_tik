import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoGrid extends StatefulWidget {
  final List<Map<String, dynamic>> displayVideo;

  VideoGrid({required this.displayVideo});

  @override
  _VideoGridState createState() => _VideoGridState();
}

class _VideoGridState extends State<VideoGrid> {
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var video in widget.displayVideo) {
      _controllers.add(VideoPlayerController.network(video['url']!)
        ..initialize().then((_) {
          setState(() {}); // Ensure the first frame is shown
        }));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: widget.displayVideo.length,
      itemBuilder: (context, index) {
        final controller = _controllers[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.black,
          ),
          child: controller.value.isInitialized
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: VideoProgressIndicator(controller,
                          allowScrubbing: true),
                    ),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.value.isPlaying
                                ? controller.pause()
                                : controller.play();
                          });
                        },
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
