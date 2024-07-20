import 'package:fstapp/appConfig.dart';
import 'package:fstapp/dataServices/DataExtensions.dart';
import 'package:fstapp/dataServices/OfflineDataHelper.dart';
import 'package:fstapp/dataServices/RightsHelper.dart';
import 'package:fstapp/dataModels/InformationModel.dart';
import 'package:fstapp/dataServices/DataService.dart';
import 'package:fstapp/RouterService.dart';
import 'package:fstapp/styles/Styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../services/ToastHelper.dart';
import '../widgets/HtmlView.dart';
import 'HtmlEditorPage.dart';

class InfoPage extends StatefulWidget {
  final String? type;
  static const ROUTE = "info";
  const InfoPage({this.type, super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<InformationModel>? _informationList;
  Map<int, bool> _isItemLoading = {};

  String title = "Information".tr();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.infoPageColor,
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(
          onPressed: () => RouterService.goBackOrHome(context),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: appMaxWidth),
          child: SingleChildScrollView(
            child: ExpansionPanelList(
              expansionCallback: (panelIndex, isExpanded) async {
                setState(() {
                  for (var element in _informationList!) {
                    element.isExpanded = false;
                  }
                  _informationList![panelIndex].isExpanded = isExpanded;
                });

                if (_informationList![panelIndex].description == null &&
                    !_isItemLoading[panelIndex]!) {
                  await loadItemDescription(panelIndex);
                }
              },
              children: _informationList == null
                  ? []
                  : _informationList!.map<ExpansionPanel>((InformationModel item) {
                int index = _informationList!.indexOf(item);
                return ExpansionPanel(
                  backgroundColor: AppConfig.backgroundColor,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(
                      title: Text(item.title ?? ""),
                    );
                  },
                  body: _isItemLoading[index] ?? false
                      ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : Column(
                    children: [
                      if (RightsHelper.isEditor())
                        ElevatedButton(
                          onPressed: () async {
                            var result = await RouterService.navigateOccasion(
                                context, HtmlEditorPage.ROUTE,
                                extra: item.description);
                            if (result != null) {
                              setState(() {
                                item.description = result as String;
                              });
                              await DataService.updateInformation(item);
                              ToastHelper.Show("Content has been changed.".tr());
                            }
                          },
                          child: const Text("Edit content").tr(),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.all(12),
                        child: HtmlView(html: item.description ?? "", isSelectable: true),
                      )
                    ],
                  ),
                  isExpanded: item.isExpanded,
                  canTapOnHeader: true,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    await loadDataOffline();
    setState(() {});
    var allInfo = await DataService.getAllActiveInformation();
    await OfflineDataHelper.saveAllInfo(allInfo);
    await loadDataOffline();
    setState(() {});
  }

  Future<void> loadItemDescription(int index) async {
    setState(() {
      _isItemLoading[index] = true;
    });

    var info = _informationList![index];
    await fillDescriptionFromOffline(info);
    setState(() {
      if(info.description != null){
        _isItemLoading[index] = false;
      }
    });
    await DataService.updateInfoDescription([info.id!]);
    await fillDescriptionFromOffline(info);
    setState(() {
        _isItemLoading[index] = false;
    });
  }

  Future<void> fillDescriptionFromOffline(InformationModel info) async {
    var infoDesc = await OfflineDataHelper.getInfoDescription(info.id!.toString());
    if (infoDesc != null) {
      setState(() {
        info.description = infoDesc.description!;
      });
    }
  }

  Future<void> loadDataOffline() async {
    _informationList = (await OfflineDataHelper.getAllInfo()).filterByType(widget.type);
    _isItemLoading = {for (int i = 0; i < _informationList!.length; i++) i: false};
  }
}
