import 'package:flutter/material.dart';

import 'entities.dart';
import 'tile.dart';
import 'timeline/time_listview.dart';


abstract class EventList<T extends Event> extends StatelessWidget {
  final List<T> events;
  final bool isDetailed;
  final TimeOfDay timelineStart;
  final TimeOfDay timelineEnd;
  final int allDaySlots;

  Tile buildTileForEvent(T event, bool isDetailed,{bool isMultiday=false});

  EventList(this.events, this.isDetailed, {this.timelineStart,this.timelineEnd,this.allDaySlots=0});

  Widget getList() {
    List<Widget> tileList = List();
    List<Widget> allDayTileList = List();
    List<Widget> multiDayTileList = List();
    List<T> hourlyEvents=List();
    for (int i = 0; i < events.length; i++) {
      var event = events[i];
      if(event.allDay){
        allDayTileList.add(buildTileForEvent(event, isDetailed));
      }else if(event.multiday){
        allDayTileList.add(buildTileForEvent(event, isDetailed,isMultiday: true));
      }
      else {
        tileList.add(buildTileForEvent(event, isDetailed));
        hourlyEvents.add(event);
      }
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return TimeListView(hourlyEvents,tileList, timelineStart,timelineEnd,constraints.maxHeight,constraints.maxWidth,allDay: allDayTileList,allDaySlots: allDaySlots,);
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