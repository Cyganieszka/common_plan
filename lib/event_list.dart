import 'package:flutter/material.dart';

import 'entities.dart';
import 'tile.dart';
import 'timeline/time_listview.dart';


abstract class EventList<T extends Event> extends StatelessWidget {
  final List<T> events;
  final bool isDetailed;
  final TimeOfDay timelineStart;
  final TimeOfDay timelineEnd;

  Tile buildTileForEvent(T event, bool isDetailed,{bool isMultiday=false});

  EventList(this.events, this.isDetailed, {this.timelineStart,this.timelineEnd});

  Widget getList() {
    List<Widget> tileList = List();

    List<T> hourlyEvents=List();
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      tileList.add(buildTileForEvent(event, isDetailed));
      hourlyEvents.add(event);
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return TimeListView(hourlyEvents,tileList, timelineStart,timelineEnd,constraints.maxHeight,constraints.maxWidth);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Flexible(child:getList()),
      ],
    );

  }
}