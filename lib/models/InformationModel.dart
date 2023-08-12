import 'package:av_app/services/DataService.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'PlutoAbstract.dart';


class InformationModel extends IPlutoRowModel {
  int? id;
  String title;
  String? description;
  bool isExpanded = false;

  static const String idColumn = "id";
  static const String titleColumn = "title";
  static const String descriptionColumn = "description";
  static const String informationTable = "information";

  factory InformationModel.fromJson(Map<String, dynamic> json) {
    return InformationModel(
      id: json["id"],
      title: json["title"],
      description: json.containsKey("description") ? json["description"] : null,
    );
  }

  static InformationModel fromPlutoJson(Map<String, dynamic> json) {
    return InformationModel(
      id: json[idColumn] == -1 ? null : json[idColumn],
      title: json[titleColumn],
      description: json[descriptionColumn],
    );
  }


  @override
  PlutoRow toPlutoRow() {
    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      titleColumn: PlutoCell(value: title),
      descriptionColumn: PlutoCell(value: description)
    });
  }

  @override
  Future<void> deleteMethod() async {
    await DataService.deleteInformation(this);
  }

  @override
  Future<void> updateMethod() async {
    await DataService.updateInformation(this);
  }

  @override
  String toBasicString() => title;

  InformationModel({
    required this.id,
    required this.title,
    required this.description});
}