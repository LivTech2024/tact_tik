import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tact_tik/fonts/inter_bold.dart';
import 'package:tact_tik/utils/colors.dart';

import '../../../fonts/inter_medium.dart';
import '../../../fonts/inter_regular.dart';
import '../../home screens/widgets/icon_text_widget.dart';

class Movie {
  final String title;
  final String category;

  Movie(this.title, this.category);
}

class OpenPatrollingScreen extends StatefulWidget {
  const OpenPatrollingScreen({super.key});

  @override
  State<OpenPatrollingScreen> createState() => _OpenPatrollingScreenState();
}

class _OpenPatrollingScreenState extends State<OpenPatrollingScreen> {
  final List<Movie> movies = [
    Movie('Movie 1', 'Action'),
    Movie('Movie 2', 'Action'),
    Movie('Movie 3', 'Action'),
    Movie('Movie 4', 'Action'),
    Movie('Movie 5', 'Comedy'),
    Movie('Movie 6', 'Comedy'),
    Movie('Movie 7', 'Comedy'),
    Movie('Movie 8', 'Comedy'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Secondarycolor,
        appBar: AppBar(
          backgroundColor: AppBarcolor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios, // Use the iPhone back button icon
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: 20),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: InterRegular(
            text: 'Patrolling',
            fontsize: 18,
            color: Colors.white,
            letterSpacing: -.3,
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Primarycolor,
          shape: const CircleBorder(),
          onPressed: (){},
          child: Icon(Icons.qr_code_scanner , color: color1,),
        ),
        body: CustomScrollView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final category = movies[index].category;
                final categoryMovies = movies
                    .where((movie) => movie.category == category)
                    .toList();
                return MovieCategory(category, categoryMovies);
              }, childCount: 8
                  /*Set<String>.from(movies.map((movie) => movie.category))
                        .length,*/
                  ),
              //       ),
              //     ],
              //   ),
              // )

              /* SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return ListTile(
                    title: Text('Item $index'),
                    onTap: () {
                      print('Tapped on Item $index');
                    },
                  );
                },
                childCount: 20, // Number of items in the list
              ),*/
            )
          ],
        ),
      ),
    );
  }
}

class MovieCategory extends StatefulWidget {
  final String category;
  final List<Movie> movies;

  MovieCategory(this.category, this.movies);

  @override
  _MovieCategoryState createState() => _MovieCategoryState();
}

class _MovieCategoryState extends State<MovieCategory> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterBold(
            text: 'Today',
            fontsize: 18,
            color: color1,
          ),
          SizedBox(height: 30),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
                color: WidgetColor, borderRadius: BorderRadius.circular(10)),
            constraints:
                _expanded ? BoxConstraints(minHeight: 200) : BoxConstraints(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      IconTextWidget(
                        iconSize: 24,
                        icon: Icons.location_on,
                        text: '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
                        useBold: false,
                        color: color13,
                      ),
                      SizedBox(height: 16),
                      Divider(
                        color: color14,
                      ),
                      SizedBox(height: 5),
                      IconTextWidget(
                        iconSize: 24,
                        icon: Icons.access_time,
                        text: '12:00 am TO 12:00 pm',
                        useBold: false,
                        color: color13,
                      ),
                      SizedBox(height: 16),
                      Divider(
                        color: color14,
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: Primarycolor,
                                size: 24,
                              ),
                              SizedBox(width: 20),
                              InterMedium(
                                text: 'Total 6     Completed 0',
                                fontsize: 14,
                                color: color13,
                              )
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _expanded = !_expanded;
                              });
                            },
                            icon: Icon(
                              _expanded
                                  ? Icons.arrow_circle_up_outlined
                                  : Icons.arrow_circle_down_outlined,
                              size: 24,
                              color: Primarycolor,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                /*ListTile(
                  title: Text(
                    widget.category,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {

                    },
                    color: Colors.white,
                  ),
                ),*/
                if (_expanded)
                  Column(
                    children: widget.movies
                        .map(
                          (movie) => Container(
                            height: 70,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 11.0),
                            margin: EdgeInsets.only(top: 10.0),
                            decoration: BoxDecoration(
                              color: color15,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                        color: color16,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.qr_code_scanner,
                                          size: 24,
                                          color: Primarycolor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    InterRegular(
                                      text: '1st floor',
                                      color: color17,
                                      fontsize: 18,
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color16,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.info,
                                        color: color18,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
class GroupTile extends StatefulWidget {
  GroupTile(this.index);

  final int index;

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  bool _isExpanded = false;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 240 + height,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: WidgetColor,
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(microseconds: 10),
      child: Column(
        children: [
          SizedBox(height: 5),
          IconTextWidget(
            iconSize: 24,
            icon: Icons.location_on,
            text: '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
            useBold: false,
            color: color13,
          ),
          SizedBox(height: 16),
          Divider(
            color: color14,
          ),
          SizedBox(height: 5),
          IconTextWidget(
            iconSize: 24,
            icon: Icons.access_time,
            text: '12:00 am TO 12:00 pm',
            useBold: false,
            color: color13,
          ),
          SizedBox(height: 16),
          Divider(
            color: color14,
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Primarycolor,
                    size: 24,
                  ),
                  SizedBox(width: 20),
                  InterMedium(
                    text: 'Total 6     Completed 0',
                    fontsize: 14,
                    color: color13,
                  )
                ],
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  if (_isExpanded) {
                    height = 60 * 12.0;
                  } else
                    height = 0;
                },
                icon: Icon(
                  Icons.arrow_circle_up_outlined,
                  size: 24,
                  color: Primarycolor,
                ),
              )
            ],
          ),
          if (_isExpanded)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 12,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'widget.group.members[index]',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
*/
