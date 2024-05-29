import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../common/sizes.dart';
import '../../../../common/widgets/button1.dart';
import '../../../../common/widgets/setTextfieldWidget.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_medium.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';
import '../../../feature screens/widgets/custome_textfield.dart';
import '../../home screens/widgets/set_details_widget.dart';

class SCreateKeyManagScreen extends StatefulWidget {
  final String keyId;
  final String companyId;
  SCreateKeyManagScreen({super.key, required this.keyId, required this.companyId});

  @override
  State<SCreateKeyManagScreen> createState() => _SCreateAssignAssetScreenState();
}

class _SCreateAssignAssetScreenState extends State<SCreateKeyManagScreen> {
  List colors = [DarkColor.Primarycolor, DarkColor. color25];
  bool isChecked = false;
  bool showCreate = false;

  TextEditingController _tittleController = TextEditingController();
  TextEditingController _RecipientNameController = TextEditingController();
  TextEditingController _ContactController = TextEditingController();
  TextEditingController _CompanyNameController = TextEditingController();
  TextEditingController _AllocationPurposeController = TextEditingController();
  TextEditingController _AllocateQtController1 = TextEditingController();
  TextEditingController _AllocateQtController2 = TextEditingController();
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

  Future<void> _saveData() async {
    CollectionReference keyAllocations = FirebaseFirestore.instance.collection('KeyAllocations');
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

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: DarkColor. Secondarycolor,
        body: Stack(
          children: [
            SingleChildScrollView(
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
                                colors[0] = DarkColor.Primarycolor;
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
                                colors[0] = DarkColor. color25;
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
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Recipient Name',
                          fontsize: width / width16,
                          color:DarkColor. color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: 'Eg. Leslie Alexander',
                          controller: _RecipientNameController,
                          showIcon: false,
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Contact',
                          fontsize: width / width16,
                          color: DarkColor.color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: '9876543210',
                          controller: _ContactController,
                          showIcon: false,
                          textInputType: TextInputType.number,
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Company Name',
                          fontsize: width / width16,
                          color:DarkColor. color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: 'Eg. Tacttik',
                          controller: _CompanyNameController,
                          showIcon: false,
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Allocate Qt.',
                          fontsize: width / width16,
                          color:DarkColor. color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: '0',
                          controller: _AllocateQtController1,
                          showIcon: false,
                          textInputType: TextInputType.number,
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Date',
                          color:DarkColor. color1,
                          fontsize: width / width16,
                        ),
                        SizedBox(height: height / height10),
                        Container(
                          height: height / height60,
                          padding: EdgeInsets.symmetric(horizontal: width / width20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width / width10),
                            color:DarkColor. WidgetColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InterMedium(
                                text: 'Select Date',
                                fontsize: width / width16,
                                color: DarkColor.color2,
                              ),
                              SvgPicture.asset(
                                'assets/images/calendar_clock.svg',
                                width: width / width20,
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Allocation Date',
                          color:DarkColor. color1,
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
                                  color:DarkColor. WidgetColor,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InterMedium(
                                      text: 'Start date',
                                      fontsize: width / width16,
                                      color: DarkColor. color2,
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/calendar_clock.svg',
                                      width: width / width20,
                                    )
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
                                  color:DarkColor. WidgetColor,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    InterMedium(
                                      text: 'End date',
                                      fontsize: width / width16,
                                      color:DarkColor. color2,
                                    ),
                                    SvgPicture.asset(
                                      'assets/images/calendar_clock.svg',
                                      width: width / width20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height / height20),
                        InterBold(
                          text: 'Allocation Purpose',
                          fontsize: width / width16,
                          color: DarkColor.color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: 'Write something...',
                          controller: _AllocationPurposeController,
                          showIcon: true,
                          isExpanded: true,
                        ),
                        SizedBox(height: height / height20),
                      ],
                    ),
                  )
                      : Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / width30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterBold(
                          text: 'Key Name',
                          fontsize: width / width16,
                          color:DarkColor. color1,
                        ),
                        SizedBox(height: height / height10),
                        DropdownButtonFormField<String>(
                          value: selectedKeyName,
                          items: keys.map((DocumentSnapshot document) {
                            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: data['KeyName'],
                              child: Text(data['KeyName']),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedKeyName = newValue;
                              selectedKeyId = keys.firstWhere((document) => (document.data() as Map<String, dynamic>)['KeyName'] == newValue).id;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width / width10),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: width / width20, vertical: height / height60),
                            hintText: 'Select Key Name',
                            hintStyle: TextStyle(color: DarkColor.color2),
                          ),
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
                          showIcon: false,
                          textInputType: TextInputType.number,
                        ),
                        SizedBox(height: height / height10),
                        InterBold(
                          text: 'Description',
                          fontsize: width / width16,
                          color: DarkColor.color1,
                        ),
                        SizedBox(height: height / height10),
                        CustomeTextField(
                          hint: 'Write something...',
                          controller: _DescriptionController,
                          showIcon: true,
                          isExpanded: true,
                        ),
                        SizedBox(height: height / height20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button1(
                    text: 'Save',
                    onPressed: () {
                      _saveData();
                    },
                    borderRadius: width / width10,
                    backgroundcolor: DarkColor. Primarycolor,
                  ),
                  SizedBox(
                    height: height / height20,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}