import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({Key? key}) : super(key: key);

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastList;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          error = 'Location services are disabled.';
          loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            error = 'Location permissions are denied.';
            loading = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          error = 'Location permissions are permanently denied.';
          loading = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final weatherService = WeatherService();
      final weather = await weatherService.fetchWeather(
        position.latitude,
        position.longitude,
      );
      final forecast = await weatherService.fetchForecast(
        position.latitude,
        position.longitude,
      );
      setState(() {
        weatherData = weather;
        forecastList = forecast != null ? forecast['list'] : null;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to get weather: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (weatherData == null) {
      return const Center(child: Text('No weather data.'));
    }
    final main = weatherData!['weather']?[0]?['main'] ?? '';
    final desc = weatherData!['weather']?[0]?['description'] ?? '';
    final temp = weatherData!['main']?['temp']?.toStringAsFixed(1) ?? '';
    final city = weatherData!['name'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.orange, size: 36),
            title: Text('$city: $main'),
            subtitle: Text('Temp: $temp°C\n$desc'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchWeather,
            ),
          ),
        ),
        if (forecastList != null && forecastList!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Today's Forecast:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        if (forecastList != null && forecastList!.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecastList!.length > 8
                  ? 8
                  : forecastList!.length, // Show up to 8 (24h)
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = forecastList![i];
                final dtTxt = item['dt_txt'] ?? '';
                final time = dtTxt.length >= 16
                    ? dtTxt.substring(11, 16)
                    : dtTxt;
                final temp = item['main']?['temp']?.toStringAsFixed(1) ?? '';
                final icon = item['weather']?[0]?['icon'] ?? '01d';
                final desc = item['weather']?[0]?['description'] ?? '';
                return Container(
                  width: 90,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.network(
                        'https://openweathermap.org/img/wn/$icon@2x.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.cloud, size: 40),
                      ),
                      Text('$temp°C', style: const TextStyle(fontSize: 16)),
                      Text(desc, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
