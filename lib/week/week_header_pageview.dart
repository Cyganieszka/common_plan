import 'package:common_plan/model/date_model.dart';
import 'package:flutter/material.dart';


class WeekHeaderPageView extends StatelessWidget{

  final DateInterface dateModel;
  final PageController controller;
  final Function(int) buildWeekHeaderForPosition;

  WeekHeaderPageView({Key key, this.dateModel, this.controller, this.buildWeekHeaderForPosition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: NeverScrollableScrollPhysics(),
      controller: controller,
      itemBuilder: (context, position) {
        return buildWeekHeaderForPosition(position);
      },
      itemCount: null,
    );
  }

}