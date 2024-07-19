import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hydrohealth/models/weather_models.dart';

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather';
  final String apikey;

  WeatherService(this.apikey);

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apikey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<Weather> getWeatherByCoordinates(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        '$BASE_URL?lat=$latitude&lon=$longitude&appid=$apikey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Convert location from placemark
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // Extract the most relevant city name from placemark
    Placemark placemark = placemarks.firstWhere(
        (place) => place.locality != null && place.locality!.isNotEmpty,
        orElse: () => placemarks[0]);

    String? city = placemark.locality;

    return city ?? "";
  }

  Future<Weather> getWeatherForSpecificLocation(String cityName) async {
    return getWeather(cityName);
  }
}
