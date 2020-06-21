import 'package:auto_size_text/auto_size_text.dart';
import 'package:common_plan/timeline/time_listview.dart';
import 'package:flutter/material.dart';

import '../entities.dart';

class TimelineBackground extends StatelessWidget {
  final TimeOfDay start;
  final TimeOfDay end;
  final Duration d;
  final bool show15min;
  final double height, width;
  final List<TimeOfDay> hoursToDisplay;
  final int allDaySlots;

  TimelineBackground(this.start, this.end, this.height, this.width,this.hoursToDisplay,
      {this.show15min = true,this.allDaySlots=0})
      : d = maxDayPlanDuration(start, end);

  final BorderSide thinBorder = BorderSide(
    color: Colors.grey.withAlpha(200),
    width: 0.2,
  );
  final BorderSide thickBorder = BorderSide(
    color: Colors.grey.withAlpha(200),
    width: 0.5,
  );

  Widget buildHour(int hour){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(
        child: Center(
          child: AutoSizeText(
            "${(hour).toString().padLeft(2, "0")}",
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300),
            minFontSize: 8,
            maxFontSize: 13,
          ),
        ),
      )],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<EmptyBounds> hours = List();
    List<Widget> hourWidgets = List();


    for (int i = 0; i < d.inHours; i++) {
      TimeOfDay timeQ1 = TimeOfDay(hour: start.hour + i, minute: 0);
      TimeOfDay timeQ2 = TimeOfDay(hour: start.hour + i, minute: 15);
      TimeOfDay timeQ3 = TimeOfDay(hour: start.hour + i, minute: 30);
      TimeOfDay timeQ4 = TimeOfDay(hour: start.hour + i, minute: 45);
      hours.add(EmptyBounds.time(
          timeQ1, TimeOfDay(hour: start.hour + i + 1, minute: 0)));
      hourWidgets.add(Container(
        child: show15min
            ? Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(child: (hoursToDisplay.contains(timeQ1))
                            ? buildHour(start.hour + i)
                            : Container(),
                        decoration: BoxDecoration(
                            border: Border(
                              top: thickBorder
                            ))),
                      ),
                      Expanded(
                        child: Container(
                          child: (hoursToDisplay.contains(timeQ2))
                              ? buildHour(start.hour + i)
                              : Container(),
                          decoration: BoxDecoration(
                              border: Border(
                            top: thinBorder
                          )),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: (hoursToDisplay.contains(timeQ3))
                              ? buildHour(start.hour + i)
                              : Container(),
                          decoration: BoxDecoration(
                              border: Border(
                            top: thinBorder,
                          )),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: (hoursToDisplay.contains(timeQ4))
                              ? buildHour(start.hour + i)
                              : Container(),
                          decoration: BoxDecoration(
                              border: Border(
                            top: thinBorder,
                          )),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Container(),
      ));
    }

    return TimeListView(
      hours,
      hourWidgets,
      start,
      end,
      height,
      width,
      overlap: true,
      allDaySlots: allDaySlots,
    );
  }
}

Duration maxDayPlanDuration(TimeOfDay timelineStart, TimeOfDay timeLineEnd) {
  return Duration(
      hours: timeLineEnd.hour - timelineStart.hour,
      minutes: timeLineEnd.minute - timelineStart.minute);
}
