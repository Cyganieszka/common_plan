
import 'package:common_plan/model/date_model.dart';
import 'package:flutter/material.dart';


class DayPageView extends StatelessWidget{

  final DateInterface dateModel;
  final PageController controller;
  final Function(int) buildDayViewForPosition;
  final PageController weekController;

  DayPageView( this.dateModel, this.controller,this.weekController, this.buildDayViewForPosition);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
            child: PageView.builder(
              controller: controller,
              itemBuilder: (context, position) {
                return buildDayViewForPosition(position);
              },
              onPageChanged: (page) {
                dateModel.setDay(dateModel.getDayForDailyPage(page));//todo make setpage method
                weekController.animateToPage(dateModel.pageForWeek,curve: Curves.easeIn,duration: Duration(milliseconds: 300));
              },
            )),
      ],
    );
  }

}