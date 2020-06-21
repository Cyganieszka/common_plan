// plans are just projection of event on given timeline

import 'package:flutter/material.dart';

abstract class Event extends TimeBounded{
  final String title;
  final Color color;
  final bool allDay;
  final bool multiday;
  Event(DateTime from, DateTime to, this.title,this.color) : allDay= "${from.hour}${from.minute}${to.hour}${to.minute}"=="0000", multiday = "${from.year}${from.day}${from.month}"!="${to.year}${to.day}${to.month}" && from.difference(to).inHours>24, super(from, to);

  List<DateTime> getDays(){
    DateTime marker=DateTime(from.year,from.month,from.day);
    List<DateTime> days=[];
    while(marker.isBefore(to)){
      days.add(marker);
      marker=marker.add(Duration(days: 1));
    }
    return days;
  }

}

class EmptyBounds extends TimeBounded{
  EmptyBounds(DateTime from, DateTime to) : super(from, to);
  EmptyBounds.time(TimeOfDay from, TimeOfDay to) : super(DateTime(2000,1,1,from.hour,from.minute), DateTime(2000,1,1,to.hour,to.minute));

  @override
  TimeFrame getActiveFrame() {
    return this.timeFrame;
  }
}

 class TimeBounded{

  TimeFrame timeFrame;

  TimeBounded(DateTime from, DateTime to){
    timeFrame = TimeFrame(from, to);
  }

  Duration get duration => to.difference(from);

  EmptyBounds getBoundsToHour(TimeOfDay time){
    DateTime targetTime = DateTime(from.year,from.month,from.day,time.hour,time.minute);
    if(targetTime.isBefore(from)){
      return EmptyBounds(targetTime,from);
    }else if(targetTime.isAfter(from)){
      return EmptyBounds(to,targetTime);
    }else{
      return EmptyBounds(to.subtract(Duration(seconds: 1)),targetTime.add(Duration(seconds: 1)));
    }
  }

  bool isAfter(DateTime dt) {
    return timeFrame.to.isAfter(dt);
  }

  bool isBefore(DateTime dt) {
    return timeFrame.from.isBefore(dt);
  }

  String getStartTimeString(){
    return getPaddedString(timeFrame.from.hour)+":"+getPaddedString(timeFrame.from.minute);
  }
  String getEndTimeString(){
    return getPaddedString(timeFrame.to.hour)+":"+getPaddedString(timeFrame.to.minute);
  }

  TimeOfDay get startTime => TimeOfDay(hour: from.hour,minute: from.minute);
  TimeOfDay get endTime => TimeOfDay(hour: to.hour,minute: to.minute);

  DateTime get to {
    return timeFrame.to;
  }


  DateTime get from {
    return timeFrame.from;
  }

  TimeFrame getActiveFrame() {
    return this.timeFrame;
  }

  TimeFrame getBounds(){
    return timeFrame;
  }

  bool overlapping(TimeBounded other){
    return timeFrame.overlapping(other.timeFrame);
  }


}

class TimeFrame {
  final DateTime from;
  final DateTime to;

  TimeFrame(this.from, this.to){
    assert(from.isBefore(to));
  }

  bool match(DateTime dateTime){
    return dateTime.isAfter(from) && dateTime.isBefore(to);
  }

  bool overlapping(TimeFrame other){
    return other.from.isBefore(to) && other.to.isAfter(from);
  }

  Duration timeUntilStart(DateTime dateTime){
    if(dateTime.isBefore(from)) {
      return dateTime.difference(from);
    }else{
      return Duration.zero;
    }
  }

  Duration timeLeft(DateTime dateTime){
    if(match(dateTime)) {
      return dateTime.difference(to);
    }else{
      return Duration.zero;
    }
  }

   static TimeFrame getActiveFrame( List<TimeBounded> tbl){

    DateTime first;
    DateTime last;

    for(TimeBounded tb in tbl){
      if(first==null || tb.isBefore(first)){
        first=tb.from;
      }
      if(last==null || tb.isAfter(last)){
        last = tb.to;
      }
    }

    assert(first!=null && last!=null);

    return TimeFrame(first,last);
  }

  static TimeFrame cropToBounds(TimeFrame tf, TimeFrame bounds){

    DateTime activeFrom = tf.from;
    DateTime activeTo = tf.to;
    if(activeFrom.isBefore(bounds.from)){
      activeFrom=bounds.from;
    }
    if(activeTo.isAfter(bounds.to)){
      activeTo=bounds.to;
    }
    if(activeFrom!= tf.from || activeTo != tf.to){
      return TimeFrame(activeFrom,activeTo);
    }else {
      return tf;
    }
  }
}

//todo move to utils
getPaddedString(int val) {
  return val.toString().padLeft(2, "0");
}

