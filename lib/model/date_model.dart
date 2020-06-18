abstract class DateInterface {

  int get pageForWeek;
  int get pageForDay;
  DateTime get startDate;
  DateTime get selectedDay;
  DateTime getDayForDailyPage(int page);
  DateTime getDayForWeeklyPage(int page);
  void setDay(DateTime day);
}