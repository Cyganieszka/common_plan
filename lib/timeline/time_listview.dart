import 'package:flutter/material.dart';

import '../entities.dart';

// whole one day list logic.
// creates proportionally sized and placed containers with provided child
// checks overlapping and builds overlaping events in separate columns

//todo stretch vertical

class TimelineBounds{ // for possibly overlapping events
  final TimeBounded _timeBounds;
  TimeBounded get timeBounds => _timeBounds;

  int index;          // column
  int factor;         // width factor

  bool isIndexed() => index>-1;

  TimelineBounds(this._timeBounds):index=-1,factor=1;
}

class TimeListView extends StatelessWidget{

  final List<TimelineBounds> bounds;
  final List<Widget> widgets;
  final double width;
  final double height;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool overlap;
  final double pixelsPerHour;

  final int allDaySlots;
  final List<Widget> allDayWidgets;

  static double getPixelPerHour(double height,TimeOfDay startTime, TimeOfDay endTime,int allDaySlots){
    return (height-(allDaySlots*20)) / ((timeToDouble(endTime.hour, endTime.minute) - timeToDouble(startTime.hour, startTime.minute))/60);
  }

  static TimeOfDay getCorrectedStartTime(TimeOfDay start,int allDaySlots){
    for(int i=0;i<allDaySlots;i++){
      int hour=start.hour;
      int minute=start.minute;
      if(minute<15){
        start=TimeOfDay(hour: hour-1,minute: 45);
      }else{
        start=TimeOfDay(hour: hour,minute: minute-15);
      }
    }
    return start;
  }

  TimeListView(List<TimeBounded> b, this.widgets,this.startTime,this.endTime,this.height,this.width,{this.overlap = false,this.allDaySlots=0, List<Widget> allDay}):
        allDayWidgets = allDay ?? [],
        bounds= checkOverlapping(b,overlap,startTime,endTime),
        pixelsPerHour= getPixelPerHour(height, startTime, endTime,allDaySlots){

    assert(bounds!=null && widgets!=null);
    assert(bounds.length==widgets.length);

  }

  static List<TimelineBounds> checkOverlapping(List<TimeBounded> events,bool overlap,TimeOfDay startTime,TimeOfDay endTime){
    List<TimelineBounds> list=events.map((e) => TimelineBounds(e)).toList();
    for(int i=0;i<events.length;i++){
      TimeBounded event = events[i];// for every event
      List<int> overlapping=List();
      DateTime marker = event.from;
      int maxOverlap=0;
      while(marker.isBefore(event.to)){ // check max overlapping events for every 15min of event
        int overlaps=0;
        TimeBounded slot = TimeBounded(marker, marker.add(Duration(minutes: 15)));
        for(int j=0;j<events.length;j++) {
          if(i==j)continue;
          TimeBounded other = events[j];
          if(slot.overlapping(other)){
            overlaps++;
            if(!overlapping.contains(j)) {
              overlapping.add(j);// remember overlapping indexes
            }
          }
        }
        if(overlaps>maxOverlap){
          maxOverlap=overlaps;
        }
        marker=marker.add(Duration(minutes: 15));//increment time slot
      }
      // find first free index
      for(int j =0;j<=overlapping.length;j++){
        if(overlapping.firstWhere((e) => list[e].index==j,orElse: () => null,)==null){
          list[i].index=j;
          break;
        }
      }
      list[i].factor=maxOverlap+1;// max overlap as width factor
    }
    return list;
  }



  @override
  Widget build(BuildContext context) {

    List<Widget> elements = List();
    for(int i=0;i<bounds.length;i++){
      elements.add(
        TimelineElement(
          child: widgets[i],
          bounds: bounds[i],
          width: width,
          startTime: startTime,
          pixelsPerHour: pixelsPerHour,
        )
      );

    }


    return Column(
      children: [
        if(allDaySlots>0)Container(
          height: (allDaySlots*30.0),
          decoration: BoxDecoration(color:Colors.grey.withAlpha(100)),
          child: Column(
            children: allDayWidgets.map((e) => Expanded(child: e,flex: 1,)).toList(),
          ),
        ),
        Expanded(
          child: Stack(
            children: elements,
          ),
        ),
      ],
    );

  }

}

class TimelineElement extends StatelessWidget{
  final Widget child;
  final TimelineBounds bounds;
  final double pixelsPerHour;
  final TimeOfDay startTime;
  final double width;


  TimelineElement({this.child, this.bounds, this.pixelsPerHour, this.startTime,
      this.width});

  @override
  Widget build(BuildContext context) {
    double proportionalWidth = width/bounds.factor;
    return TimePositionedContainer(
      shift: bounds.index*proportionalWidth,
      bounds: bounds.timeBounds,
      startTime: startTime,
      pixelsPerHour: pixelsPerHour,
      child: TimeProportionalContainer(
          bounds: bounds.timeBounds,
          pixelsPerHour: pixelsPerHour,
          child: child,
          width:proportionalWidth),
    );
  }

}

class TimePositionedContainer extends StatelessWidget{
  final TimeBounded bounds;
  final TimeOfDay startTime;
  final double pixelsPerHour;
  final Widget child;
  final double shift;


  TimePositionedContainer({Key key,
      this.bounds, this.startTime, this.pixelsPerHour, this.child, this.shift=0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double topDistance =  timeToDouble(bounds.from.hour,bounds.from.minute)-timeToDouble(startTime.hour,startTime.minute);
    return Positioned(
      left: shift,
      top: (topDistance*(pixelsPerHour/60)),
      child: child,);
  }

}

class TimeProportionalContainer extends StatelessWidget{
  final TimeBounded bounds;
  final double pixelsPerHour;
  final Widget child;
  final double width;



  TimeProportionalContainer({Key key,this.bounds, this.pixelsPerHour, this.child, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration duration = bounds.duration;
    double height = (duration.inMinutes * (pixelsPerHour/60));

    return SizedBox(width:width,height: height, child: child);
  }

}

double timeToDouble(int hour, int minute) {
  return (minute + (hour * 60)).toDouble();
}
