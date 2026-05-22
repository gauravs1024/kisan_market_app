class CountryModel {
  final int id;
  final String countryName;

  CountryModel({
    required this.id,
    required this.countryName,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      countryName: json['countryName'] as String? ?? '',
    );
  }
}
