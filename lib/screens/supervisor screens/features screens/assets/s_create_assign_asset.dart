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
import 'package:tact_tik/screens/supervisor%20screens/features%20screens/assets/select_assets_guards.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../common/widgets/setTextfieldWidget.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import '../../home screens/widgets/set_details_widget.dart';
import 's_assets_view_screen.dart';

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
  List selectedGuards = [];

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
  String? selectedBranch;
  DateTime? StartDate;
  DateTime? EndDate;

  List<Map<String, dynamic>> guards = [];
  List<DocumentSnapshot> equipment = [];
  List selectedGuards = [];

  initColors(BuildContext context) {
    return [
      Theme.of(context).textTheme.bodySmall!.color,
      Theme.of(context).highlightColor,
    ];
  }

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
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            padding: EdgeInsets.only(left: 20.w),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? DarkColor.color24
                    : LightColor.WidgetColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showCreate = true;
                            colors[0] = Theme.of(context).primaryColor;
                            colors[1] = Theme.of(context).highlightColor;
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
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                    Expanded(
                      child: IgnorePointer(
                        ignoring: widget.OnlyView,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showCreate = false;
                              colors[0] = Theme.of(context).highlightColor;
                              colors[1] = Theme.of(context).primaryColor;
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
                      padding: EdgeInsets.symmetric(horizontal: 30.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterBold(
                                text: 'Select Guard',
                                fontsize: 16.w,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SelectAssetsGuardsScreen(
                                                companyId: widget.companyId,
                                                empId: '',
                                              ))).then((value) => {
                                        if (value != null)
                                          {
                                            print("Value: ${value}"),
                                            setState(() {
                                              bool guardExists =
                                                  selectedGuards.any((guard) =>
                                                      guard['GuardId'] ==
                                                      value['id']);

                                              if (guardExists) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Guard already added'),
                                                  ),
                                                );
                                              } else {
                                                // Add the guard if it does not exist
                                                selectedGuards.add({
                                                  'GuardId': value['id'],
                                                  'GuardName': value['name'],
                                                  'GuardImg': value['url']
                                                });
                                              }
                                            }),
                                          }
                                      });
                                },
                                child: InterBold(
                                  text: '+ Add',
                                  fontsize: 16.w,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 24.h),
                          Container(
                            height: 64.h,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(13.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (query) {
                                      searchGuards(query);
                                    },
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
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
                                        fontSize: 18.sp,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .color,
                                      ),
                                      hintText: 'Search Guard',
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    cursorColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Container(
                                  height: 44.h,
                                  width: 44.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.search,
                                      size: 20.w,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? DarkColor.Secondarycolor
                                          : LightColor.color1,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
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
                                    selectedGuards.add({
                                      'GuardName': guard['EmployeeName'],
                                      'GuardImg': guard['EmployeeImg'],
                                      'GuardId': guard['EmployeeId'],
                                    });
                                    selectedGuardId = guard['EmployeeId'];
                                    controller:
                                    _searchController.text =
                                        guard['EmployeeName'];
                                    guards.clear();
                                  });
                                },
                              );
                            },
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20.h),
                            height: 80.h,
                            width: double.maxFinite,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 0,
                              itemBuilder: (context, index) {
                                String guardId =
                                    selectedGuards[index]['GuardId'];
                                String guardName =
                                    selectedGuards[index]['GuardName'];
                                String guardImg =
                                    selectedGuards[index]['GuardImg'];
                                return Padding(
                                  padding: EdgeInsets.only(right: 20.h),
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
                                                    color: Theme.of(context)
                                                        .primaryColor,
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
                                                  // selectedGuards
                                                  //     .removeAt(index);
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
                                        color: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .color,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                          InterBold(
                            text: 'Select equipment',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .color,
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
                                  borderRadius: BorderRadius.circular(13.w),
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
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                                        borderRadius:
                                            BorderRadius.circular(10.r),
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
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
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
                                        borderRadius:
                                            BorderRadius.circular(10.r),
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
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
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
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).shadowColor,
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: Offset(0, 3),
                                )
                              ],
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    InterMedium(
                                      text: 'Asset Returned ?',
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .color,
                                      fontsize: 16.sp,
                                      letterSpacing: -.3,
                                    )
                                  ],
                                ),
                                Checkbox(
                                  activeColor: Theme.of(context).primaryColor,
                                  checkColor: DarkColor.color1,
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
                          SizedBox(height: 40.h),
                          IgnorePointer(
                            ignoring:
                                widget.OnlyView == true && isChecked == true
                                    ? true
                                    : false,
                            child: Button1(
                              text: 'Save',
                              onPressed: () {
                                createEquipmentAllocation();
                              },
                              backgroundcolor: /*widget.OnlyView == true
                                  ?*/
                                  isChecked == false
                                      ? Theme.of(context).primaryColorLight
                                      : Theme.of(context).primaryColor,
                              // : Theme.of(context).primaryColorLight,
                              borderRadius: 10.r,
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          InterBold(
                            text: 'Title.',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            hint: 'Title',
                            controller: _titleController2,
                            showIcon: true,
                          ),
                          SizedBox(height: 10.sp),
                          InterBold(
                            text: 'Allocate Qt.',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 10.h),
                          CustomeTextField(
                            hint: '0',
                            controller: _allocateQtController2,
                          ),
                          InterBold(
                            text: 'Select Branch',
                            fontsize: 16.sp,
                            color:
                            Theme.of(context).textTheme.bodyMedium!.color,
                          ),
                          SizedBox(height: 10.h),
                          DropdownButtonFormField<String>(
                            value: selectedBranch,
                            items: equipment.map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: data['EquipmentName'],
                                child: InterRegular(
                                  text: data['EquipmentName'],
                                  color: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .color,
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedBranch = newValue;
                                // selectedEquipmentId = equipment
                                //     .firstWhere((document) =>
                                // (document.data() as Map<String,
                                //     dynamic>)['EquipmentName'] ==
                                //     newValue)
                                //     .id;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Selected Branch',
                              hintStyle: TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13.w),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          InterBold(
                            text: 'Description',
                            fontsize: 16.sp,
                            color:
                                Theme.of(context).textTheme.bodyMedium!.color,
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
                            backgroundcolor: Theme.of(context).primaryColor,
                            borderRadius: 10.r,
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

/*Container(
                            height: 60.h,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            //Add receiver name too
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InterBold(
                                      text: 'Select Guards',
                                      fontsize: 16.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color,
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
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                Container(
                                  height: 64.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(13.r),
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
                                            fontSize: 18.sp,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
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
                                              fontSize: 18.sp,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .color,
                                            ),
                                            hintText: 'Search Guard',
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          cursorColor:
                                              Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Container(
                                        height: 44.h,
                                        width: 44.w,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                                ),
                                SizedBox(height: 10.h),
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
                                          color: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .color,
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
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color),
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(13.r),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                InterBold(
                                  text: 'Allocate Qt.',
                                  fontsize: 16.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
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
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color:
                                                  Theme.of(context).cardColor,
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
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .color,
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
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                              color:
                                                  Theme.of(context).cardColor,
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
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .color,
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
                                  height: height / height60,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10.r),
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
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          InterMedium(
                                            text: 'Asset Returned ?',
                                            color: DarkColor.color8,
                                            fontsize: width / width16,
                                            letterSpacing: -.3,
                                          )
                                        ],
                                      ),
                                      Checkbox(
                                        activeColor:
                                            Theme.of(context).primaryColor,
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
                                SizedBox(height: 40.h),
                                IgnorePointer(
                                  ignoring: widget.OnlyView
                                      ? isChecked == false
                                          ? true
                                          : false
                                      : true,
                                  child: Button1(
                                    text: 'Done',
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .color,
                                    onPressed: () {
                                      createEquipmentAllocation();
                                    },
                                    backgroundcolor: Theme.of(context)
                                                .brightness ==
                                            Brightness.dark
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
                                    borderRadius: 10.r,
                                  ),
                                ),
                              ],
                            ),
                          ),*/

/*   Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Allocate Qt.',
                                fontsize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Title',
                                controller: _titleController2,
                                showIcon: true,
                              ),
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Allocate Qt.',
                                fontsize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: '0',
                                controller: _allocateQtController2,
                              ),
                              SizedBox(height: 10.h),
                              InterBold(
                                text: 'Description',
                                fontsize: 16.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                              SizedBox(height: 10.h),
                              CustomeTextField(
                                hint: 'Write something about asset...',
                                controller: _descriptionController,
                                showIcon: true,
                              ),
                              SizedBox(height: 40.h),
                              Button1(
                                text: 'Done',
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .color,
                                onPressed: () {
                                  createEquipmentAllocation();
                                },
                                backgroundcolor:
                                    Theme.of(context).primaryColor,
                                borderRadius: 10.r,
                              ),
                            ],
                          ),*/
