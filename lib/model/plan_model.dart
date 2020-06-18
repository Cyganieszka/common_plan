import 'package:flutter/material.dart';
import '../entities.dart';


abstract class PlanInterface {
  List<Event> getDayPlan(DateTime day);

  TimeOfDay getStartTimeForSelectedWeek(DateTime day);
  TimeOfDay getEndTimeForSelectedWeek(DateTime day);

  Map<DateTime, List<Event>>  getWeekPlan(DateTime day);

  void showDetailView();
  void showMasterView();

  bool get isDetailView;
  DateTime get firstDate;
  DateTime get lastDate;
}
//todo consinder
//abstract class HeroModel{
//  void showDetailView();
//  void showMasterView();
//  bool get isDetailView;
//}