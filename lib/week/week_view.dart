import 'package:common_plan/day/day_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rect_getter/rect_getter.dart';

import '../entities.dart';




abstract class WeekView extends StatelessWidget {

  final Map<DateTime,List<Event>> weeklyPlan;
  final int weekNo;
  final Function(DateTime,GlobalKey) onDayTouched;
  final List keys;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double headerMargin;
  final int allDayEvents;

  WeekView(this.weekNo,this.weeklyPlan,this.onDayTouched,this.keys,this.startTime,this.endTime,{this.headerMargin=0,this.allDayEvents=0});

  DayView buildWeekDayView(List<Event> events, DateTime day,int allDayEvents);
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: weeklyPlan.entries.map((entry) {
              DateTime day = entry.key;
              List<Event> events =entry.value;
              events.sort((a, b) => a.from.compareTo(b.from));
              return Expanded(
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      onDayTouched(day, keys[day.weekday-1]);
                    },
                    child: Stack(
                      children: <Widget>[
                        RectGetter(
                          key: keys[day.weekday-1],
                          child: buildWeekDayView(events,day,allDayEvents),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(decoration: BoxDecoration(color: Colors.grey),width: 0.1,),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0,0,0,0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(decoration: BoxDecoration(color: Colors.grey),width: 0.1,),
                          ),
                        )
                      ],

                    )),
                flex: events.isEmpty ? 1: 3,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
