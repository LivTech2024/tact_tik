import 'package:flutter/material.dart';
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/create_post_order_screen.dart';

import '../../../utils/colors.dart';

class PostOrderScreen extends StatelessWidget {
  const PostOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [

          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePostOrderScreen(),
                ));
          },
          backgroundColor: Primarycolor,
          shape: CircleBorder(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
