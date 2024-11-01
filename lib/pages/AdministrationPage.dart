import 'package:auto_route/auto_route.dart';
import 'package:fstapp/AppRouter.gr.dart';
import 'package:fstapp/appConfig.dart';
import 'package:fstapp/dataModels/EventModel.dart';
import 'package:fstapp/dataModels/InformationModel.dart';
import 'package:fstapp/dataServices/AuthService.dart';
import 'package:fstapp/dataServices/DbEvents.dart';
import 'package:fstapp/dataServices/DbGroups.dart';
import 'package:fstapp/dataServices/DbInformation.dart';
import 'package:fstapp/dataServices/DbPlaces.dart';
import 'package:fstapp/dataServices/DbUsers.dart';
import 'package:fstapp/dataServices/RightsService.dart';
import 'package:fstapp/components/dataGrid/DataGridAction.dart';
import 'package:fstapp/components/dataGrid/SingleTableDataGrid.dart';
import 'package:fstapp/dataModels/ExclusiveGroupModel.dart';
import 'package:fstapp/dataModels/IconModel.dart';
import 'package:fstapp/dataModels/OccasionModel.dart';
import 'package:fstapp/dataModels/OccasionUserModel.dart';
import 'package:fstapp/dataModels/PlaceModel.dart';
import 'package:fstapp/dataModels/Tb.dart';
import 'package:fstapp/dataModels/UserGroupInfoModel.dart';
import 'package:fstapp/dataModels/UserInfoModel.dart';
import 'package:fstapp/dataServices/SynchroService.dart';
import 'package:fstapp/pages/MapPage.dart';
import 'package:fstapp/components/dataGrid/DataGridHelper.dart';
import 'package:fstapp/RouterService.dart';
import 'package:fstapp/services/ToastHelper.dart';
import 'package:fstapp/services/UserManagementHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import '../services/DialogHelper.dart';
import 'HtmlEditorPage.dart';

@RoutePage()
class AdministrationPage extends StatefulWidget {
  static const ROUTE = "admin";
  const AdministrationPage({Key? key}) : super(key: key);

  @override
  _AdministrationPageState createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> with SingleTickerProviderStateMixin {
  OccasionModel? occasionModel;
  List<String> places = [];
  List<PlutoColumn> columns = [];
  List<int?> mapIcons = [];
  List<IconModel> svgIcons = [];
  bool isAdmin = false;
  late TabController _tabController;


  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if(!RightsService.canSeeAdmin())
    {
      RouterService.popOrHome(context);
      return;
    }

    loadData();
  }

  Future<void> loadData() async {
    occasionModel = await DbUsers.getOccasion(RightsService.currentOccasion!);
    await loadPlaces();
    svgIcons = await DbPlaces.getAllIcons();
    mapIcons.addAll(svgIcons.map((s)=>s.id));
    mapIcons.add(null);
    setState(() {});
  }

