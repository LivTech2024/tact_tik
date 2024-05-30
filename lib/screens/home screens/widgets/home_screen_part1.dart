import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tact_tik/fonts/inter_regular.dart';
import '../../../common/sizes.dart';
import '../../../fonts/poppins_light.dart';
import '../../../fonts/poppis_semibold.dart';
import '../../../utils/colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Screens {
  final String name;
  final IconData icon;

  Screens(this.name, this.icon);
}

class HomeScreenPart1 extends StatelessWidget {
  final String userName;
  final String employeeImg;

  // final String url;
  final VoidCallback drawerOnClicked;
  bool? showWish;

  HomeScreenPart1({
    Key? key,
    required this.userName,
    // required this.url,
    required this.employeeImg,
    required this.drawerOnClicked,
    this.showWish = true,
  }) : super(key: key);

  bool isUnread = true;
  DateTime now = DateTime.now();
  int hour = DateTime.now().hour;
  String greeting = 'Good ';
  final TextEditingController _controller = TextEditingController();

  final List<Screens> _screens = [
    Screens('Site Tours', Icons.ac_unit_outlined),
    Screens('DAR Screen', Icons.ac_unit_outlined),
    Screens('Reports Screen', Icons.ac_unit_outlined),
    Screens('Post Screen', Icons.ac_unit_outlined),
    Screens('Task Screen', Icons.ac_unit_outlined),
    Screens('LogBook Screen', Icons.ac_unit_outlined),
    Screens('Visitors Screen', Icons.ac_unit_outlined),
    Screens('Assets Screen', Icons.ac_unit_outlined),
    Screens('Key Screen', Icons.ac_unit_outlined),
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
      reverse: SuggestionsController.of<Screens>(context).effectiveDirection ==
          VerticalDirection.up,
      itemBuilder: (context, index) => items[index],
    );
  }

  Future<List<Screens>> suggestionsCallback(String pattern) async =>
      Future<List<Screens>>.delayed(
        Duration(milliseconds: 300),
        () => _screens.where((product) {
          final nameLower = product.name.toLowerCase().split(' ').join('');
          final patternLower = pattern.toLowerCase().split(' ').join('');
          return nameLower.contains(patternLower);
        }).toList(),
      );

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    if (hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour < 18) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          left: width / width30,
          right: width / width30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height / height55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: height / height50,
                    width: width / width50,
                    decoration: employeeImg != ""
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(employeeImg ?? ""),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          )
                        : BoxDecoration(
                            shape: BoxShape.circle,
                            color: Primarycolor,
                            image: DecorationImage(
                              image: AssetImage('assets/images/default.png'),
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            // Use the notifications_active icon
                            color: Primarycolor, // Change color if unread
                            size: width / width28,
                          ),
                          if (isUnread)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(width / width4 / 2),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Primarycolor, // Background color for unread indicator
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        width: width / width30,
                      ),
                      GestureDetector(
                        onTap: drawerOnClicked,
                        child: Transform.scale(
                          scaleX: -1,
                          child: Icon(
                            Icons.short_text_rounded,
                            color: Primarycolor,
                            size: width / width40,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: height / height30),
            showWish!
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PoppinsSemibold(
                        text: '${greeting}',
                        color: Primarycolor,
                        letterSpacing: -.5,
                        fontsize: width / width35,
                      ),
                      SizedBox(height: height / height10),
                      PoppinsLight(
                        text: userName != '' ? userName : 'User not found',
                        color: Primarycolor,
                        fontsize: width / width30,
                      ),
                      SizedBox(height: height / height16),
                    ],
                  )
                : const SizedBox(),
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
                    child: TypeAheadField<Screens>(
                      controller: _controller,
                      direction: VerticalDirection.down,
                      builder: (context, _controller, focusNode) => TextField(
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
                                Radius.circular(width / width10),
                              ),
                            ),
                            focusedBorder: InputBorder.none,
                            hintStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                              fontSize: width / width18,
                              color: color2,
                            ),
                            hintText: 'Search screen',
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: Primarycolor),
                      suggestionsCallback: suggestionsCallback,
                      itemBuilder: (context, Screens screen) {
                        return ListTile(
                          leading: Icon(screen.icon, color: Colors.blueAccent),
                          title: InterRegular(
                            text: screen.name,
                            color: color2,
                          ),
                        );
                      },
                      emptyBuilder: (context) => Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: height / height10,
                            horizontal: width / width10),
                        child: InterRegular(
                          text: 'No Such Screen found',
                          color: color2,
                          fontsize: width / width18,
                        ),
                      ),
                      decorationBuilder: (context, child) => Material(
                        type: MaterialType.card,
                        elevation: 4,
                        borderRadius: BorderRadius.circular(width / width10),
                        child: child,
                      ),
                      debounceDuration: const Duration(milliseconds: 300),
                      onSelected: (Screens value) {
                        // _controller.text = value.name;
                        print(
                            'home screen search bar############################################');
                        print(value.name);
                      },
                      listBuilder: gridLayoutBuilder,
                    ),
                  ),
                  /*Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w300,
                        fontSize: width / width18,
                        color: Colors.white, // Change text color to white
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
                          color: color2, // Change text color to white
                        ),
                        hintText: 'Search',
                        contentPadding: EdgeInsets.zero, // Remove padding
                      ),
                      cursorColor: Primarycolor,
                    ),
                  ),*/

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
            SizedBox(height: height / height10),
          ],
        ),
      ),
    );
  }
}
