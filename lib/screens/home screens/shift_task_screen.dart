import 'package:flutter/material.dart';
import 'package:tact_tik/common/enums/shift_task_enums.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/screens/home%20screens/widgets/shift_task_type_widget.dart';

import '../../common/sizes.dart';
import '../../fonts/inter_regular.dart';
import '../../utils/colors.dart';

class ShiftTaskScreen extends StatelessWidget {
  const ShiftTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Shift Task',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / width30,
            // vertical: height / height30,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: height / height60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InterBold(
                        text: 'Westheimer',
                        fontsize: width / width18,
                        color: Primarycolor,
                      ),
                      InterBold(
                        text: '03/03',
                        fontsize: width / width18,
                        color: Primarycolor,
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: 5,
                  (context, index) {
                    List data = [ShiftTaskEnum.upload,ShiftTaskEnum.scan,ShiftTaskEnum.upload,ShiftTaskEnum.scan,ShiftTaskEnum.upload];
                    return ShiftTaskTypeWidget(
                      type: data[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
