import 'package:avapp/models/PlaceModel.dart';
import 'package:avapp/services/DataGridHelper.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../models/PlutoAbstract.dart';
import '../services/DataService.dart';

class EventModel extends IPlutoRowModel {

  String startTimeString() => DateFormat.Hm().format(startTime);
  String durationTimeString() => "${DateFormat.Hm().format(startTime)} - ${DateFormat.Hm().format(endTime)}";
  String durationString() => "${DateFormat("EEEE, MMM d, HH:mm", "cs").format(startTime)} - ${DateFormat.Hm().format(endTime)}";

  int? maxParticipants;
  int maxParticipantsNumber() => maxParticipants == null ? 0 : maxParticipants!;

  final int? id;
  PlaceModel? place;
  List<EventModel> childEvents = [];

  List<int>? parentEventIds;
  List<int>? childEventIds;
  int? currentParticipants;
  String? title = "událost";
  String? description = "";
  bool isSignedIn = false;
  bool splitForMenWomen = false;
  bool isGroupEvent = false;
  DateTime startTime;
  DateTime endTime;

  EventModel({
    required this.startTime,
    required this.endTime,
    required this.id,
    this.title,
    this.description,
    this.maxParticipants,
    this.place,
    this.childEventIds,
    this.parentEventIds,
    required this.splitForMenWomen,
    this.currentParticipants,
    required this.isSignedIn,
    required this.isGroupEvent});

  factory EventModel.fromJson(Map<String, dynamic> json) {
    var eventGroups = json.containsKey(eventGroupsTable) && json[eventGroupsTable] != null ? json[eventGroupsTable] : null;
    List<int>? childEvents;
    List<int>? parentEvents;
    if(eventGroups != null)
    {
      for(var e in eventGroups)
      {
        if(e.containsKey(eventChildColumn))
        {
          childEvents = childEvents ?? [];
          childEvents.add(e[eventChildColumn]);
        }
        if(e.containsKey(eventParentColumn))
        {
          parentEvents = parentEvents ?? [];
          parentEvents.add(e[eventParentColumn]);
        }
      }
    }
    return EventModel(
      startTime: json.containsKey(startTimeColumn) ? DateTime.parse(json[startTimeColumn]) : DateTime.fromMicrosecondsSinceEpoch(0),
      endTime: json.containsKey(endTimeColumn) ? DateTime.parse(json[endTimeColumn]): DateTime.fromMicrosecondsSinceEpoch(0),
      id: json[idColumn],
      title: json.containsKey(titleColumn) ? json[titleColumn] : null,
      description: json.containsKey(descriptionColumn) ? json[descriptionColumn] : null,
      maxParticipants: json.containsKey(maxParticipantsColumn) ? json[maxParticipantsColumn] : null,
      place: json.containsKey(placesTable) && json[placesTable] != null ? PlaceModel.fromJson(json[placesTable]) : null,
      splitForMenWomen: json.containsKey(splitForMenWomenColumn) ? json[splitForMenWomenColumn] : false,
      isSignedIn: json.containsKey("isSignedIn") ? json["isSignedIn"] : false,
      isGroupEvent: json.containsKey(isGroupEventColumn) ? json[isGroupEventColumn] : false,
      childEventIds: childEvents,
      parentEventIds: parentEvents,
      currentParticipants: json.containsKey(eventUsersTable) ? json[eventUsersTable][0]["count"] : json.containsKey("currentParticipants") ? json["currentParticipants"] : null,
  );
  }

  bool isFull() => currentParticipants !>= maxParticipants!;
  static bool canSignIn(EventModel? event) => event != null && event.maxParticipants != null;

  @override
  String toString() {
    return (maxParticipants==null ? title:"$title (${currentParticipants??"-"}/$maxParticipants)")??"";
  }

  copyFromEvent(EventModel event)
  {
    startTime = event.startTime;
    endTime = event.endTime;
    title = event.title;
    description = event.description;
    maxParticipants = event.maxParticipants;
    isGroupEvent = event.isGroupEvent;
  }

