import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../common/widgets/setTextfieldWidget.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import '../../home screens/widgets/set_details_widget.dart';

class SCreateAssignAssetScreen extends StatefulWidget {
  final String companyId;
  final String empId;
  final bool OnlyView;
  final String equipemtAllocId;
  SCreateAssignAssetScreen({super.key, required this.companyId, required this.empId, this.OnlyView = false, required this.equipemtAllocId});

  @override
  State<SCreateAssignAssetScreen> createState() =>
      _SCreateAssignAssetScreenState();
}

class _SCreateAssignAssetScreenState extends State<SCreateAssignAssetScreen> {
  List colors = [Primarycolor, color25];
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
    CollectionReference equipmentAllocations = FirebaseFirestore.instance.collection('EquipmentAllocations');
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
    CollectionReference equipmentAllocations = FirebaseFirestore.instance.collection('EquipmentAllocations');
    await equipmentAllocations.doc(widget.equipemtAllocId).update({
      'EquipmentAllocationIsReturned': isChecked,
    });
  }

  Future<void> _selectDate(BuildContext context , bool isStart) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null){
        if (isStart) {
          StartDate = picked;
        }  else{
          EndDate = picked;
        }
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        appBar: AppBar(
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
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Assets',
            fontsize: width / width18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: height / height65,
                width: double.maxFinite,
                color: color24,
                padding: EdgeInsets.symmetric(vertical: height / height16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            showCreate = true;
                            colors[0] = Primarycolor;
                            colors[1] = color25;
                          });
                        },
                        child: SizedBox(
                          child: Center(
                            child: InterBold(
                              text: 'Assign',
                              color: colors[0],
                              fontsize: width / width18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(
                      color: Primarycolor,
                    ),
                    Expanded(
                      child: IgnorePointer(
                        ignoring: widget.OnlyView,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showCreate = false;
                              colors[0] = color25;
                              colors[1] = Primarycolor;
                            });
                          },
                          child: SizedBox(
                            child: Center(
                              child: InterBold(
                                text: 'Create',
                                color: colors[1],
                                fontsize: width / width18,
                              ),
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
                padding: EdgeInsets.symmetric(horizontal: width / width30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InterBold(
                          text: 'Select Guards',
                          fontsize: width / width16,
                          color: color1,
                        ),
                        IgnorePointer(
                          ignoring: widget.OnlyView,
                          child: TextButton(
                            onPressed: () async {
                              final result = await FirebaseFirestore.instance
                                  .collection('Employees')
                                  .where('EmployeeRole', isEqualTo: 'GUARD')
                                  .where('EmployeeCompanyId', isEqualTo: widget.companyId)
                                  .get();

                              setState(() {
                                guards = result.docs.map((doc) => doc.data()).toList();
                              });
                            },
                            child: InterBold(
                              text: 'view all',
                              fontsize: width / width14,
                              color: color1,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: height / height24),
                    Container(
                      height: height / height64,
                      padding: EdgeInsets.symmetric(horizontal: width / width10),
                      decoration: BoxDecoration(
                        color: WidgetColor,
                        borderRadius: BorderRadius.circular(width / width13),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: color2,
                                ),
                                hintText: 'Search Guard',
                                contentPadding: EdgeInsets.zero,
                              ),
                              cursorColor: Primarycolor,
                            ),
                          ),
                          Container(
                            height: height / height44,
                            width: width / width44,
                            decoration: BoxDecoration(
                              color: Primarycolor,
                              borderRadius: BorderRadius.circular(width / width10),
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
                              _searchController.text = guard['EmployeeName'];
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
                      color: color1,
                    ),
                    SizedBox(height: height / height10),
                    IgnorePointer(
                      ignoring: widget.OnlyView,
                      child: DropdownButtonFormField<String>(
                        value: selectedEquipmentName,
                        items: equipment.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: data['EquipmentName'],
                            child: InterRegular(text: data['EquipmentName'] , color: color3,),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedEquipmentName = newValue;
                            selectedEquipmentId = equipment.firstWhere((document) => (document.data() as Map<String, dynamic>)['EquipmentName'] == newValue).id;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Select Equipment',
                          hintStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: WidgetColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width / width13),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height / height20),
                    InterBold(
                      text: 'Allocate Qt.',
                      fontsize: width / width16,
                      color: color1,
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
                      color: color1,
                      fontsize: width / width16,
                    ),
                    SizedBox(height: height / height10),
                    IgnorePointer(
                      ignoring: widget.OnlyView,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap:(){
                                _selectDate(context , true);
                              },
                              child: Container(
                                height: height / height60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(width / width10),
                                  color: WidgetColor,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InterMedium(
                                      text: StartDate != null ? '${StartDate!.toLocal()}'.split(' ')[0] :'Start Time',
                                      fontsize: width / width16,
                                      color: color2,
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
                              onTap: (){
                                _selectDate(context , false);
                              },
                              child: Container(
                                height: height / height60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(width / width10),
                                  color: WidgetColor,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InterMedium(
                                      text: EndDate!= null ? '${EndDate!.toLocal()}'.split(' ')[0] : 'End Time',
                                      fontsize: width / width16,
                                      color: color2,
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
                      padding: EdgeInsets.symmetric(horizontal: width / width20),
                      decoration: BoxDecoration(
                        color: WidgetColor,
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
                                color: color8,
                                fontsize: width / width16,
                                letterSpacing: -.3,
                              )
                            ],
                          ),
                          Checkbox(
                            activeColor: Primarycolor,
                            checkColor: color1,
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
                      ignoring: widget.OnlyView ? isChecked == false ? true : false : true,
                      child: Button1(
                        text: 'Done',
                        onPressed: () {
                          createEquipmentAllocation();
                        },
                        backgroundcolor: widget.OnlyView ? isChecked == false ? Primarycolorlight : Primarycolor : Primarycolorlight,
                        borderRadius: width / width10,
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
                      color: color1,
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
                      color: color1,
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
                      color: color1,
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
                      backgroundcolor: Primarycolor,
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