  Future<void> loadPlaces() async {
    var placesRaws =  await DbPlaces.getMapPlaces();
    var placesStrings = placesRaws.map((p)=>p.toPlutoSelectString()).toList();
    placesStrings.add(PlaceModel.WithouValue);
    setState(() {
      places = placesStrings;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
  }

  @override
  Widget build(BuildContext context) {

    return  DefaultTabController(
      length: _tabController.length,
      child: Scaffold(
          appBar: AppBar(
          title: const Text("Admin").tr(),
          leading: BackButton(
            onPressed: () => RouterService.popOrHome(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                controller: _tabController,
                  isScrollable: true,
                tabs: [
                  Row(
                  children: [
                    const Icon(Icons.info),
                    Padding(padding: const EdgeInsets.all(12), child: const Text("Info").tr())
                    ]
                  ),
                  Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        Padding(padding: const EdgeInsets.all(12), child: const Text("Events").tr())
                      ]
                  ),
                  Row(
                      children: [
                        const Icon(Icons.pin_drop),
                        Padding(padding: const EdgeInsets.all(12), child: const Text("Places").tr())
                      ]
                  ),
                  Row(
                      children: [
                        const Icon(Icons.punch_clock_rounded),
                        Padding(padding: const EdgeInsets.all(12), child: const Text("Exclusivity").tr())
                      ]
                  ),
                  Row(
                      children: [
                        const Icon(Icons.groups),
                        Padding(padding: const EdgeInsets.all(12), child: const Text("Groups").tr())
                      ]
                  ),
                  Row(
                      children: [
                        const Icon(Icons.people),
                        Padding(padding: const EdgeInsets.all(12), child: const Text("Users").tr())
                      ]
                  ),
                  // Row(
                  //     children: [
                  //       Icon(Icons.settings),
                  //       Padding(padding: EdgeInsets.all(12), child: Text("Nastavení"))
                  //     ]
                  // )
                ]
              ),
            ),
          )),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleTableDataGrid<InformationModel>(
                context,
                DbInformation.getAllInformationForDataGrid,
                InformationModel.fromPlutoJson,
                DataGridFirstColumn.deleteAndDuplicate,
                Tb.information.id,
                columns: [
                  PlutoColumn(
                      hide: true,
                      title: "Id".tr(),
                      field: Tb.information.id,
                      type: PlutoColumnType.number(defaultValue: -1),
                      readOnly: true,
                      width: 50,
                      renderer: (rendererContext) => DataGridHelper.idRenderer(rendererContext),),
                  PlutoColumn(
                    title: "Hide".tr(),
                    field: Tb.information.is_hidden,
                    type: PlutoColumnType.select(places),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.information.is_hidden),
                  ),
                  PlutoColumn(
                      title: "Title".tr(),
                      field: Tb.information.title,
                      type: PlutoColumnType.text()),
                  PlutoColumn(
                      width: 150,
                      title: "Content".tr(),
                      field: Tb.information.description,
                      type: PlutoColumnType.text(),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: () async{
                              String? textToEdit;
                              String? oldText = rendererContext.row.cells[Tb.information.description]?.value;
                              if(oldText!=null)
                              {
                                textToEdit = oldText;
                              }
                              Future<String?> Function() load = () async {
                                var id = rendererContext.row.cells[Tb.information.id]!.value;

                                if(id!=null)
                                {
                                  var infoDescription = await DbInformation.getInfosDescription([id]);
                                  if(infoDescription.isNotEmpty){
                                    return infoDescription[0].description;
                                  }
                                }
                                return null;
                              };
                              Map<String, dynamic> param = {HtmlEditorPage.parContent: textToEdit, HtmlEditorPage.parLoad: load};
                              RouterService.navigatePageInfo(context, HtmlEditorRoute(content: param)).then((value) async {
                                if(value != null)
                                {
                                  var newText = value as String;
                                  if(newText!=textToEdit)
                                  {
                                    rendererContext.row.cells[Tb.information.description]?.value = newText;
                                    var cell = rendererContext.row.cells[Tb.information.description]!;
                                    rendererContext.stateManager.changeCellValue(cell, cell.value, force: true);
                                  }
                                }
                              });},
                            child: Row(children: [Icon(Icons.edit), Padding(padding: EdgeInsets.all(6), child: Text("Edit".tr())) ])
                        );
                      }),
                  PlutoColumn(
                    title: "Order".tr(),
                    field: Tb.information.order,
                    type: PlutoColumnType.number(defaultValue: null),
                    applyFormatterInEditing: true,
                    width: 100,
                  ),
                  PlutoColumn(
                      title: "Type".tr(),
                      field: Tb.information.type,
                      type: PlutoColumnType.text()),
                ]).DataGrid(),
            SingleTableDataGrid<EventModel>(
                context,
                DbEvents.getAllEventsForDatagrid,
                EventModel.fromPlutoJson,
                DataGridFirstColumn.deleteAndDuplicate,
                Tb.events.id,
                columns: [
                  PlutoColumn(
                    title: "Id".tr(),
                    field: Tb.events.id,
                    type: PlutoColumnType.number(defaultValue: -1),
                    readOnly: true,
                    width: 50,
                    renderer: (rendererContext) => DataGridHelper.idRenderer(rendererContext),
                  ),
                  PlutoColumn(
                    title: "Hide".tr(),
                    field: Tb.events.is_hidden,
                    type: PlutoColumnType.select(places),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.events.is_hidden),
                  ),
                  PlutoColumn(
                    title: "Interest".tr(),
                    field: Tb.event_users.table,
                    readOnly: true,
                    type: PlutoColumnType.number(negative: false, defaultValue: 0),
                    width: 100,
                  ),
                  PlutoColumn(
                      title: "Title".tr(),
                      field: EventModel.titleColumn,
                      type: PlutoColumnType.text(),
                      width: 300
                  ),
                  PlutoColumn(
                    title: "Start date".tr(),
                    field: EventModel.startDateColumn,
                    type: PlutoColumnType.date(defaultValue: occasionModel?.startTime),
                    width: 140,
                  ),
                  PlutoColumn(
                    title: "Start".tr(),
                    field: EventModel.startTimeColumn,
                    type: PlutoColumnType.time(),
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "End date".tr(),
                    field: EventModel.endDateColumn,
                    type: PlutoColumnType.date(defaultValue: occasionModel?.startTime),
                    width: 140,
                  ),
                  PlutoColumn(
                    title: "End".tr(),
                    field: EventModel.endTimeColumn,
                    type: PlutoColumnType.time(),
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "Max".tr(),
                    field: EventModel.maxParticipantsColumn,
                    type: PlutoColumnType.number(negative: false, defaultValue: null),
                    width: 70,
                  ),
                  PlutoColumn(
                    title: "M/F 50/50".tr(),
                    field: EventModel.splitForMenWomenColumn,
                    type: PlutoColumnType.text(),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, EventModel.splitForMenWomenColumn),
                  ),
                  PlutoColumn(
                    title: "Group".tr(),
                    field: EventModel.isGroupEventColumn,
                    type: PlutoColumnType.text(),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, EventModel.isGroupEventColumn),
                  ),
                  PlutoColumn(
                    title: "Place".tr(),
                    field: EventModel.placeColumn,
                    type: PlutoColumnType.select(places),
                    applyFormatterInEditing: true,
                    formatter: DataGridHelper.GetValueFromFormatted,
                  ),
                  PlutoColumn(
                      width: 150,
                      title: "Content".tr(),
                      enableFilterMenuItem: false,
                      enableContextMenu: false,
                      enableSorting: false,
                      field: Tb.events.description,
                      type: PlutoColumnType.text(defaultValue: ""),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: () async {
                              String? textToEdit;
                              String? oldText = rendererContext.row.cells[Tb.events.description]?.value;
                              if(oldText!=null)
                              {
                                textToEdit = oldText;
                              }
                              Future<String?> Function() load = () async {
                                var eventId = rendererContext.row.cells[Tb.events.id]!.value;
                                if(eventId!=null)
                                {
                                  var fullEvent = await DbEvents.getEvent(eventId);
                                  return fullEvent.description;
                                }
                                return null;
                              };
                              Map<String, dynamic> param = {HtmlEditorPage.parContent: textToEdit, HtmlEditorPage.parLoad: load};
                              RouterService.navigatePageInfo(context, HtmlEditorRoute(content: param)).then((value) async {
                                if(value != null)
                                {
                                  var newText = value as String;
                                  if(newText!=textToEdit)
                                  {
                                    rendererContext.row.cells[Tb.events.description]?.value = newText;
                                    var cell = rendererContext.row.cells[Tb.events.description]!;
                                    rendererContext.stateManager.changeCellValue(cell, cell.value, force: true);
                                  }
                                }
                              });},
                            child: Row(children: [const Icon(Icons.edit), Padding(padding: const EdgeInsets.all(6), child: const Text("Edit").tr()) ])
                        );
                      }),
                  PlutoColumn(
                      title: "Show inside event".tr(),
                      field: EventModel.parentEventColumn,
                      type: PlutoColumnType.text(),
                      width: 300
                  ),
                  PlutoColumn(
                      title: "Roles".tr(),
                      field: Tb.event_roles.role,
                      type: PlutoColumnType.text(),
                      width: 100
                  ),
                  PlutoColumn(
                      title: "Type".tr(),
                      field: Tb.events.type,
                      type: PlutoColumnType.text()),
                ]).DataGrid(),
            SingleTableDataGrid<PlaceModel>(
                context,
                DbPlaces.getAllPlaces,
                PlaceModel.fromPlutoJson,
                DataGridFirstColumn.deleteAndDuplicate,
                Tb.places.id,
                actionsExtended: DataGridExtendedActions(saveAction:
                DataGridAction(
                  action: (datagrid, [action]) async {
                    await action!();
                    await loadPlaces();
                  }
                )),
                columns: [
                  PlutoColumn(
                    hide: true,
                    title: "Id".tr(),
                    field: Tb.places.id,
                    type: PlutoColumnType.number(defaultValue: -1),
                    readOnly: true,
                    width: 50,
                    renderer: (rendererContext) => DataGridHelper.idRenderer(rendererContext),
                  ),
                  PlutoColumn(
                    title: "Hide".tr(),
                    field: Tb.places.is_hidden,
                    type: PlutoColumnType.select(places),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.places.is_hidden),
                  ),
                  PlutoColumn(
                      title: "Title".tr(),
                      field: Tb.places.title,
                      type: PlutoColumnType.text(),
                      width: 300
                  ),
                  PlutoColumn(
                      title: "Content".tr(),
                      field: Tb.places.description,
                      type: PlutoColumnType.text(),
                      width: 300
                  ),
                  PlutoColumn(
                    title: "Icon".tr(),
                    field: Tb.places.icon,
                    type: PlutoColumnType.select(mapIcons, builder: (icon) {
                      return DataGridHelper.iconToRow(context, icon, svgIcons);
                    }),
                    renderer: (rendererContext) => DataGridHelper.mapIconRenderer(context, rendererContext, svgIcons),
                  ),
                  PlutoColumn(
                      width: 150,
                      title: "Location on map".tr(),
                      enableFilterMenuItem: false,
                      enableContextMenu: false,
                      enableSorting: false,
                      field: Tb.places.coordinates,
                      type: PlutoColumnType.text(defaultValue: SynchroService.globalSettingsModel!.defaultMapLocation),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: () async {
                              var placeModel = PlaceModel.fromPlutoJson(rendererContext.row.toJson());
                              RouterService.navigatePageInfo(context, MapRoute(place: placeModel)).then((value) async {
                                  if(value != null)
                                  {
                                    var cell = rendererContext.row.cells[Tb.places.coordinates]!;
                                    rendererContext.stateManager.changeCellValue(cell, value, force: true);
                                  }
                                 });
                              },
                            child: Row(children: [const Icon(Icons.edit), Padding(padding: const EdgeInsets.all(6), child: const Text("Edit").tr()) ])
                        );
                      }),
                  PlutoColumn(
                    title: "Order".tr(),
                    field: Tb.places.order,
                    type: PlutoColumnType.number(defaultValue: null),
                    applyFormatterInEditing: true,
                    width: 100,
                  ),
                ]).DataGrid(),
            SingleTableDataGrid<ExclusiveGroupModel>(
                context,
                DbEvents.getAllExclusiveGroups,
                ExclusiveGroupModel.fromPlutoJson,
                DataGridFirstColumn.delete,
                Tb.exclusive_groups.id,
                columns: [
                  PlutoColumn(
                    hide: true,
                    title: "Id".tr(),
                    field: Tb.exclusive_groups.id,
                    type: PlutoColumnType.number(defaultValue: -1),
                    readOnly: true,
                    enableEditingMode: false,
                    width: 50,
                    renderer: (rendererContext) => DataGridHelper.idRenderer(rendererContext),
                  ),
                  PlutoColumn(
                      title: "Name".tr(),
                      field: Tb.exclusive_groups.title,
                      type: PlutoColumnType.text(),
                      width: 300
                  ),
                  PlutoColumn(
                      title: "Events".tr(),
                      field: ExclusiveGroupModel.eventsColumn,
                      type: PlutoColumnType.text(),
                      width: 500
                  ),
                ]).DataGrid(),
            SingleTableDataGrid<UserGroupInfoModel>(
                context,
                DbGroups.getAllUserGroupInfo,
                UserGroupInfoModel.fromPlutoJson,
                DataGridFirstColumn.delete,
                Tb.user_group_info.id,
                columns: [
                  PlutoColumn(
                    hide: true,
                    title: "Id".tr(),
                    field: Tb.user_group_info.id,
                    type: PlutoColumnType.number(defaultValue: -1),
                    readOnly: true,
                    enableEditingMode: false,
                    width: 50,
                    renderer: (rendererContext) => DataGridHelper.idRenderer(rendererContext),
                  ),
                  PlutoColumn(
                      title: "Name".tr(),
                      field: Tb.user_group_info.title,
                      type: PlutoColumnType.text(),
                      width: 200
                  ),
                  PlutoColumn(
                      title: "Moderator".tr(),
                      field: UserGroupInfoModel.leaderUserColumn,
                      type: PlutoColumnType.text(),
                      enableEditingMode: false,
                      width: 200,
                      renderer: (rendererContext) {
                        String? userName;
                        var currentValue = rendererContext.row.cells[UserGroupInfoModel.leaderUserColumn]?.value;
                        if(currentValue!=null && currentValue.toString().isNotEmpty)
                        {
                          var user = (rendererContext.row.cells[UserGroupInfoModel.leaderUserColumn]?.value as UserInfoModel);
                          userName = user.toString();
                        }
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    if(_allUsers.isEmpty)
                                    {
                                      _allUsers = await DbUsers.getAllUsersBasics();
                                    }
                                    DialogHelper.chooseUser(context, (person) =>
                                    setState(() {
                                      rendererContext.row.cells[UserGroupInfoModel.leaderUserColumn]?.value = person;
                                      var cell = rendererContext.row.cells[UserGroupInfoModel.leaderUserColumn]!;
                                      rendererContext.stateManager.changeCellValue(cell, cell.value, force: true);
                                      RouterService.goBack(context);
                                    }), _allUsers, "Set".tr());
                                  },
                                  icon: const Icon(Icons.add_circle_rounded)),
                              Text(userName??""),]
                        );
                      }
                  ),
                  PlutoColumn(
                      title: "Participants".tr(),
                      field: UserGroupInfoModel.participantsColumn,
                      type: PlutoColumnType.text(defaultValue: <UserInfoModel>{}),
                      enableEditingMode: false,
                      width: 600,
                      renderer: (rendererContext) {
                        String? userNames;
                        Set<UserInfoModel> participants = {};
                        var currentValue = rendererContext.row.cells[UserGroupInfoModel.participantsColumn]?.value;
                        if(currentValue!=null && currentValue.toString().isNotEmpty)
                        {
                          participants = (rendererContext.row.cells[UserGroupInfoModel.participantsColumn]?.value as Set<UserInfoModel>);
                          userNames = participants.join(", ");
                        }
                        return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              IconButton(
                                  onPressed: () async{
                                    if(_allUsers.isEmpty)
                                    {
                                      _allUsers = await DbUsers.getAllUsersBasics();
                                    }
                                    DialogHelper.chooseUser(context, (person) =>
                                        setState(() {
                                          rendererContext.row.cells[UserGroupInfoModel.participantsColumn]?.value.add(person);
                                          var cell = rendererContext.row.cells[UserGroupInfoModel.participantsColumn]!;
                                          rendererContext.stateManager.changeCellValue(cell, cell.value, force: true);
                                        }), _allUsers, "Add".tr());
                                  },
                                  icon: const Icon(Icons.add_circle_rounded)),
                              IconButton(
                                  onPressed: () async{
                                    var cell = rendererContext.row.cells[UserGroupInfoModel.participantsColumn]!;
                                    rendererContext.stateManager.changeCellValue(cell, <UserInfoModel>{}, force: true);
                                  },
                                  icon: const Icon(Icons.remove_circle)),
                              Text("(${participants.length}) $userNames"),]
                        );
                      }
                  ),
                  PlutoColumn(
                      width: 150,
                      title: "Content".tr(),
                      enableFilterMenuItem: false,
                      enableContextMenu: false,
                      enableSorting: false,
                      field: Tb.user_group_info.description,
                      type: PlutoColumnType.text(defaultValue: null),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: () async{
                              var oldText = rendererContext.row.cells[Tb.user_group_info.description]!.value as String?;
                              RouterService.navigatePageInfo(context, HtmlEditorRoute(content: {HtmlEditorPage.parContent: oldText})).then((value) async {
                                if(value != null)
                                {
                                  var newText = value as String;
                                  if(newText!=oldText)
                                  {
                                    var cell = rendererContext.row.cells[Tb.user_group_info.description]!;
                                    rendererContext.stateManager.changeCellValue(cell, newText, force: true);
                                  }
                                }
                              });},
                            child: Row(children: [Icon(Icons.edit), Padding(padding: EdgeInsets.all(6), child: Text("Edit".tr())) ])
                        );
                      }),
                  PlutoColumn(
                      width: 150,
                      title: "Place".tr(),
                      enableFilterMenuItem: false,
                      enableContextMenu: false,
                      enableSorting: false,
                      field: Tb.user_group_info.place,
                      type: PlutoColumnType.text(defaultValue: null),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: () async {
                              var title = rendererContext.row.cells[Tb.user_group_info.title]?.value;
                              var placeModel = rendererContext.row.cells[Tb.user_group_info.place]?.value as PlaceModel?;
                              placeModel ??= PlaceModel(id: null, title: title, description: "", type: "group", isHidden: true, latLng: SynchroService.globalSettingsModel!.defaultMapLocation);

                              RouterService.navigatePageInfo(context, MapRoute(place: placeModel)).then((value) async {
                                if(value != null)
                                {
                                  placeModel!.latLng = value;
                                  var cell = rendererContext.row.cells[Tb.user_group_info.place]!;
                                  rendererContext.stateManager.changeCellValue(cell, placeModel, force: true);
                                }
                              });
                            },
                            child: Row(children: [const Icon(Icons.location_pin), Padding(padding: const EdgeInsets.all(6), child: const Text("Location").tr()) ])
                        );
                      }),
                ]).DataGrid(),
            SingleTableDataGrid<OccasionUserModel>(
                context,
                DbUsers.getOccasionUsers,
                OccasionUserModel.fromPlutoJson,
                DataGridFirstColumn.deleteAndCheck,
                Tb.occasion_users.user,
                actionsExtended: DataGridExtendedActions(
                  saveAction: DataGridAction(
                      action: (datagrid, [action]) async {
                        await action!();
                        _allUsers = [];
                      }
                  ), areAllActionsEnabled: RightsService.canUpdateUsers),
                headerChildren: [
                  DataGridAction(name: "Import".tr(), action: (SingleTableDataGrid p0, [_]) { _import(p0); }, isEnabled: () => (AppConfig.isUsersImportSupported && RightsService.canUpdateUsers())),
                  DataGridAction(name: "Add existing".tr(), action: (SingleTableDataGrid p0, [_]) { _addExisting(p0); }),
                  DataGridAction(name: "Invite".tr(), action:  (SingleTableDataGrid p0, [_]) { _invite(p0); }, isEnabled: RightsService.canUpdateUsers),
                  DataGridAction(name: "Change password".tr(), action: (SingleTableDataGrid p0, [_]) { _setPassword(p0); }, isEnabled: RightsService.canUpdateUsers),
                  DataGridAction(name: "Add to group".tr(), action: (SingleTableDataGrid p0, [_]) { _addToGroup(p0); }),
                ],
                columns: [
                  PlutoColumn(
                      hide: true,
                      title: "Id".tr(),
                      field: Tb.occasion_users.user,
                      type: PlutoColumnType.text(),
                      readOnly: true,
                      width: 50),
                  PlutoColumn(
                      title: "E-mail".tr(),
                      field: Tb.occasion_users.data_email,
                      type: PlutoColumnType.text(),
                      checkReadOnly: (row, cell) {
                        final id = row.cells[Tb.occasion_users.user]?.value as String?;
                        return id != null && id.isNotEmpty;
                      },
                      width: 200
                  ),
                  PlutoColumn(
                    title: "Name".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.user_info_public.name,
                    type: PlutoColumnType.text(),
                    width: 200,
                  ),
                  PlutoColumn(
                    title: "Surname".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.user_info_public.surname,
                    type: PlutoColumnType.text(),
                    width: 200,
                  ),
                  PlutoColumn(
                    title: "Sex".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.user_info_public.sex,
                    type: PlutoColumnType.select(UserInfoModel.sexes, defaultValue: UserInfoModel.sexes.first),
                    formatter: (value) => DataGridHelper.textTransform(value, UserInfoModel.sexes, UserInfoModel.sexToLocale),
                    applyFormatterInEditing: true,
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "Accommodation".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.occasion_users.data_accommodation,
                    type: PlutoColumnType.text(),
                    readOnly: false,
                    width: 150,
                  ),
                  PlutoColumn(
                    title: "Phone".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.occasion_users.data_phone,
                    type: PlutoColumnType.text(),
                    width: 200,
                  ),
                  PlutoColumn(
                    title: "Birthday".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.occasion_users.data_birthDate,
                    type: PlutoColumnType.date(defaultValue: DateTime.now()),
                    width: 140,
                  ),
                  PlutoColumn(
                    title: "Role".tr(),
                    enableEditingMode: RightsService.canUpdateUsers(),
                    field: Tb.user_info.role,
                    type: PlutoColumnType.text(),
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "Manager".tr(),
                    field: Tb.occasion_users.is_manager,
                    type: PlutoColumnType.select([]),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.occasion_users.is_manager, RightsService.canUpdateUsers),
                  ),
                  PlutoColumn(
                    title: "Editor".tr(),
                    field: Tb.occasion_users.is_editor,
                    type: PlutoColumnType.select([]),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.occasion_users.is_editor, RightsService.canUpdateUsers),
                  ),
                  PlutoColumn(
                    title: "Approver".tr(),
                    field: Tb.occasion_users.is_approver,
                    type: PlutoColumnType.select([]),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.occasion_users.is_approver, RightsService.canUpdateUsers),
                  ),
                  PlutoColumn(
                    title: "Approved".tr(),
                    field: Tb.occasion_users.is_approved,
                    type: PlutoColumnType.select([]),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.occasion_users.is_approved, RightsService.canUpdateUsers),
                  ),
                  PlutoColumn(
                    title: "Invited".tr(),
                    field: Tb.occasion_users.data_isInvited,
                    type: PlutoColumnType.select([]),
                    applyFormatterInEditing: true,
                    enableEditingMode: false,
                    width: 100,
                    renderer: (rendererContext) => DataGridHelper.checkBoxRenderer(rendererContext, Tb.occasion_users.data_isInvited, ()=>false),
                  )
                ]).DataGrid(),
          ]
        ),
      ),
    );
  }

  List<UserInfoModel> _allUsers = [];
  Future<void> _import(SingleTableDataGrid dataGrid) async {
    await UserManagementHelper.import(context);
    await dataGrid.reloadData();
  }

  Future<void> _invite(SingleTableDataGrid dataGrid) async {
    var users = List<OccasionUserModel>.from(dataGrid.stateManager.refRows.originalList.where((element) => element.checked == true).map((x) => OccasionUserModel.fromPlutoJson(x.toJson())));
    users = users.where((element) => element.user != null).toList();
    var really = await DialogHelper.showConfirmationDialogAsync(context, "Invite".tr(), "${"Users will get invitation via e-mail.".tr()} (${users.length}):\n${users.map((value) => value.toBasicString()).toList().join(",\n")}", confirmButtonMessage: "Proceed".tr());
    if(!really) {
      return;
    }

    if(users.any((u) => u.data![Tb.occasion_users.data_isInvited]==true))
    {
      var reallyAll = await DialogHelper.showConfirmationDialogAsync(context, "Invite".tr(), "Invite users who have already been invited?".tr(), confirmButtonMessage: "Proceed".tr());
      if(!reallyAll) {
        users = users.where((element) => !element.data![Tb.occasion_users.data_isInvited]).toList();
      }
    }


    for(OccasionUserModel u in users) {
      await AuthService.resetPasswordForEmail(u.data![Tb.occasion_users.data_email]);
      u.data![Tb.occasion_users.data_isInvited] = true;
      await DbUsers.updateOccasionUser(u);
      ToastHelper.Show(context, "Invited: {user}.".tr(namedArgs: {"user":u.data![Tb.occasion_users.data_email]}));
    }
    await dataGrid.reloadData();
  }

  Future<void> _setPassword(SingleTableDataGrid dataGrid) async {
    var users = List<OccasionUserModel>.from(dataGrid.stateManager.refRows.originalList.where((element) => element.checked == true).map((x) => OccasionUserModel.fromPlutoJson(x.toJson())));
    users = users.where((element) => element.user != null).toList();
    var really = await DialogHelper.showConfirmationDialogAsync(context, "Change password".tr(), "${"Change password to users".tr()} (${users.length}):\n${users.map((value) => value.toBasicString()).toList().join(",\n")}", confirmButtonMessage: "Proceed".tr());
    if(!really) {
      return;
    }

    try {
      for(var u in users) {
          await UserManagementHelper.unsafeChangeUserPassword(context, u);
          ToastHelper.Show(context, "Password has been changed.".tr());
      }
    } on Exception catch (e) {
      ToastHelper.Show(context, e.toString(), severity: ToastSeverity.NotOk);
      return;
    }
  }

  Future<void> _addToGroup(SingleTableDataGrid dataGrid) async {
    var users = List<OccasionUserModel>.from(dataGrid.stateManager.refRows.originalList.where((element) => element.checked == true).map((x) => OccasionUserModel.fromPlutoJson(x.toJson())));
    users = users.where((element) => element.user != null).toList();
    var allGroups = await DbGroups.getAllUserGroupInfo();
    var chosenGroup = await DialogHelper.showAddToGroupDialogAsync(context, allGroups);
    if(chosenGroup == null)
    {
      return;
    }
    chosenGroup.participants!.addAll(users.map((e) => UserInfoModel(id: e.user)));
    await DbGroups.updateUserGroupParticipants(chosenGroup, chosenGroup.participants!);

    for (var value in dataGrid.stateManager.refRows.originalList) {
      value.setChecked(false);
    }

    ToastHelper.Show(context, "Updated {item}.".tr(namedArgs: {"item":chosenGroup.title}));
  }

  Future<void> _addExisting(SingleTableDataGrid dataGrid) async {
    var users = List<OccasionUserModel>.from(dataGrid.stateManager.refRows.originalList.map((x) => OccasionUserModel.fromPlutoJson(x.toJson())));
    users = users.where((element) => element.user != null).toList();

    if(_allUsers.isEmpty)
    {
      _allUsers = await DbUsers.getAllUsersBasics();
    }
    var nonAdded = _allUsers.where((a)=>!users.any((u)=>(u.user==a.id))).toList();
    DialogHelper.chooseUser(context, (person) async
    {
      await DbUsers.addUserToOccasion(person.id, RightsService.currentOccasion!);
      ToastHelper.Show(context, "Updated {item}.".tr(namedArgs: {"item":person.toString()}));
    }, nonAdded, "Add".tr());

    await dataGrid.reloadData();

  }

}