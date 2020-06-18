import 'package:common_plan/model/date_model.dart';
import 'package:flutter/material.dart';


class WeekPageView extends StatelessWidget{

  final DateInterface dateModel;
  final PageController controller;
  final Function(int) buildWeekViewForPosition;


  WeekPageView(this.dateModel,this.controller,this.buildWeekViewForPosition);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: PageView.builder(
              controller: controller,
              itemBuilder: (context, position) {
                return buildWeekViewForPosition(position);
              },
              itemCount: null, // Can be null
              onPageChanged: (page) {
                dateModel.setDay(dateModel.getDayForWeeklyPage(page));
              },
            )),
      ],
    );
  }

}