import 'package:festapp/styles/Styles.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';
import 'package:festapp/appConfig.dart';

import '../models/EventModel.dart';

enum DotType {
  dot, open, closed
}

class TimeLineItem{
  DateTime startTime;
  DotType dotType;
  String leftText;
  String rightText;
  int id;

  TimeLineItem({
    required this.dotType,
    required this.startTime,
    required this.leftText,
    required this.rightText,
    required this.id
  });

  static DotType getIndicatorFromEvent(EventModel model)
  {
      if (model.isSignedIn) {
        return DotType.closed;
      }
      else if(model.isGroupEvent && model.isMyGroupEvent)
      {
        return DotType.closed;
      }
      else if(model.currentParticipants != null && model.maxParticipants != null && model.isFull())
      {
        return DotType.dot;
      }
      else if (EventModel.canSignIn(model))
      {
        return DotType.open;
      }
      return DotType.dot;
  }

  factory TimeLineItem.fromEventModel(EventModel model) {
    return TimeLineItem(
    startTime: model.startTime,
    dotType: getIndicatorFromEvent(model),
    id: model.id!,
    leftText: model.startTimeString(),
    rightText: model.toString(),
  );
  }

  factory TimeLineItem.fromEventModelAsChild(EventModel model) {
    return TimeLineItem(
      startTime: model.startTime,
      dotType: getIndicatorFromEvent(model),
      id: model.id!,
      leftText: model.durationTimeString(),
      rightText: model.toString(),
    );
  }
}

class ScheduleTimeline extends StatefulWidget {
  Function(int)? onEventPressed;

  List<TimeLineItem> events = [];
  double? nodePosition;

  bool? splitByDay;

  ScheduleTimeline({super.key, required this.events, this.onEventPressed, this.nodePosition = 0.24, this.splitByDay = false});

  @override
  _ScheduleTimelineState createState() =>
      _ScheduleTimelineState();
}

class _ScheduleTimelineState extends State<ScheduleTimeline> {

  @override
  Widget build(BuildContext context) {
    if(widget.splitByDay!) {
      var groupByDay = widget.events.groupListsBy((element) =>
          buildDayFormat(element));
      List<Widget> children = [];
      for (var group in groupByDay.entries) {
        children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 18, 0, 12),
              child: Text(
                group.key,
                style: timeLineSplitTextStyle,
              ),));
        children.add(createTimeline(group.value));
      }

      if (children.isEmpty)
      {
        return Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24,88,24,24),
            child: AppConfig.isOwnProgramSupported ?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Create your own schedule with button".tr()+ " ", style: const TextStyle(fontSize: 20)),
              const Icon(Icons.add_circle_outline)
            ],) :
             const Text(
              "There will appear your events.",
                style: TextStyle(fontSize: 20)
              ).tr(),
          ),
        );
      }
      return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ));
    }

    var morningEvents = widget.events.where((e) => e.startTime.hour <= 12).toList();
    var afternoonEvents = widget.events
        .where((e) => e.startTime.hour > 12 && e.startTime.hour < 18)
        .toList();
    var eveningEvents = widget.events.where((e) => e.startTime.hour >= 18).toList();
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
    createTimeline(morningEvents),
    afternoonEvents.isNotEmpty && morningEvents.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(48, 18, 0, 12),
            child: Text(
              "Afternoon".tr(),
              style: timeLineSplitTextStyle,
            ),
          )
        : const SizedBox.shrink(),
    createTimeline(afternoonEvents),
    eveningEvents.isNotEmpty && afternoonEvents.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(48, 18, 0, 12),
            child: Text(
              "Evening".tr(),
              style: timeLineSplitTextStyle,
            ),
          )
        : const SizedBox.shrink(),
    createTimeline(eveningEvents),
          ],
        );
  }

  String buildDayFormat(TimeLineItem element) {
    var result = DateFormat("EEEE d. MMMM ", context.locale.languageCode).format(element.startTime);
    result = result[0].toUpperCase() + result.substring(1);
    return result;
  }

  Timeline createTimeline(List<TimeLineItem> events) {
    return Timeline.tileBuilder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      theme: TimelineTheme.of(context).copyWith(
        nodePosition: widget.nodePosition,
        indicatorTheme:
            IndicatorTheme.of(context).copyWith(color: AppConfig.timelineColor),
        connectorTheme: ConnectorTheme.of(context)
            .copyWith(color: AppConfig.timelineColor, thickness: 2),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: events.length,
        contentsAlign: ContentsAlign.basic,
        oppositeContentsBuilder: (_, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(event.leftText, style: timeLineSmallTextStyle,),
          );
        },
        contentsBuilder: (_, index) {
          final event = events[index];
          //return Text(event.maxParticipants == null ? event.title : "${event.title} (${event.currentParticipants}/${event.maxParticipants})");
          return TextButton(
              onPressed: () => widget.onEventPressed!(event.id),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                alignment: Alignment.centerLeft
              ),
              child: Text(event.rightText, style: timeLineSmallTextStyle,));
        },
        indicatorBuilder: (_, index) {
          final event = events[index];
          return event.dotType != DotType.dot
              ? OutlinedDotIndicator(
                  color: AppConfig.timelineColor, borderWidth: event.dotType == DotType.closed ? 6 : 2)
              : const Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 3.5),
                  child: DotIndicator(color: AppConfig.timelineColor, size: 8));
        },
        connectorBuilder: (_, index, __) {
          return const SolidLineConnector();
        },
      ),
    );
  }
}
