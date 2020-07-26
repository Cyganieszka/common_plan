import 'package:common_plan/tile.dart';
import 'package:common_plan/timeline/time_listview.dart';
import 'package:common_plan/timeline/timeline_background.dart';
import 'package:flutter/material.dart';
import 'package:rect_getter/rect_getter.dart';

import 'model/date_model.dart';
import 'model/plan_model.dart';

abstract class HeroView extends StatefulWidget {
  final PlanInterface planModel;
  final DateInterface dateModel;

  final double headerHeight;
  final double bottomMargin;
  final double timeColumnWidth;
  final double allDayHeight;

  HeroView(this.planModel,this.dateModel,{this.headerHeight=35,this.allDayHeight= 60,this.bottomMargin=20,this.timeColumnWidth=20});

  Widget buildTimeLine(PlanInterface plan,{bool quater= true,bool hours=false});

  Widget buildWeekHeader(PlanInterface plan,List weekKeys, PageController headerController,Function showDayView);
  Widget buildAllDayHeader(PlanInterface plan,List weekKeys, PageController headerController,Function showDayView);
  Widget buildWeekView(PageController weekController,List weekKeys, Function showDayView,bool isDayViewVisible,bool animating);
  Widget buildDayView(PageController weekController,PageController dayController,List dayKeys, bool isDayViewVisible);

  Color getColorForType(String type);

  @override
  _HeroViewState createState() => _HeroViewState();
}

