import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/setTextfieldWidget.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import '../../home screens/widgets/set_details_widget.dart';

class SCreateAssignAssetScreen extends StatefulWidget {
  SCreateAssignAssetScreen({super.key});

  @override
  State<SCreateAssignAssetScreen> createState() =>
      _SCreateAssignAssetScreenState();
}

class _SCreateAssignAssetScreenState extends State<SCreateAssignAssetScreen> {
  List colors = [DarkColor.Primarycolor, DarkColor.color25];
  bool isChecked = false;
  bool showCreate = false;
  TextEditingController _tittleController1 = TextEditingController();
  TextEditingController _tittleController2 = TextEditingController();
  TextEditingController _AllocateQtController1 = TextEditingController();
  TextEditingController _AllocateQtController2 = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkColor.Secondarycolor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: DarkColor. color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showCreate = true;
                            colors[0] = DarkColor. Primarycolor;
                            colors[1] = DarkColor.color25;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Edit',
                              color: colors[0],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: DarkColor. Primarycolor,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showCreate = false;
                            colors[0] = DarkColor.color25;
                            colors[1] = DarkColor.Primarycolor;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Reports',
                              color: colors[1],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: height / height20),
              showCreate
                  ? Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'Select Guards',
                                fontsize: width / width16,
                                color: DarkColor.color1,
                              ),
                              TextButton(
                                onPressed: () {
                                  /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SelectGuardsScreen(
                                                companyId: widget.CompanyId,
                                              ))).then((value) => {
                                    if (value != null)
                                      {
                                        print("Value: ${value}"),
                                        setState(() {
                                          // selectedGuards.add({
                                          //   'GuardId': value['id'],
                                          //   'GuardName': value['name'],
                                          //   'GuardImg': value['url']
                                          // });
                                        }),
                                      }
                                  });*/
                                },
                                child: InterBold(
                                  text: 'view all',
                                  fontsize: width / width14,
                                  color: DarkColor.color1,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: height / height24),
                          Container(
                            height: height / height64,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width10),
                            decoration: BoxDecoration(
                              color: DarkColor.WidgetColor,
                              borderRadius:
                              BorderRadius.circular(width / width13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: width / width18,
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(width / width10),
                                        ),
                                      ),
                                      focusedBorder: InputBorder.none,
                                      hintStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: width / width18,
                                        color:
                                        DarkColor
                                            .color2, // Change text color to white
                                      ),
                                      hintText: 'Search Guard',
                                      contentPadding:
                                      EdgeInsets.zero, // Remove padding
                                    ),
                                    cursorColor: DarkColor. Primarycolor,
                                  ),
                                ),
                                Container(
                                  height: height / height44,
                                  width: width / width44,
                                  decoration: BoxDecoration(
                                    color: DarkColor.Primarycolor,
                                    borderRadius:
                                    BorderRadius.circular(width / width10),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: width / width20,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: height / height20),
                            height: height / height80,
                            width: double.maxFinite,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 0,
                              itemBuilder: (context, index) {
                                // String guardId =
                                // selectedGuards[index]['GuardId'];
                                // String guardName =
                                // selectedGuards[index]['GuardName'];
                                // String guardImg =
                                // selectedGuards[index]['GuardImg'];
                                return Padding(
                                  padding:
                                  EdgeInsets.only(right: height / height20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: height / height50,
                                            width: width / width50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: NetworkImage('guardImg'),
                                                  fit: BoxFit.fitWidth),
                                            ),
                                          ),
                                          Positioned(
                                            top: -4,
                                            right: -5,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  // selectedGuards
                                                  //     .removeAt(index);
                                                });
                                              },
                                              child: Container(
                                                height: height / height20,
                                                width: width / width20,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DarkColor.color1),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 8,
                                                    color: DarkColor
                                                        .Secondarycolor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: height / height8),
                                      InterBold(
                                        text: 'guardName',
                                        fontsize: width / width14,
                                        color: DarkColor.color26,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: height / height20),
                          InterBold(
                            text: 'Select equipment',
                            fontsize: width / width16,
                            color: DarkColor.color1,
                          ),
                          SizedBox(height: height / height10),
                          CustomeTextField(
                            hint: 'Title',
                            controller: _tittleController1,
                            showIcon: true,
                          ),
                          SizedBox(height: height / height20),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: width / width16,
                            color: DarkColor.color1,
                          ),
                          SizedBox(height: height / height10),
                          CustomeTextField(
                            hint: '0',
                            controller: _AllocateQtController1,
                            showIcon: true,
                          ),
                          SizedBox(height: height / height20),
                          InterBold(
                            text: 'Allocation Date',
                            color: DarkColor.color1,
                            fontsize: width / width16,
                          ),
                          SizedBox(height: height / height10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: height / height60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(width / width10),
                                    color: DarkColor.WidgetColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      InterMedium(text: '21 / 04 / 2024',
                                        fontsize: width / width16,
                                        color: DarkColor. color2,),
                                      SvgPicture.asset('assets/images/calendar_clock.svg',
                                        width: width / width20,)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: width / width6),
                              Expanded(
                                child: Container(
                                  height: height / height60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(width / width10),
                                    color: DarkColor. WidgetColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      InterMedium(text: '22 / 04 / 2024',
                                        fontsize: width / width16,
                                        color: DarkColor. color2,),
                                      SvgPicture.asset('assets/images/calendar_clock.svg',
                                        width: width / width20,)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height / height20),
                          Container(
                            height: height / height60,
                            padding:
                            EdgeInsets.symmetric(horizontal: width / width20),
                            decoration: BoxDecoration(
                              color: DarkColor. WidgetColor,
                              borderRadius: BorderRadius.circular(width / width10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: width / width24,
                                    ),
                                    SizedBox(width: width / width6),
                                    InterMedium(
                                      text: 'Asset Returned ?',
                                      color: DarkColor.color8,
                                      fontsize: width / width16,
                                      letterSpacing: -.3,
                                    )
                                  ],
                                ),
                                Checkbox(
                                  activeColor: DarkColor.Primarycolor,
                                  checkColor: DarkColor. color1,
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = !isChecked;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / width30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height / height10),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: width / width16,
                            color: DarkColor.color1,
                          ),
                          SizedBox(height: height / height10),
                          CustomeTextField(
                            hint: 'Title',
                            controller: _tittleController2,
                            showIcon: true,
                          ),
                          SizedBox(height: height / height10),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: width / width16,
                            color: DarkColor.color1,
                          ),
                          SizedBox(height: height / height10),
                          CustomeTextField(
                            hint: '0',
                            controller: _AllocateQtController2,
                          ),
                          SizedBox(height: height / height10),
                          InterBold(
                            text: 'Description',
                            fontsize: width / width16,
                            color: DarkColor.color1,
                          ),
                          SizedBox(height: height / height10),
                          CustomeTextField(
                            hint: 'Write something about asset...',
                            controller: _DescriptionController,
                            showIcon: true,
                          ),
                        ],
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
