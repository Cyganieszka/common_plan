import 'package:flutter/material.dart';
import '../entities.dart';
import '../event_list.dart';



abstract class DayView extends StatelessWidget {
  final List<Event> events;
  final bool isToday;
  final bool detailed;
  final TimeOfDay timelineStart;
  final TimeOfDay timelineEnd;
  final double headerMargin;

  EventList buildEventList();

  DayView(this.events,DateTime day,this.timelineStart,this.timelineEnd,this.detailed,this.headerMargin):
        isToday= day.day == DateTime.now().day && day.month == DateTime.now().month && day.year == DateTime.now().year
  {
    events.sort((a, b) => a.from.compareTo(b.from));
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: <Widget>[
        Positioned.fill(child: buildEventList(),top: headerMargin)
      ],
    );
  }
}







