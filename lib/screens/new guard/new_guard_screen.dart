import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tact_tik/common/sizes.dart';
import 'package:tact_tik/common/widgets/button1.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/new%20guard/address_details.dart';
import 'package:tact_tik/screens/new%20guard/certificate_detailes.dart';
import 'package:tact_tik/screens/new%20guard/licenses_details.dart';
import 'package:tact_tik/screens/new%20guard/personel_details.dart';
import 'package:tact_tik/screens/new%20guard/bank_details.dart';
import 'package:tact_tik/utils/colors.dart';

class NewGuardScreen extends StatefulWidget {
  final String companyId;
  NewGuardScreen({super.key, required this.companyId});

  @override
  State<NewGuardScreen> createState() => _NewGuardScreenState();
}

class _NewGuardScreenState extends State<NewGuardScreen> {
  bool LastPage = false;
  final TextEditingController FirstNameController = TextEditingController();
  final TextEditingController LastNameController = TextEditingController();
  final TextEditingController PhoneNumberController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PasswordController = TextEditingController();
  final String SelectedRole = '';
  final TextEditingController PayRateController = TextEditingController();
  final TextEditingController WeekHoursController = TextEditingController();
  final TextEditingController BranchController = TextEditingController();
  final TextEditingController AddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController PostalCodeController = TextEditingController();
  final TextEditingController ProvinceController = TextEditingController();
  final TextEditingController DrivingLicenseController =
      TextEditingController();
  final TextEditingController SecurityLicensesController =
      TextEditingController();
  final TextEditingController CertificateController = TextEditingController();
  final TextEditingController AccountNumberController = TextEditingController();
  final TextEditingController TransitNumberController = TextEditingController();
  final TextEditingController InstitutionNumberController =
      TextEditingController();
  final TextEditingController SINNumberController = TextEditingController();
  File? bankVoidCheckImg;
  File? certificateDoc;
  File? employeeImg;
  File? drivingLicenseImg;
  File? securityLicenseImg;
  DateTime? drivingExpDate;
  DateTime? securityExpDate;

  Future<String> uploadFile(File file, String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> createEmployee() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: EmailController.text,
        password: PasswordController.text,
      );

      String uid = userCredential.user!.uid;

      final employeeName = '${FirstNameController.text} ${LastNameController.text}';
      final nameSearchIndex = generateSearchIndex(employeeName);

      DocumentReference newEmployeeDoc = FirebaseFirestore.instance.collection('Employees').doc(uid);

      String bankVoidCheckImgUrl = '';
      String certificateDocUrl = '';
      String employeeImgUrl = '';
      String drivingLicenseImgUrl = '';
      String securityLicenseImgUrl = '';

      if (bankVoidCheckImg != null) {
        bankVoidCheckImgUrl = await uploadFile(bankVoidCheckImg!,
            'employees/images/${uid}_bankVoidCheckImg${Path.extension(bankVoidCheckImg!.path)}');
      }

      if (certificateDoc != null) {
        certificateDocUrl = await uploadFile(certificateDoc!,
            'employees/images/${uid}_certificateDoc${Path.extension(certificateDoc!.path)}');
      }

      if (employeeImg != null) {
        employeeImgUrl = await uploadFile(employeeImg!,
            'employees/images/${uid}_employeeImg${Path.extension(employeeImg!.path)}');
      }

      if (drivingLicenseImg != null) {
        drivingLicenseImgUrl = await uploadFile(drivingLicenseImg!,
            'employees/images/${uid}_drivingLicenseImg${Path.extension(drivingLicenseImg!.path)}');
      }

      if (securityLicenseImg != null) {
        securityLicenseImgUrl = await uploadFile(securityLicenseImg!,
            'employees/images/${uid}_securityLicenseImg${Path.extension(securityLicenseImg!.path)}');
      }

