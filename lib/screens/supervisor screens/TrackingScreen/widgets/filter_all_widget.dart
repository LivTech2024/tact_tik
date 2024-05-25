import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../controller/s_tracking_screen_controller.dart';

class FilterAllWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = SupervisorTrackingScreenController.instance;
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xff252525),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              'All',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.filter_list,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
      onSelected: (String result) {
        print('onSelected: $result');
        final company =
            controller.companies.firstWhere((c) => c.companyId == result);
        company.selected = !company.selected;
        controller.filterEmployees();
      },
      itemBuilder: (BuildContext context) {
        return controller.companies.map((Company company) {
          return PopupMenuItem<String>(
            value: company.companyId,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: company.companyLogo,
                      width: 30,
                      height: 30,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[600]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(company.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        letterSpacing: -.3,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white,
                      )),
                ),
                Checkbox(
                  value: company.selected,
                  onChanged: (bool? value) {
                    company.selected = value!;
                    controller.filterEmployees();
                  },
                ),
              ],
            ),
          );
        }).toList();
      },
    );
    // });
  }
}