class _HeroViewState extends State<HeroView>
    with SingleTickerProviderStateMixin {
  List dayKeys = List.generate(365, (i) => RectGetter.createGlobalKey());
  List weekKeys = List.generate(365, (i) => RectGetter.createGlobalKey());

  bool isDayViewVisible = false;
  PageController _headerController;
  PageController _allDayController;
  PageController _weekController;
  PageController _dayController;

  AnimationController _animationController; //<-- Add AnimationController
  Animation<Rect> rectAnimation;

  OverlayEntry transitionOverlayEntry; //<--add OverlayEntry field

  @override
  void initState() {
    super.initState();
    print("INIT page for week ${widget.dateModel.pageForWeek} day: ${widget.dateModel.pageForDay}");
    _allDayController = PageController(initialPage: widget.dateModel.pageForWeek);
    _headerController = PageController(initialPage: widget.dateModel.pageForWeek);
    _weekController = PageController(initialPage: widget.dateModel.pageForWeek)
      ..addListener(_onWeekScroll);
    _dayController= PageController(initialPage: widget.dateModel.pageForDay);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    transitionOverlayEntry = createOverlayEntry(); //<--create OverlayEntry

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        transitionOverlayEntry.remove(); //<-- remove Entry from the Overlay
      }
      if (status == AnimationStatus.completed) {
        _setPageViewVisible(true);
      } else if (status == AnimationStatus.reverse) {
        _setPageViewVisible(false);
      }
    });
    print("init day page:${widget.dateModel.pageForDay} init week page${widget.dateModel.pageForWeek}");

  }



  @override
  void dispose() {
    _headerController.dispose();
    _allDayController.dispose();
    _weekController.dispose();
    _dayController.dispose();
    _animationController.dispose(); //<-- Remember to dispose the controller
    super.dispose();
  }

  void _setPageViewVisible(bool visible) {
    setState(() => isDayViewVisible = visible);
  }

  void _showDayView(DateTime date,GlobalKey weekRect) async {
    animating=true;
    widget.dateModel.setDay(date);
    _dayController.jumpToPage(widget.dateModel.pageForDay);
    print("jump to page:" + widget.dateModel.pageForDay.toString());
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(true, widget.dateModel.pageForDay);
    widget.planModel.showDetailView();
    animating=false;
  }


  void _showWeekView() async {
    animating=true;
    print("jump from page:" + widget.dateModel.pageForDay.toString());
    await Future.delayed(Duration(milliseconds: 100));
    _startTransition(false, widget.dateModel.pageForDay);
    _weekController.jumpToPage(widget.dateModel.pageForWeek);
    widget.planModel.showMasterView();
    animating=false;
  }

  OverlayEntry createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        DateTime day = widget.dateModel.selectedDay;

        List<Widget> elements = List();
        for (int i = 0; i < widget.planModel.getDayPlan(day).length; i++) {
          elements.add(
              Tile.empty(
                  color:widget.planModel.getDayPlan(day)[i].color
              )
          );
        }

        Widget dayView = Padding(
            padding: EdgeInsets.fromLTRB(0, widget.headerHeight, 0, 0),
            child:
            LayoutBuilder(builder:
                (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: TimeListView(
                        widget.planModel.getDayPlan(day),
                        elements,
                        widget.planModel.getStartTimeForSelectedWeek(widget.dateModel.selectedDay),
                        widget.planModel.getEndTimeForSelectedWeek(widget.dateModel.selectedDay),
                        constraints.maxHeight,
                        constraints.maxWidth),
                  ),
                ],
              );
            }));

        return AnimatedBuilder(
          //<-- rebuild when animation changes
          animation: rectAnimation,
          builder: (context, child) {
            return Positioned(
              top: rectAnimation.value.top,
              left: rectAnimation.value.left,
              child: SizedBox(
                child: dayView,
                height: rectAnimation.value.height,
                width: rectAnimation.value.width,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // <--- on back press
        if (isDayViewVisible) {
          // <--- if page view is visible
          _showWeekView(); // <--- hide page view
          return false; // <--- and don't close app
        }
        return true; // <--- otherwise close the app
      },
      child: Stack(
        children: <Widget>[
          Positioned(child: _buildHoursLine(widget.planModel),left:0,
            top: widget.headerHeight+widget.allDayHeight,
            bottom: widget.bottomMargin,),
          Positioned(child: widget.buildWeekHeader(widget.planModel,weekKeys,_headerController,_showDayView),
            left: widget.timeColumnWidth,
            top: widget.allDayHeight,
            height: widget.headerHeight,),
          Positioned(child: widget.buildAllDayHeader(widget.planModel,weekKeys,_allDayController,_showDayView),
            left: widget.timeColumnWidth,
            top: 0,
            height: widget.allDayHeight,),
          Positioned.fill(child: widget.buildTimeLine(widget.planModel),
            left: widget.timeColumnWidth,
            top: widget.headerHeight+widget.allDayHeight,
            bottom: widget.bottomMargin,),
          Positioned.fill(child: widget.buildWeekView(_weekController,weekKeys,_showDayView,isDayViewVisible,animating),
            left: widget.timeColumnWidth,
            top: 0,
            bottom: widget.bottomMargin,),
          Positioned.fill(child: widget.buildDayView(_weekController,_dayController,dayKeys,isDayViewVisible),
            left:widget.timeColumnWidth,
            top: 0,
            bottom: widget.bottomMargin,),
          // <--- build PageView ON TOP of GridView
        ],
      ),
    );
  }
  @override
  void didUpdateWidget(HeroView oldWidget) {
    if(isDayViewVisible != widget.planModel.isDetailView){
      if(!widget.planModel.isDetailView){
        _showWeekView();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  _onWeekScroll() {
    _headerController.jumpTo(_weekController.offset);
  }

  Widget _buildHoursLine(PlanInterface plan,{bool quater= true,bool hours=false}) {

    TimeOfDay start = plan.getStartTimeForSelectedWeek(widget.dateModel.selectedDay);
    TimeOfDay end = plan.getEndTimeForSelectedWeek(widget.dateModel.selectedDay);

    List<TimeOfDay> hours = List();

    for (var h =start.hour;h<end.hour;h++) {
      hours.add(TimeOfDay(hour:h,minute: 0));
    }

    return Container(
      width: 20,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: TimelineBackground(start, end, constraints.maxHeight, widget.timeColumnWidth,hours,allDaySlots: plan.getAllDayEventsForSelectedWeek(widget.dateModel.selectedDay),),
                ),
              ],
            );
          }),
    );
  }





  bool animating=false;

  void _startTransition(bool toDay, int currentIndex) {

    Rect dayRect = RectGetter.getRectFromKey(dayKeys[currentIndex]);
    Rect weekRect = RectGetter.getRectFromKey(weekKeys[currentIndex]);

    rectAnimation = RectTween(
      //<-- create an animation between gridRect and pageRect
      begin: weekRect,
      end: dayRect,
    ).animate(_animationController);

    Overlay.of(context)
        .insert(transitionOverlayEntry); //<-- Add Entry to the Overlay

    if (toDay) {
      _animationController.forward(); //<--run the animation
    } else {
      _animationController.reverse();
    }
  }
}
