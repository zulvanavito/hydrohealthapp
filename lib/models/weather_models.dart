class Weather {
  final String cityName;
  final double temperature;
  final String mainCondition;
  final int humidity;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.mainCondition,
    required this.humidity,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      mainCondition: (json['weather'] != null && json['weather'].isNotEmpty)
          ? json['weather'][0]['main'] ?? 'Unknown'
          : 'Unknown',
      humidity: json['main']['humidity'] ?? 0,
    );
  }
}
