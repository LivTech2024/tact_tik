import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_medium.dart';
import 'package:tact_tik/fonts/poppins_bold.dart';
import 'package:tact_tik/main.dart';
import 'package:tact_tik/screens/home%20screens/widgets/home_screen_part1.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

import '../../../../common/sizes.dart';
import '../../../../fonts/inter_bold.dart';
import '../../../../fonts/inter_regular.dart';
import '../../../../utils/colors.dart';

class SelectLocationShift extends StatefulWidget {
  final String companyId;

   SelectLocationShift({super.key, required this.companyId});

  @override
  State<SelectLocationShift> createState() => _SelectLocationShiftState();
}

class _SelectLocationShiftState extends State<SelectLocationShift> {
  get suggestionsCallback => null;

  @override
  void initState() {
    super.initState();
  }

  List<String> _locatioInfo = [
    'mumbai, india',
    'mumbai, india',
    'mumbai, india',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
          title: const InterMedium(
            text: 'Locations',
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                SearchBar(
                  hintText: 'Search Location',
                  onChanged: (value) {
                    print(value);
                  },
                // shape:WidgetStatePropertyAll(value),
                backgroundColor:WidgetStatePropertyAll(Theme.of(context).cardColor),
                
                  trailing: [
                      Container(
                      height: 43.h,
                      width: 43.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.search,
                          size: 19.sp,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20.h),
                _locatioInfo.length != 0
                    ? ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _locatioInfo.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {},
                              child: Container(
                                
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12.h),
                                ),
                              
                                height: 60.h,
                                
                                margin: EdgeInsets.only(bottom: 10.h),
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                    
                                      height: 48.h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                              ),
                                              SizedBox(width: 20.w),
                                              InterBold(
                                                text: _locatioInfo[index],
                                                letterSpacing: -.3,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .color,
                                                fontsize: 12.sp,
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        },
                      )
                    : Center(
                        child: PoppinsBold(
                          text: 'No Location Found',
                          color: DarkColor.color2,
                          fontsize: 16.sp,
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
