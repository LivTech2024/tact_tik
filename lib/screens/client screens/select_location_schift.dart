import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filter_list/filter_list.dart';
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
  List<User>? selectedUserList = [];

  @override
  void initState() {
    super.initState();
  }

  List<String> _locatioInfo = [
    'mumbai, india',
    'delhi, india',
    'bhiwandi, india',
  ];

  Future<void> openFilterDelegate() async {
    await FilterListDelegate.show<User>(
      context: context,
      list: userList,
      selectedListData: selectedUserList,
      theme: FilterListDelegateThemeData(
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          tileColor: Colors.white,
          selectedTileColor: const Color(0xFF649BEC).withOpacity(.5),
        ),
        tileTextStyle: TextStyle(fontSize: 14),
      ),
      // enableOnlySingleSelection: true,
      onItemSearch: (user, query) {
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },
      tileLabel: (user) => user!.name,
      emptySearchChild: const Center(child: Text('No user found')),
      // enableOnlySingleSelection: true,
      searchFieldHint: 'Search Here..',
      /*suggestionBuilder: (context, user, isSelected) {
        return ListTile(
          title: Text(user.name!),
          leading: const CircleAvatar(
            backgroundColor: Colors.blue,
          ),
          selected: isSelected,
        );
      },*/
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = list;
        });
      },
    );
  }

  Future<void> _openFilterDialog() async {
    await FilterListDialog.display<User>(
      context,
      hideSelectedTextCount: true,
      // themeData: FilterListThemeData(
      //   context,
      //   choiceChipTheme: ChoiceChipThemeData.(context),
      // ),
      headlineText: 'Select Location',
      height: 500.h,
      listData: userList,
      selectedListData: selectedUserList,
      choiceChipLabel: (item) => item!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      controlButtons: [ControlButtonType.All, ControlButtonType.Reset],
      onItemSearch: (user, query) {
        /// When search query change in search bar then this method will be called
        ///
        /// Check if items contains query
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },

      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = List.from(list!);
        });
        Navigator.pop(context);
      },
      onCloseWidgetPress: () {
        // Do anything with the close button.
        //print("hello");
        Navigator.pop(context, null);
      },

      /// uncomment below code to create custom choice chip
      choiceChipBuilder: (context, item, isSelected) {
        return Container(
          constraints: BoxConstraints(minWidth: 10.w),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
              border: Border.all(
            color: isSelected! ? Colors.blue[300]! : Colors.grey[300]!,
          )),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: isSelected ? Colors.blue[300] : Colors.grey[500],
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              InterMedium(
                text: item.name,
                color: isSelected ? Colors.blue[300] : Colors.grey[500],
              ),
            ],
          ),
        );
      },
    );
  }

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
              size: 24.sp,
            ),
            padding: EdgeInsets.only(left: 20.w),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: InterRegular(
            text: 'Select Location',
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
          child: FilledButton(
            onPressed: () {
              _openFilterDialog();
            },
            child: const Text("Filter Dialog"),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            children: <Widget>[
              if (selectedUserList == null || selectedUserList!.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No user selected'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(selectedUserList![index].name!),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: selectedUserList!.length,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPage extends StatelessWidget {
  const FilterPage({Key? key, this.allTextList, this.selectedUserList})
      : super(key: key);
  final List<User>? allTextList;
  final List<User>? selectedUserList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FilterListWidget<User>(
          themeData: FilterListThemeData(context),
          hideSelectedTextCount: true,
          listData: userList,
          selectedListData: selectedUserList,
          onApplyButtonClick: (list) {
            Navigator.pop(context, list);
          },
          choiceChipLabel: (item) {
            /// Used to print text on chip
            return item!.name;
          },
          // choiceChipBuilder: (context, item, isSelected) {
          //   return Container(
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //     decoration: BoxDecoration(
          //         border: Border.all(
          //       color: isSelected! ? Colors.blue[300]! : Colors.grey[300]!,
          //     )),
          //     child: Text(item.name),
          //   );
          // },
          validateSelectedItem: (list, val) {
            ///  identify if item is selected or not
            return list!.contains(val);
          },
          onItemSearch: (user, query) {
            /// When search query change in search bar then this method will be called
            ///
            /// Check if items contains query
            return user.name!.toLowerCase().contains(query.toLowerCase());
          },
          onCloseWidgetPress: () {
            print("hello");
          },
        ),
      ),
    );
  }
}

class User {
  final String? name;
  final IconData? icon;

  User({this.name, this.icon});
}

/// Creating a global list for example purpose.
/// Generally it should be within data class or where ever you want
List<User> userList = [
  User(name: "Abigail", icon: Icons.location_on),
  User(name: "Audrey", icon: Icons.location_on),
  User(name: "Ava", icon: Icons.location_on),
  User(name: "Bella", icon: Icons.location_on),
  User(name: "Bernadette", icon: Icons.location_on),
  User(name: "Carol", icon: Icons.location_on),
  User(name: "Claire", icon: Icons.location_on),
  User(name: "Deirdre", icon: Icons.location_on),
  User(name: "Donna", icon: Icons.location_on),
  User(name: "Dorothy", icon: Icons.location_on),
  User(name: "Faith", icon: Icons.location_on),
];
