import 'package:common_plan/model/date_model.dart';
import 'package:flutter/material.dart';


class WeekAllDayPageView extends StatelessWidget{

  final DateInterface dateModel;
  final PageController controller;
  final Function(int) buildAllDayForPosition;

  WeekAllDayPageView({Key key, this.dateModel, this.controller, this.buildAllDayForPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: controller,
      itemBuilder: (context, position) {
        return buildAllDayForPosition(position);
      },
      itemCount: null,
    );
  }

}