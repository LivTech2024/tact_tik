import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tact_tik/main.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../common/widgets/setTextfieldWidget.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import '../../home screens/widgets/set_details_widget.dart';

class Guards {
  final String image;
  final String name;

  Guards(this.name, this.image);
}

class SCreateKeyManagScreen extends StatefulWidget {
  final String keyId;
  final String companyId;

  SCreateKeyManagScreen(
      {super.key, required this.keyId, required this.companyId});

  @override
  State<SCreateKeyManagScreen> createState() =>
      _SCreateAssignAssetScreenState();
}

class _SCreateAssignAssetScreenState extends State<SCreateKeyManagScreen> {
  List colors = isDark
      ? [DarkColor.Primarycolor, DarkColor.color25]
      : [LightColor.color3, LightColor.color2];
  bool isChecked = false;
  bool showCreate = true;

  DateTime? StartDate;
  DateTime? SelectedDate;
  DateTime? EndDate;
  String dropdownValue = 'Select';
  List<String> tittles = [];
  List selectedGuards = [];
  TextEditingController _tittleController = TextEditingController();
  TextEditingController _RecipientNameController = TextEditingController();
  TextEditingController _ContactController = TextEditingController();
  TextEditingController _CompanyNameController = TextEditingController();
  TextEditingController _AllocationPurposeController = TextEditingController();
  TextEditingController _AllocateQtController1 = TextEditingController();
  TextEditingController _AllocateQtController2 = TextEditingController();
  TextEditingController _keyNameController2 = TextEditingController();
  TextEditingController _DescriptionController = TextEditingController();

  String? selectedKeyName;
  String? selectedKeyId;
  List<DocumentSnapshot> keys = [];

  @override
  void initState() {
    super.initState();
    _fetchKeys();
  }

  Future<void> _fetchKeys() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Keys')
        .where('KeyCompanyId', isEqualTo: widget.companyId)
        .get();

