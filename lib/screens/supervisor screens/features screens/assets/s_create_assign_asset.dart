import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
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

class SCreateAssignAssetScreen extends StatefulWidget {
  final String companyId;
  final String empId;
  final bool OnlyView;
  final String equipemtAllocId;

  SCreateAssignAssetScreen(
      {super.key,
      required this.companyId,
      required this.empId,
      this.OnlyView = false,
      required this.equipemtAllocId});

  @override
  State<SCreateAssignAssetScreen> createState() =>
      _SCreateAssignAssetScreenState();
}

class _SCreateAssignAssetScreenState extends State<SCreateAssignAssetScreen> {
  List colors = [DarkColor.Primarycolor, DarkColor.color25];
  bool isChecked = false;
  bool showCreate = true;
  TextEditingController _titleController1 = TextEditingController();
  TextEditingController _titleController2 = TextEditingController();
  TextEditingController _allocateQtController1 = TextEditingController();
  TextEditingController _allocateQtController2 = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String? selectedGuardId;
  String? selectedEquipmentId;
  String? selectedEquipmentName;
  DateTime? StartDate;
  DateTime? EndDate;

  List<Map<String, dynamic>> guards = [];
  List<DocumentSnapshot> equipment = [];

  @override
  void initState() {
    super.initState();
    fetchEquipmentAllocationData();
    fetchEquipment();
  }

