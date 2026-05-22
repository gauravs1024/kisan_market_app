class StateModel {
  final int id;
  final String stateName;
  final String countryName;

  StateModel({
    required this.id,
    required this.stateName,
    required this.countryName,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      stateName: json['stateName'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
    );
  }
}
