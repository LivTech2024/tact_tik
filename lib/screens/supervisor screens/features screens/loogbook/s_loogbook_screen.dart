import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/screens/feature%20screens/Log%20Book/widget/log_type_widget.dart';

import '../../../../common/enums/log_type_enums.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';


class LogBookScreen extends StatefulWidget {
  const LogBookScreen({super.key});

  @override
  State<LogBookScreen> createState() => _LogBookScreenState();
}

class _LogBookScreenState extends State<LogBookScreen> {
  List<Logs> logs = [
    Logs(type: 'type', clintName: 'clintName', location: 'location'),
    Logs(type: 'type', clintName: 'clintName', location: 'location'),
    Logs(type: 'type', clintName: 'clintName', location: 'location'),
    Logs(type: 'type', clintName: 'clintName', location: 'location'),
  ];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: height / height30,
            ),
          ),
          SliverAppBar(
            backgroundColor: AppBarcolor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: width / width24,
              ),
              padding: EdgeInsets.only(left: width / width20),
              onPressed: () {
                Navigator.pop(context);
                print("Navigtor debug: ${Navigator.of(context).toString()}");
              },
            ),
            title: InterRegular(
              text: 'LogBook',
              fontsize: width / width18,
              color: Colors.white,
              letterSpacing: -.3,
            ),
            centerTitle: true,
            floating: true, // Makes the app bar float above the content
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return LogBookWidget(
                  logs: logs,
                );
              },
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class LogBookWidget extends StatefulWidget {
  final List<Logs> logs;

  const LogBookWidget({super.key, required this.logs});

  @override
  State<LogBookWidget> createState() => _LogBookWidgetState();
}

class _LogBookWidgetState extends State<LogBookWidget> {
  bool expand = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / width30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expand = !expand;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: height / height10),
              padding: EdgeInsets.symmetric(horizontal: width / width20),
              height: height / height70,
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width / width10),
                color: WidgetColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InterBold(
                    text: '15/04/2023',
                    color: Primarycolor,
                    fontsize: width / width18,
                  ),
                  Icon(
                    expand
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    size: width / width24,
                    color: Primarycolor,
                  )
                ],
              ),
            ),
          ),
          if (expand)
            Padding(
              padding: EdgeInsets.symmetric(vertical: height / height10),
              child: Flexible(
                child: InterBold(text: 'Shift Name Here' , fontsize: width / width18,color: Primarycolor,),
              ),
            ),
          Visibility(
            visible: expand,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.logs.map((l) {
                return LogTypeWidget(
                  type: LogBookEnum.CheckPoint,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Logs {
  final String type;
  final String location;
  final String clintName;

  Logs({
    required this.type,
    required this.clintName,
    required this.location,
  });
}
