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
  NewGuardScreen({super.key});

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
  final TextEditingController RoleController = TextEditingController();
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
            RoleController: RoleController,
            PayRateController: PayRateController,
            WeekHoursController: WeekHoursController,
            BranchController: BranchController,
          ),
          BankDetails(
            AccountNumberController: AccountNumberController,
            TransitNumberController: TransitNumberController,
            InstitutionNumberController: InstitutionNumberController,
            SINNumberController: SINNumberController,
          ),
          LicensesDetails(
            DrivingLicenseController: DrivingLicenseController,
            SecurityLicensesController: SecurityLicensesController,
          ),
          CertificateDetails(
            CertificateController: CertificateController,
          ),
          AddressDetails(
            AddressController: AddressController,
            cityController: cityController,
            PostalCodeController: PostalCodeController,
            ProvinceController: ProvinceController,
          )
        ],
      )),
      bottomSheet: LastPage
          ?  Button1(
            text: 'Submit',
            onPressed: (){},
            backgroundcolor:
               Theme.of(context).primaryColor,
            color: Theme.of(context).textTheme.headlineMedium!.color,
            borderRadius: 10.r,
            fontsize: 18.sp,
          )
          : Container(
              height: 66.h,
              color:
                  Theme.of(context).canvasColor,
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
                        color:
                            Theme.of(context).textTheme.bodySmall!.color,
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
                        color:
                            Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