    setState(() {
      keys = querySnapshot.docs;
    });
  }

  Future<void> _selectDate(
      BuildContext context, bool isStart, bool isDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        if (isStart) {
          StartDate = picked;
        } else if (isDate) {
          SelectedDate = picked;
        } else {
          EndDate = picked;
        }
      }
    });
  }

  Future<void> _saveData() async {
    CollectionReference keyAllocations =
        FirebaseFirestore.instance.collection('KeyAllocations');
    DocumentReference docRef = await keyAllocations.add({
      'KeyAllocationCreatedAt': FieldValue.serverTimestamp(),
      'KeyAllocationDate': FieldValue.serverTimestamp(),
      'KeyAllocationEndTime': 0,
      'KeyAllocationStartTime': 0,
      'KeyAllocationId': '',
      'KeyAllocationIsReturned': false,
      'KeyAllocationKeyId': selectedKeyId ?? '',
      'KeyAllocationKeyQty': int.tryParse(_AllocateQtController1.text) ?? 0,
      'KeyAllocationPurpose': _AllocationPurposeController.text,
      'KeyAllocationRecipientCompany': _CompanyNameController.text,
      'KeyAllocationRecipientContact': _ContactController.text,
      'KeyAllocationRecipientName': _RecipientNameController.text,
    });

    await docRef.update({
      'KeyAllocationId': docRef.id,
    });
  }
   final List<Guards> _screens = [
    Guards('Site Tours', 'Image URL'),
    Guards('DAR Screen', 'Image URL'),
    Guards('Reports Screen', 'Image URL'),
    Guards('Post Screen', 'Image URL'),
    Guards('Task Screen', 'Image URL'),
    Guards('LogBook Screen', 'Image URL'),
    Guards('Visitors Screen', 'Image URL'),
    Guards('Assets Screen', 'Image URL'),
    Guards('Key Screen', 'Image URL'),
  ];
  Widget gridLayoutBuilder(
      BuildContext context,
      List<Widget> items,
      ) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 58,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      reverse: SuggestionsController.of<Guards>(context).effectiveDirection ==
          VerticalDirection.up,
      itemBuilder: (context, index) => items[index],
    );
  }

  Future<List<Guards>> suggestionsCallback(String pattern) async =>
      Future<List<Guards>>.delayed(
        Duration(milliseconds: 300),
            () => _screens.where((product) {
          // print(product.name);
          final nameLower = product.name.toLowerCase().split(' ').join('');
          final patternLower = pattern.toLowerCase().split(' ').join('');
          return nameLower.contains(patternLower);
        }).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            isDark ? DarkColor.Secondarycolor : LightColor.Secondarycolor,
        appBar: AppBar(
          backgroundColor:
              isDark ? DarkColor.AppBarcolor : LightColor.AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? DarkColor.color1 : LightColor.color3,
              size: 24.w,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Keys Guards',
            fontsize: 18.sp,
            color: isDark ? DarkColor.color1 : LightColor.color3,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 65.h,
                    width: double.maxFinite,
                    color: isDark ? DarkColor.color24 : LightColor.WidgetColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showCreate = true;
                                colors[0] = isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.color3;
                                colors[1] = isDark
                                    ? DarkColor.color25
                                    : LightColor.color2;
                              });
                            },
                            child: Container(
                              color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                              child: Center(
                                child: InterBold(
                                  text: 'Assign',
                                  color: colors[0],
                                  fontsize: 18.w,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: VerticalDivider(
                            color: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.color3,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showCreate = false;
                                colors[0] = isDark
                                    ? DarkColor.color25
                                    : LightColor.color2;
                                colors[1] = isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.color3;
                              });
                            },
                            child: Container(
                              color: isDark ? DarkColor.WidgetColor : LightColor.WidgetColor,
                              child: Center(
                                child: InterBold(
                                  text: 'Create',
                                  color: colors[1],
                                  fontsize: 18.w,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  showCreate
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Select key',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                height: 60.h,
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.transparent
                                          : LightColor.color3.withOpacity(.05),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: isDark
                                      ? DarkColor.WidgetColor
                                      : LightColor.WidgetColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    iconSize: 24.sp,
                                    dropdownColor: isDark
                                        ? DarkColor.WidgetColor
                                        : LightColor.WidgetColor,
                                    style: TextStyle(
                                        color: isDark
                                            ? DarkColor.color2
                                            : LightColor.color3),
                                    borderRadius: BorderRadius.circular(10.r),
                                    value: dropdownValue,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownValue = newValue!;
                                        print('$dropdownValue selected');
                                      });
                                    },
                                    items: <String?>[...tittles]
                                        .map<DropdownMenuItem<String>>(
                                            (String? value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: InterMedium(text: value ?? ''),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Recipient Name',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                height: 64.h,
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.transparent
                                          : LightColor.color3.withOpacity(.05),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                  color: isDark
                                      ? DarkColor.WidgetColor
                                      : LightColor.WidgetColor,
                                  borderRadius: BorderRadius.circular(13.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TypeAheadField<Guards>(
                                        autoFlipDirection: true,
                                        controller: _RecipientNameController,
                                        direction: VerticalDirection.down,
                                        builder:
                                            (context, _controller, focusNode) =>
                                            TextField(
                                              controller: _controller,
                                              focusNode: focusNode,
                                              autofocus: false,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 18.w,
                                                color: Colors.white,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(10.r),
                                                  ),
                                                ),
                                                focusedBorder: InputBorder.none,
                                                hintStyle: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 18.w,
                                                  color: isDark
                                                      ? DarkColor.color2
                                                      : LightColor.color2,
                                                ),
                                                hintText: 'Search Guards',
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              cursorColor: isDark
                                                  ? DarkColor.Primarycolor
                                                  : LightColor.Primarycolor,
                                            ),
                                        suggestionsCallback: suggestionsCallback,
                                        itemBuilder: (context, Guards guards) {
                                          return ListTile(
                                            leading: Container(
                                              height: 30.h,
                                              width: 30.w,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDark
                                                    ? DarkColor.Primarycolor
                                                    : LightColor.Primarycolor,
                                              ),
                                            ),
                                            title: InterRegular(
                                              text: guards.name,
                                              color: isDark
                                                  ? DarkColor.color2
                                                  : LightColor.color2,
                                            ),
                                          );
                                        },
                                        emptyBuilder: (context) => Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 10.w,
                                          ),
                                          child: InterRegular(
                                            text: 'No Such Screen found',
                                            color: isDark
                                                ? DarkColor.color2
                                                : LightColor.color2,
                                            fontsize: 18.sp,
                                          ),
                                        ),
                                        decorationBuilder: (context, child) =>
                                            Material(
                                              type: MaterialType.card,
                                              elevation: 4,
                                              borderRadius: BorderRadius.circular(
                                                10.r,
                                              ),
                                              child: child,
                                            ),
                                        debounceDuration:
                                        const Duration(milliseconds: 300),
                                        onSelected: (Guards guard) {
                                          print(
                                              'home screen search bar############################################');

                                          print(guard.name);
                                        },
                                        listBuilder: gridLayoutBuilder,
                                      ),
                                    ),
                                    Container(
                                      height: 44.h,
                                      width: 44.w,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.search,
                                          size: 20.w,
                                          color: isDark
                                              ? DarkColor.Secondarycolor
                                              : LightColor.color1,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Container(
                                margin: EdgeInsets.only(top: 20.h),
                                height: 80.h,
                                width: double.maxFinite,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedGuards.length,
                                  itemBuilder: (context, index) {
                                    String guardId =
                                    selectedGuards[index]['GuardId'];
                                    String guardName =
                                    selectedGuards[index]['GuardName'];
                                    String guardImg =
                                    selectedGuards[index]['GuardImg'];
                                    return Padding(
                                      padding:
                                      EdgeInsets.only(right: 20.h),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                height: 50.h,
                                                width: 50.w,
                                                decoration: guardImg != ""
                                                    ? BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        guardImg ?? ""),
                                                    filterQuality:
                                                    FilterQuality.high,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                    : BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isDark
                                                      ? DarkColor.Primarycolor
                                                      : LightColor.Primarycolor,
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/images/default.png'),
                                                    filterQuality:
                                                    FilterQuality.high,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: -4,
                                                right: -5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedGuards
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 20.h,
                                                    width: 20.w,
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
                                          SizedBox(height: 8.h),
                                          InterBold(
                                            text: guardName,
                                            fontsize: 14.sp,
                                            color:  isDark
                                                ? DarkColor.color26
                                                : LightColor.color3,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Contact',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                maxlength: 11,
                                hint: '12345678901',
                                controller: _ContactController,
                                showIcon: false,
                                textInputType: TextInputType.number,
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Company Name',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Eg. Tacttik',
                                controller: _CompanyNameController,
                                showIcon: false,
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Allocate Qt.',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: '0',
                                controller: _AllocateQtController1,
                                showIcon: false,
                                textInputType: TextInputType.number,
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Date',
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                fontsize: 16.w,
                              ),
                              SizedBox(height: 10.h),
                              GestureDetector(
                                onTap: () {
                                  _selectDate(context, true, true);
                                },
                                child: Container(
                                  height: 60.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: isDark
                                        ? DarkColor.WidgetColor
                                        : LightColor.WidgetColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InterMedium(
                                        text: SelectedDate != null
                                            ? '${SelectedDate!.toLocal()}'
                                                .split(' ')[0]
                                            : 'Start Time',
                                        fontsize: 16.w,
                                        color: isDark
                                            ? DarkColor.color2
                                            : LightColor.color2,
                                      ),
                                      SvgPicture.asset(
                                        'assets/images/calendar_clock.svg',
                                        width: 20.w,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Allocation Date',
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                                fontsize: 16.sp,
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectDate(context, true, false);
                                      },
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: isDark
                                              ? DarkColor.WidgetColor
                                              : LightColor.WidgetColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InterMedium(
                                              text: StartDate != null
                                                  ? '${StartDate!.toLocal()}'
                                                      .split(' ')[0]
                                                  : 'Start Time',
                                              fontsize: 16.sp,
                                              color: isDark
                                                  ? DarkColor.color2
                                                  : LightColor.color2,
                                            ),
                                            SvgPicture.asset(
                                              'assets/images/calendar_clock.svg',
                                              width: 20.w,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _selectDate(context, false, false);
                                      },
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: isDark
                                              ? DarkColor.WidgetColor
                                              : LightColor.WidgetColor,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            InterMedium(
                                              text: EndDate != null
                                                  ? '${EndDate!.toLocal()}'
                                                      .split(' ')[0]
                                                  : 'End Time',
                                              fontsize: 16.w,
                                              color: isDark
                                                  ? DarkColor.color2
                                                  : LightColor.color2,
                                            ),
                                            SvgPicture.asset(
                                              'assets/images/calendar_clock.svg',
                                              width: 20.w,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              InterBold(
                                text: 'Allocation Purpose',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Write something...',
                                controller: _AllocationPurposeController,
                                showIcon: true,
                                isExpanded: true,
                              ),
                              SizedBox(height: 20.h),
                              Button1(
                                text: 'Save',
                                onPressed: () {
                                  _saveData();
                                },
                                borderRadius: 10.r,
                                backgroundcolor: isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor,
                              ),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InterBold(
                                text: 'Key Name',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Tittle',
                                controller: _keyNameController2,
                                showIcon: true,
                              ),
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Allocate Qt.',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: '0',
                                controller: _AllocateQtController2,
                                showIcon: false,
                                textInputType: TextInputType.number,
                              ),
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Description',
                                fontsize: 16.w,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Write something...',
                                controller: _DescriptionController,
                                showIcon: true,
                                isExpanded: true,
                              ),
                              SizedBox(
                                height: 40.h,
                              ),
                              Button1(
                                text: 'Save',
                                onPressed: () {
                                  _saveData();
                                },
                                borderRadius: 10.r,
                                backgroundcolor: isDark
                                    ? DarkColor.Primarycolor
                                    : LightColor.Primarycolor,
                              ),
                              SizedBox(
                                height: 20.h,
                              )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