  static const String startDateColumn = "startDate";
  static const String startTimeColumn = "start_time";
  static const String endDateColumn = "endDate";
  static const String endTimeColumn = "end_time";
  static const String idColumn = "id";
  static const String titleColumn = "title";
  static const String descriptionColumn = "description";
  static const String descriptionHiddenColumn = "descriptionHidden";
  static const String parentEventColumn = "parentEvent";

  static const String maxParticipantsColumn = "max_participants";
  static const String placeColumn = "place";
  static const String placesTable = "places";
  static const String eventUsersTable = "event_users";
  static const String eventGroupsTable = "event_groups";
  static const String eventChildColumn = "event_child";
  static const String eventParentColumn = "event_parent";

  static const String splitForMenWomenColumn = "split_for_men_women";
  static const String isGroupEventColumn = "is_group_event";

  static EventModel fromPlutoJson(Map<String, dynamic> json) {
    var startTimeString = json[startDateColumn]+"-"+json[startTimeColumn];
    var endTimeString = json[endDateColumn]+"-"+json[endTimeColumn];

    var placeId = DataGridHelper.GetIdFromFormatted(json[placeColumn]);
    var dateFormat = DateFormat("yyyy-MM-dd-HH:mm");

    List<int> parentEvents = [];
    if(json[parentEventColumn].toString().trim().isNotEmpty)
    {
      parentEvents = json[parentEventColumn].toString().split(",").map((e) => int.parse(e.trim())).toList();
    }

    return EventModel(
      startTime: dateFormat.parse(startTimeString),
      endTime: dateFormat.parse(endTimeString),
      id: json[idColumn] == -1 ? null : json[idColumn],
      title: json[titleColumn],
      description: json[descriptionHiddenColumn],
      maxParticipants: json[maxParticipantsColumn] == 0 ? null : json[maxParticipantsColumn],
      place: placeId == null ? null : PlaceModel(id: placeId, title: "", description: "", type: ""),
      splitForMenWomen: json[splitForMenWomenColumn] == "true" ? true : false,
      parentEventIds: parentEvents,
      isSignedIn: false,
      isGroupEvent: json[isGroupEventColumn] == "true" ? true : false
    );
  }

  @override
  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      titleColumn: PlutoCell(value: title),
      descriptionColumn: PlutoCell(value: description),
      descriptionHiddenColumn: PlutoCell(value: description),
      startDateColumn: PlutoCell(value: DateFormat('yyyy-MM-dd').format(startTime)),
      startTimeColumn: PlutoCell(value: DateFormat('HH:mm').format(startTime)),
      endDateColumn: PlutoCell(value: DateFormat('yyyy-MM-dd').format(endTime)),
      endTimeColumn: PlutoCell(value: DateFormat('HH:mm').format(endTime)),
      maxParticipantsColumn: PlutoCell(value: maxParticipants),
      placeColumn: PlutoCell(value: place == null ? PlaceModel.WithouValue : place!.toPlutoSelectString()),
      splitForMenWomenColumn: PlutoCell(value: splitForMenWomen.toString()),
      isGroupEventColumn: PlutoCell(value: isGroupEvent.toString()),
      parentEventColumn: PlutoCell(value: parentEventIds?.map((e) => e.toString()).join(",")??"")
    });
  }

  @override
  Future<void> deleteMethod() async {
    var participants = await DataService.getParticipantsPerEvent(id!);
    for(var p in participants)
    {
      await DataService.signOutFromEvent(this, p);
    }
    await DataService.removeEventFromEventGroups(this);
    await DataService.deleteEvent(this);
  }

  @override
  Future<void> updateMethod() async {
    await DataService.updateEventAndParents(this);
  }

  @override
  String toBasicString() => "$title";

  Map toJson() =>
  {
    idColumn: id,
    startTimeColumn: startTime.toIso8601String(),
    endTimeColumn: endTime.toIso8601String(),
    titleColumn: title,
    descriptionColumn: description,
    maxParticipantsColumn: maxParticipants,
    "currentParticipants": currentParticipants,
    "isSignedIn": isSignedIn,
    isGroupEventColumn: isGroupEvent,
  };
}