      await newEmployeeDoc.set({
        'EmployeeAddress': AddressController.text,
        'EmployeeBankDetails': {
          'BankAccNumber': AccountNumberController.text,
          'BankInstitutionNumber': InstitutionNumberController.text,
          'BankTransitNumber': TransitNumberController.text,
          'BankVoidCheckImg': bankVoidCheckImgUrl,
        },
        'EmployeeCertificates': [
          {
            'CertificateName': CertificateController.text,
            'CertificateDoc': certificateDocUrl,
          }
        ],
        'EmployeeCity': cityController.text,
        'EmployeeCompanyBranchId': BranchController.text,
        'EmployeeCompanyId': widget.companyId,
        'EmployeeCreatedAt': Timestamp.now(),
        'EmployeeEmail': EmailController.text,
        'EmployeeId': uid,
        'EmployeeImg': employeeImgUrl,
        'EmployeeIsAvailable': 'available',
        'EmployeeIsBanned': false,
        'EmployeeLicenses': [
          {
            'LicenseType': 'security',
            'LicenseNumber': SecurityLicensesController.text,
            'LicenseExpDate': securityExpDate != null
                ? Timestamp.fromDate(securityExpDate!)
                : '',
            'LicenseImg': securityLicenseImgUrl,
          },
          {
            'LicenseType': 'driving',
            'LicenseNumber': DrivingLicenseController.text,
            'LicenseExpDate': drivingExpDate != null
                ? Timestamp.fromDate(drivingExpDate!)
                : '',
            'LicenseImg': drivingLicenseImgUrl,
          }
        ],
        'EmployeeLocations': [],
        'EmployeeMaxHrsPerWeek': WeekHoursController.text,
        'EmployeeName': employeeName,
        'EmployeeNameSearchIndex': nameSearchIndex,
        'EmployeePassword': PasswordController.text,
        'EmployeePayRate': PayRateController.text,
        'EmployeePhone': PhoneNumberController.text,
        'EmployeePostalCode': PostalCodeController.text,
        'EmployeeProvince': ProvinceController.text,
        'EmployeeRole': SelectedRole,
        'EmployeeSinNumber': SINNumberController.text,
        'EmployeeSupervisorId': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Employee created successfully!'),
      ));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create employee. Please try again.'),
      ));
    }
  }


  List<String> generateSearchIndex(String name) {
    List<String> searchIndex = [];
    String temp = "";
    for (int i = 0; i < name.length; i++) {
      temp = temp + name[i];
      searchIndex.add(temp.toLowerCase());
    }
    return searchIndex;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final _pagecontroller = PageController(
      initialPage: 0,
    );

    return Scaffold(
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
          text: 'New Guard',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: PageView(
        controller: _pagecontroller,
        onPageChanged: (index) {
          setState(() {
            LastPage = 4 == index;
          });
        },
        children: [
          PersonalDetails(
            FirstNameController: FirstNameController,
            LastNameController: LastNameController,
            PhoneNumberController: PhoneNumberController,
            EmailController: EmailController,
            PasswordController: PasswordController,
            SelectedRole: SelectedRole,
            PayRateController: PayRateController,
            WeekHoursController: WeekHoursController,
            BranchController: BranchController,
            CompanyId: widget.companyId,
          ),
          BankDetails(
            AccountNumberController: AccountNumberController,
            TransitNumberController: TransitNumberController,
            InstitutionNumberController: InstitutionNumberController,
            SINNumberController: SINNumberController,
            onFileSelected: (file) {
              setState(() {
                bankVoidCheckImg = file;
              });
            },
          ),
          LicensesDetails(
            DrivingLicenseController: DrivingLicenseController,
            SecurityLicensesController: SecurityLicensesController,
            DrivingExpiryDate: drivingExpDate,
            SecurityExpiryDate: securityExpDate,
            onDrivingSelected: (file) {
              setState(() {
                drivingLicenseImg = file;
              });
            },
            onSecuritySelected: (file) {
              setState(() {
                securityLicenseImg = file;
              });
            },
          ),
          CertificateDetails(
            CertificateController: CertificateController,
            onFileSelected: (file) {
              setState(() {
                certificateDoc = file;
              });
            },
          ),
          AddressDetails(
            AddressController: AddressController,
            cityController: cityController,
            PostalCodeController: PostalCodeController,
            ProvinceController: ProvinceController,
            onFileSelected: (file) {
              setState(() {
                employeeImg = file;
              });
            },
          )
        ],
      )),
      bottomSheet: LastPage
          ? Button1(
              text: 'Submit',
              onPressed: createEmployee,
              backgroundcolor: Theme.of(context).primaryColor,
              color: Theme.of(context).textTheme.headlineMedium!.color,
              borderRadius: 10.r,
              fontsize: 18.sp,
            )
          : Container(
              height: 66.h,
              color: Theme.of(context).canvasColor,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width / width40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => _pagecontroller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 24.sp,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _pagecontroller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      ),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 24.sp,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