  Future<void> fetchEquipmentAllocationData() async {
    if (widget.empId.isNotEmpty) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('EquipmentAllocations')
          .where('EquipmentAllocationEmpId', isEqualTo: widget.empId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;
        setState(() async {
          _allocateQtController1.text =
              document['EquipmentAllocationEquipQty'].toString();
          isChecked = document['EquipmentAllocationIsReturned'];
          StartDate = (document['EquipmentAllocationStartDate'] as Timestamp)
              .toDate()
              .toLocal();
          EndDate = (document['EquipmentAllocationEndDate'] as Timestamp)
              .toDate()
              .toLocal();

          String employeeId = document['EquipmentAllocationEmpId'];
          DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
              .collection('Employees')
              .doc(employeeId)
              .get();
          _searchController.text = employeeSnapshot['EmployeeName'];
          selectedGuardId = employeeId;

          String equipmentId = document['EquipmentAllocationEquipId'];
          DocumentSnapshot equipmentSnapshot = await FirebaseFirestore.instance
              .collection('Equipments')
              .doc(equipmentId)
              .get();
          selectedEquipmentName = equipmentSnapshot['EquipmentName'];
          selectedEquipmentId = equipmentId;
        });
      }
    }
  }

  Future<void> searchGuards(String query) async {
    if (query.isEmpty) {
      setState(() {
        guards.clear();
      });
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('Employees')
        .where('EmployeeRole', isEqualTo: 'GUARD')
        .where('EmployeeCompanyId', isEqualTo: widget.companyId)
        .where('EmployeeNameSearchIndex', arrayContains: query)
        .get();

    setState(() {
      guards = result.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> fetchEquipment() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Equipments')
        .where('EquipmentCompanyId', isEqualTo: widget.companyId)
        .get();

    setState(() {
      equipment = querySnapshot.docs;
    });
  }

  Future<void> createEquipmentAllocation() async {
    CollectionReference equipmentAllocations =
        FirebaseFirestore.instance.collection('EquipmentAllocations');
    DocumentReference docRef = await equipmentAllocations.add({
      'EquipmentAllocationCreatedAt': FieldValue.serverTimestamp(),
      'EquipmentAllocationDate': FieldValue.serverTimestamp(),
      'EquipmentAllocationEmpId': selectedGuardId ?? '',
      'EquipmentAllocationEndDate': FieldValue.serverTimestamp(),
      'EquipmentAllocationStartDate': FieldValue.serverTimestamp(),
      'EquipmentAllocationEquipId': selectedEquipmentId ?? '',
      'EquipmentAllocationEquipQty': _allocateQtController1.text.isNotEmpty
          ? int.parse(_allocateQtController1.text)
          : 0,
      'EquipmentAllocationIsReturned': isChecked,
      'EquipmentAllocationId': '', // Initialize with an empty string
    });

    // Update the document with the generated document reference ID
    await docRef.update({
      'EquipmentAllocationId': docRef.id,
    });
  }

  Future<void> updateEquipmentAllocation() async {
    CollectionReference equipmentAllocations =
        FirebaseFirestore.instance.collection('EquipmentAllocations');
    await equipmentAllocations.doc(widget.equipemtAllocId).update({
      'EquipmentAllocationIsReturned': isChecked,
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) {
        if (isStart) {
          StartDate = picked;
        } else {
          EndDate = picked;
        }
      }
    });
  }

  final TextEditingController _controller = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).canvasColor,
        appBar: AppBar(
      
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              
            ),
            padding: EdgeInsets.only(left: width / width20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterMedium(
            text: 'Assets',
         
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 65.h,
                width: double.maxFinite,
                color: isDark ? DarkColor.color24 : LightColor.WidgetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
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
                                : LightColor.Primarycolor;
                            colors[1] =
                                isDark ? DarkColor.color25 : LightColor.color2;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Assign',
                              color: colors[0],
                              fontsize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color:
                          isDark ? DarkColor.Primarycolor : LightColor.color3,
                    ),
                    Expanded(
                      child: IgnorePointer(
                        ignoring: widget.OnlyView,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showCreate = false;
                              colors[0] = isDark
                                  ? DarkColor.color25
                                  : LightColor.color2;
                              colors[1] = isDark
                                  ? DarkColor.Primarycolor
                                  : LightColor.Primarycolor;
                            });
                          },
                          child: SizedBox(
                            child: Center(
                              child: InterBold(
                                text: 'Create',
                                color: colors[1],
                                fontsize: 18.sp,
                              ),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'Select Guards',
                                fontsize: 16.sp,
                                color: isDark
                                    ? DarkColor.color1
                                    : LightColor.color3,
                              ),
                              IgnorePointer(
                                ignoring: widget.OnlyView,
                                child: TextButton(
                                  onPressed: () async {
                                    final result = await FirebaseFirestore
                                        .instance
                                        .collection('Employees')
                                        .where('EmployeeRole',
                                            isEqualTo: 'GUARD')
                                        .where('EmployeeCompanyId',
                                            isEqualTo: widget.companyId)
                                        .get();

                                    setState(() {
                                      guards = result.docs
                                          .map((doc) => doc.data())
                                          .toList();
                                    });
                                  },
                                  child: InterBold(
                                    text: 'view all',
                                    fontsize: 14.sp,
                                    color: isDark
                                        ? DarkColor.color1
                                        : LightColor.color3,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            height: 64.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(13.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TypeAheadField<Guards>(
                                    autoFlipDirection: true,
                                    controller: _controller,
                                    direction: VerticalDirection.down,
                                    builder:
                                        (context, _controller, focusNode) =>
                                            TextField(
                                      controller: _controller,
                                      focusNode: focusNode,
                                      autofocus: false,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w300,
                                        fontSize: width / width18,
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
                                          fontSize: width / width18,
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
                                    borderRadius:
                                        BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: 20.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: guards.length,
                            itemBuilder: (context, index) {
                              final guard = guards[index];
                              return ListTile(
                                title: Text(guard['EmployeeName']),
                                onTap: () {
                                  setState(() {
                                    _searchController.text =
                                        guard['EmployeeName'];
                                    selectedGuardId = guard['EmployeeId'];
                                    guards.clear();
                                  });
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Select equipment',
                            fontsize: 16.sp,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          IgnorePointer(
                            ignoring: widget.OnlyView,
                            child: DropdownButtonFormField<String>(
                              value: selectedEquipmentName,
                              items: equipment.map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: data['EquipmentName'],
                                  child: InterRegular(
                                    text: data['EquipmentName'],
                                    color: isDark
                                        ? DarkColor.color3
                                        : LightColor.color2,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedEquipmentName = newValue;
                                  selectedEquipmentId = equipment
                                      .firstWhere((document) =>
                                          (document.data() as Map<String,
                                              dynamic>)['EquipmentName'] ==
                                          newValue)
                                      .id;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Select Equipment',
                                hintStyle: TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(13.w),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: 16.sp,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            isEnabled: !widget.OnlyView,
                            hint: '0',
                            controller: _allocateQtController1,
                            showIcon: true,
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Allocation Date',
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                            fontsize: 16.sp,
                          ),
                          SizedBox(height: 10.h),
                          IgnorePointer(
                            ignoring: widget.OnlyView,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _selectDate(context, true);
                                    },
                                    child: Container(
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.r),
                                        color: Theme.of(context).cardColor,
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
                                      _selectDate(context, false);
                                    },
                                    child: Container(
                                      height: 60.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10.r),
                                        color: Theme.of(context).cardColor,
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
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InterBold(
                                      text: 'Select Guards',
                                      fontsize: width / width16,
                                      color: isDark
                                          ? DarkColor.color1
                                          : LightColor.color3,
                                    ),
                                    IgnorePointer(
                                      ignoring: widget.OnlyView,
                                      child: TextButton(
                                        onPressed: () async {
                                          final result = await FirebaseFirestore
                                              .instance
                                              .collection('Employees')
                                              .where('EmployeeRole',
                                                  isEqualTo: 'GUARD')
                                              .where('EmployeeCompanyId',
                                                  isEqualTo: widget.companyId)
                                              .get();

                                          setState(() {
                                            guards = result.docs
                                                .map((doc) => doc.data())
                                                .toList();
                                          });
                                        },
                                        child: InterBold(
                                          text: 'view all',
                                          fontsize: width / width14,
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3,
                                        ),
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius:
                                        BorderRadius.circular(width / width13),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          enabled: !widget.OnlyView,
                                          controller: _searchController,
                                          onChanged: (query) {
                                            searchGuards(query);
                                          },
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w300,
                                            fontSize: width / width18,
                                            color: isDark
                                                ? DarkColor.color1
                                                : LightColor.color3,
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    width / width10),
                                              ),
                                            ),
                                            focusedBorder: InputBorder.none,
                                            hintStyle: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w300,
                                              fontSize: width / width18,
                                              color: isDark
                                                  ? DarkColor.color2
                                                  : LightColor.color3,
                                            ),
                                            hintText: 'Search Guard',
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          cursorColor: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                        ),
                                      ),
                                      Container(
                                        height: height / height44,
                                        width: width / width44,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? DarkColor.Primarycolor
                                              : LightColor.Primarycolor,
                                          borderRadius: BorderRadius.circular(
                                              width / width10),
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
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: guards.length,
                                  itemBuilder: (context, index) {
                                    final guard = guards[index];
                                    return ListTile(
                                      title: Text(guard['EmployeeName']),
                                      onTap: () {
                                        setState(() {
                                          _searchController.text =
                                              guard['EmployeeName'];
                                          selectedGuardId = guard['EmployeeId'];
                                          guards.clear();
                                        });
                                      },
                                    );
                                  },
                                ),
                                SizedBox(height: height / height20),
                                InterBold(
                                  text: 'Select equipment',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                                SizedBox(height: height / height10),
                                IgnorePointer(
                                  ignoring: widget.OnlyView,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedEquipmentName,
                                    items: equipment
                                        .map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document
                                          .data() as Map<String, dynamic>;
                                      return DropdownMenuItem<String>(
                                        value: data['EquipmentName'],
                                        child: InterRegular(
                                          text: data['EquipmentName'],
                                          color: isDark
                                              ? DarkColor.color3
                                              : LightColor.color2,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedEquipmentName = newValue;
                                        selectedEquipmentId = equipment
                                            .firstWhere((document) =>
                                                (document.data() as Map<String,
                                                        dynamic>)[
                                                    'EquipmentName'] ==
                                                newValue)
                                            .id;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Select Equipment',
                                      hintStyle: TextStyle(
                                          color: isDark
                                              ? DarkColor.color1
                                              : LightColor.color3),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            width / width13),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height / height20),
                                InterBold(
                                  text: 'Allocate Qt.',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                                SizedBox(height: height / height10),
                                CustomeTextField(
                                  isEnabled: !widget.OnlyView,
                                  hint: '0',
                                  controller: _allocateQtController1,
                                  showIcon: true,
                                ),
                                SizedBox(height: height / height20),
                                InterBold(
                                  text: 'Allocation Date',
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                  fontsize: width / width16,
                                ),
                                SizedBox(height: height / height10),
                                IgnorePointer(
                                  ignoring: widget.OnlyView,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _selectDate(context, true);
                                          },
                                          child: Container(
                                            height: height / height60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                              color: Theme.of(context).cardColor,
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
                                                  fontsize: width / width16,
                                                  color: isDark
                                                      ? DarkColor.color1
                                                      : LightColor.color3,
                                                ),
                                                SvgPicture.asset(
                                                  'assets/images/calendar_clock.svg',
                                                  width: width / width20,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: width / width6),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _selectDate(context, false);
                                          },
                                          child: Container(
                                            height: height / height60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      width / width10),
                                              color: Theme.of(context).cardColor,
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
                                                  fontsize: width / width16,
                                                  color: isDark
                                                      ? DarkColor.color2
                                                      : LightColor.color3,
                                                ),
                                                SvgPicture.asset(
                                                  'assets/images/calendar_clock.svg',
                                                  width: width / width20,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height / height20),
                                Container(
                                  height: height / height60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width / width20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius:
                                        BorderRadius.circular(width / width10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        activeColor: isDark
                                            ? DarkColor.Primarycolor
                                            : LightColor.Primarycolor,
                                        checkColor: DarkColor.color1,
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height / height40),
                                IgnorePointer(
                                  ignoring: widget.OnlyView
                                      ? isChecked == false
                                          ? true
                                          : false
                                      : true,
                                  child: Button1(
                                    text: 'Done',
                                    onPressed: () {
                                      createEquipmentAllocation();
                                    },
                                    backgroundcolor: isDark
                                        ? (widget.OnlyView
                                            ? isChecked == false
                                                ? DarkColor.Primarycolorlight
                                                : DarkColor.Primarycolor
                                            : DarkColor.Primarycolorlight)
                                        : (widget.OnlyView
                                            ? isChecked == false
                                                ? LightColor.Primarycolor
                                                : LightColor.Primarycolor
                                            : LightColor.Primarycolorlight),
                                    borderRadius: width / width10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width / width30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: height / height10),
                                InterBold(
                                  text: 'Allocate Qt.',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                                SizedBox(height: height / height10),
                                CustomeTextField(
                                  hint: 'Title',
                                  controller: _titleController2,
                                  showIcon: true,
                                ),
                                SizedBox(height: height / height10),
                                InterBold(
                                  text: 'Allocate Qt.',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                                SizedBox(height: height / height10),
                                CustomeTextField(
                                  hint: '0',
                                  controller: _allocateQtController2,
                                ),
                                SizedBox(height: height / height10),
                                InterBold(
                                  text: 'Description',
                                  fontsize: width / width16,
                                  color: isDark
                                      ? DarkColor.color1
                                      : LightColor.color3,
                                ),
                                SizedBox(height: height / height10),
                                CustomeTextField(
                                  hint: 'Write something about asset...',
                                  controller: _descriptionController,
                                  showIcon: true,
                                ),
                                SizedBox(height: height / height40),
                                Button1(
                                  text: 'Done',
                                  onPressed: () {
                                    createEquipmentAllocation();
                                  },
                                  backgroundcolor: isDark
                                      ? DarkColor.Primarycolor
                                      : LightColor.Primarycolor,
                                  borderRadius: width / width10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40.h),
                          IgnorePointer(
                            ignoring: widget.OnlyView
                                ? isChecked == false
                                    ? true
                                    : false
                                : true,
                            child: Button1(
                              text: 'Save',
                              onPressed: () {
                                createEquipmentAllocation();
                              },
                              backgroundcolor: widget.OnlyView
                                  ? isChecked == false
                                      ? isDark
                                          ? DarkColor.Primarycolorlight
                                          : LightColor.Primarycolorlight
                                      : isDark
                                          ? DarkColor.Primarycolor
                                          : LightColor.Primarycolor
                                  : isDark
                                      ? DarkColor.Primarycolorlight
                                      : LightColor.Primarycolorlight,
                              borderRadius: width / width10,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: 16.sp,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            hint: 'Title',
                            controller: _titleController2,
                            showIcon: true,
                          ),
                          SizedBox(height:10.sp),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: width / width16,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            hint: '0',
                            controller: _allocateQtController2,
                          ),
                          SizedBox(height: 10.h),
                          InterBold(
                            text: 'Description',
                            fontsize: width / width16,
                            color:
                                isDark ? DarkColor.color1 : LightColor.color3,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            hint: 'Write something about asset...',
                            controller: _descriptionController,
                            showIcon: true,
                          ),
                          SizedBox(height: 40.h),
                          Button1(
                            text: 'Save',
                            onPressed: () {
                              createEquipmentAllocation();
                            },
                            backgroundcolor: isDark
                                ? DarkColor.Primarycolor
                                : LightColor.Primarycolor,
                            borderRadius: width / width10,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
