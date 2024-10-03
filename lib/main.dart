import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/CurrentCityDataModel.dart';
import 'package:flutter_application_1/model/ForecastDaysModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'dart:ui';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyWidgetOne(),
  ));
}

class MyWidgetOne extends StatefulWidget {
  const MyWidgetOne({super.key});

  @override
  State<MyWidgetOne> createState() => _MyWidgetOneState();
}

class _MyWidgetOneState extends State<MyWidgetOne> {
  // An Object for Controlling TextField from TextEditingController()
  TextEditingController textEditingController = TextEditingController();

  // an future-object of our future CurrentCityDataModel. Json Data to ClassData. it is a Future builder.
  late Future<CurrentCityDataModel> currentWeatherFuture;

  var cityName = 'Tehran'; // for openWeatherAPI - Current API
  var lat; // for Second OpenWeatherAPI - 8 days forecast
  var lon; // for Second OpenWeatherAPI - 8 days forecast

  // StreamBuilder - for listening continuously and then re-built and new respond again.
  late StreamController<List<ForecastDaysModel>>
      streamForecastDaysController; // we used list, because we want get 6 days data nor just one and as a result of that we need list to save those data in it. we get these data by a class.

  // dio - initState
  @override
  void initState() {
    super.initState();
    currentWeatherFuture = sendRequestCurrentWeather(
        cityName); // set value for our future of our future class model.
    streamForecastDaysController = StreamController<
        List<
            ForecastDaysModel>>(); // set value for our object of our Stream COntroller.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // it is basic structure/ layout of an app.
      backgroundColor: Colors.blue[300],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        shadowColor: Colors.black,
        elevation: 15,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 55.5,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 5.5,
          ),
          child: IconButton(
            onPressed: () {
              exit(0);
            },
            highlightColor: Colors.transparent,
            icon: const Icon(
              Icons.exit_to_app_outlined,
              size: 25,
              color: Colors.white,
              semanticLabel:
                  'Arrow and Box that indicate exiting or going back of application',
            ),
            enableFeedback: true,
            tooltip: 'Completely Exit From App',
          ),
        ),
        title: Text(
          'Weather App',
          style: GoogleFonts.gabarito(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 9.5,
            ),
            child: PopupMenuButton<String>(
              iconColor: Colors.white,
              elevation: 15,
              tooltip: 'Accessing to App Menu',
              color: Colors.blue[300],
              menuPadding: const EdgeInsets.all(
                10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              popUpAnimationStyle: AnimationStyle(
                curve: Curves.easeInCirc,
              ),
              enableFeedback: true,
              onSelected: (message) =>
                  ShowToastMessage('Coming Soon, Not Available Right Now!'),
              // ignore: avoid_print
              itemBuilder: (BuildContext context) {
                return {
                  'Locations',
                  'Account',
                  'Setting',
                  'Support',
                }.map(
                  (String menuChoice) {
                    return PopupMenuItem(
                      value: menuChoice,
                      child: Center(
                        child: Text(
                          menuChoice,
                          style: GoogleFonts.gabarito(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList();
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<CurrentCityDataModel>(
        future: currentWeatherFuture,
        builder: (context, snapshot) {
          // snapshot: is data that we get from our future that are used.(currentWeatherFuture)
          if (snapshot.hasData) {
            CurrentCityDataModel? cityDataModel = snapshot.data;
            sendRequestSevenDaysForecast(lat, lon);

            final formatter = DateFormat.jm();
            var sunrise = formatter.format(
              DateTime.fromMillisecondsSinceEpoch(
                cityDataModel!.sunrise * 1000,
                isUtc: true,
              ),
            );
            var sunset = formatter.format(
              DateTime.fromMillisecondsSinceEpoch(
                cityDataModel.sunset * 1000,
                isUtc: true,
              ),
            );

            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                image: const DecorationImage(
                  image: AssetImage(
                    'images/nightskybackground.jpg',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Colors.black38,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6,
                  sigmaY: 6,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: SizedBox(
                          width: 350,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 9.5,
                                ),
                                child: ElevatedButton.icon(
                                  iconAlignment: IconAlignment.end,
                                  label: Text(
                                    'Find',
                                    style: GoogleFonts.gabarito(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[300],
                                    padding: const EdgeInsets.only(
                                      right: 15.5,
                                      left: 19.5,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        currentWeatherFuture =
                                            sendRequestCurrentWeather(
                                          textEditingController.text,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: textEditingController,
                                  cursorColor: Colors.white,
                                  enableSuggestions: true,
                                  style: GoogleFonts.gabarito(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    hintText: 'Enter A City name',
                                    hintStyle: GoogleFonts.gabarito(
                                      textStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    helper: Text(
                                      'Locations',
                                      style: GoogleFonts.gabarito(
                                        textStyle: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Text(
                          cityDataModel.cityname,
                          style: GoogleFonts.gabarito(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Text(
                          cityDataModel.description,
                          style: GoogleFonts.gabarito(
                            textStyle: TextStyle(
                              color: Colors.white.withOpacity(
                                .8,
                              ),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: setIconForMain(cityDataModel),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Text(
                          '${cityDataModel.temp}\u00b0',
                          style: GoogleFonts.gabarito(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'max',
                                  style: GoogleFonts.gabarito(
                                    textStyle: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .6,
                                      ),
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5.5,
                                  ),
                                  child: Text(
                                    '${cityDataModel.temp_max}\u00b0',
                                    style: GoogleFonts.gabarito(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.5,
                              ),
                              child: Container(
                                width: 1,
                                height: 42,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.5,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'min',
                                    style: GoogleFonts.gabarito(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(
                                          .6,
                                        ),
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5.5,
                                    ),
                                    child: Text(
                                      '${cityDataModel.temp_min}\u00b0',
                                      style: GoogleFonts.gabarito(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Container(
                          color: Colors.white,
                          width: 355,
                          height: 1,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 130,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 15.5,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                5.5,
                              ),
                              child: StreamBuilder<List<ForecastDaysModel>>(
                                stream: streamForecastDaysController.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<ForecastDaysModel>? forecastDays = snapshot
                                        .data; // it gets data from our stream builder.

                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 6,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int ic) {
                                        return listViewItems(
                                            forecastDays![ic + 1]);
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: JumpingDotsProgressIndicator(
                                        color: Colors.white,
                                        fontSize: 75,
                                        dotSpacing: 2,
                                        numberOfDots: 7,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Wind Speed',
                                  style: GoogleFonts.gabarito(
                                    textStyle: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 9.9,
                                  ),
                                  child: Text(
                                    '${cityDataModel.windSpeed}m/s',
                                    style: GoogleFonts.gabarito(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Container(
                                width: 1,
                                height: 42,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'sunrise',
                                    style: GoogleFonts.gabarito(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(
                                          .7,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      sunrise,
                                      style: GoogleFonts.gabarito(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Container(
                                width: 1,
                                height: 42,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'sunset',
                                    style: GoogleFonts.gabarito(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(
                                          .7,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      sunset,
                                      style: GoogleFonts.gabarito(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Container(
                                width: 1,
                                height: 42,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 9.9,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Humidity',
                                    style: GoogleFonts.gabarito(
                                      textStyle: TextStyle(
                                        color: Colors.white.withOpacity(
                                          .7,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      '${cityDataModel.humidity}%',
                                      style: GoogleFonts.gabarito(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: JumpingDotsProgressIndicator(
                color: Colors.white,
                fontSize: 75,
                dotSpacing: 2,
                numberOfDots: 7,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ShowToastMessage('Coming Soon, Not Available Right Now!'),
        backgroundColor: Colors.blue[300],
        focusColor: Colors.grey[350],
        hoverColor: Colors.grey[400],
        splashColor: Colors.white24,
        foregroundColor: Colors.blue[900],
        tooltip: 'Add A Specific Location Or Saved Locations',
        enableFeedback: true,
        mini: false,
        highlightElevation: 15,
        child: const Icon(
          Icons.add_location_alt_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Toast - Message
  // ignore: non_constant_identifier_names
  void ShowToastMessage(String message) => Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.blue[300],
        textColor: Colors.white,
        fontSize: 26,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
      );

  Future<CurrentCityDataModel> sendRequestCurrentWeather(
    String cityName,
  ) async {
    var apiKey = '457ec16fd35a67a666153666a8566be4';
    var responseRequest = await Dio().get(
      //get method ==> gets all data as jsonFile
      'http://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'q': cityName,
        'appid': apiKey,
        'units': 'metric',
      },
    );

    // For Checking On Console InterFace.
    print(responseRequest.data);
    print(responseRequest.statusCode);
    print(responseRequest.statusMessage);
    // End Of Console InterFace

    var dataModel = CurrentCityDataModel(
      responseRequest.data['name'],
      responseRequest.data['weather'][0]['main'],
      responseRequest.data['weather'][0]['description'],
      responseRequest.data['sys']['country'],
      responseRequest.data['coord']['lon'],
      responseRequest.data['coord']['lat'],
      responseRequest.data['main']['temp'],
      responseRequest.data['main']['temp_min'],
      responseRequest.data['main']['temp_max'],
      responseRequest.data['main']['pressure'],
      responseRequest.data['main']['humidity'],
      responseRequest.data['wind']['speed'],
      responseRequest.data['dt'],
      responseRequest.data['sys']['sunrise'],
      responseRequest.data['sys']['sunset'],
    );

    lat = responseRequest.data['coord']['lat'];
    lon = responseRequest.data['coord']['lon'];

    return dataModel;
  } // End Of SendRequestCurrentWeather()

  // create a method to get data from second openWeatherAPI, ForecastAPI
  void sendRequestSevenDaysForecast(lat, lon) async {
    var apiKey = '457ec16fd35a67a666153666a8566be4';

    List<ForecastDaysModel> listOfData = [];

    try {
      var respond = await Dio().get(
          'http://api.openweathermap.org/data/3.0/onecall',
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'exclude': 'minutely, hourly', // don't want these data
            'appid': apiKey,
            'units': 'metric',
          });

      print(respond.data);
      print(respond.statusCode);
      print(respond.statusMessage);

      // change time
      final formatter = DateFormat.MMMd();

      for (int i = 0; i < 7; i++) {
        var model = respond.data['daily'][i];

        var dt = formatter.format(
          DateTime.fromMillisecondsSinceEpoch(
            model['dt'] * 1000,
            isUtc: true,
          ),
        );

        ForecastDaysModel forecastDaysModel = ForecastDaysModel(
          dt,
          model['temp']['day'],
          model['weather'][0]['main'],
          model['weather'][0]['description'],
        );

        listOfData.add(forecastDaysModel);
      }

      streamForecastDaysController.add(listOfData);
    } on DioException catch (e) {
      print(e.response!.statusCode);
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'It Is Not!',
            style: GoogleFonts.gabarito(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 21,
              ),
            ),
          ),
        ),
      );
    }
  }

  // Icon Setter Function/ Method
  Icon setIconForMain(model) {
    String description = model.description;

    if (description == 'clear sky') {
      return Icon(
        Icons.wb_sunny,
        color: Colors.yellow[300],
        size: 90,
        semanticLabel: 'Clear Sky Icon',
      );
    } else if (description.contains('clouds')) {
      return Icon(
        Icons.cloud,
        color: Colors.blue[300],
        size: 90,
        semanticLabel: 'clouds Icon',
      );
    } else if (description.contains('thunderstorm')) {
      return Icon(
        Icons.thunderstorm_rounded,
        color: Colors.blueGrey[50],
        size: 90,
        semanticLabel: 'thunderstorm Icon',
      );
    } else if (description.contains('drizzle')) {
      return Icon(
        Icons.water,
        color: Colors.blue[300],
        size: 90,
        semanticLabel: 'drizzle Icon',
      );
    } else if (description.contains('rain')) {
      return Icon(
        Icons.water_drop_rounded,
        color: Colors.blue[300],
        size: 90,
        semanticLabel: 'rain Icon',
      );
    } else if (description.contains('snow')) {
      return const Icon(
        Icons.snowing,
        color: Colors.white,
        size: 90,
        semanticLabel: 'snow Icon',
      );
    } else {
      return const Icon(
        Icons.invert_colors_rounded,
        color: Colors.white,
        size: 90,
        semanticLabel: 'normal weather',
      );
    }
  }

  // build cards from 6-days data forecast API + it's model and create cards
  SizedBox listViewItems(ForecastDaysModel forecastDays) {
    return SizedBox(
      width: 60,
      height: 70,
      child: Card(
        color: Colors.white,
        elevation: 15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              forecastDays.dataTime.toString(),
              style: GoogleFonts.gabarito(
                textStyle: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: setIconForMain(forecastDays),
            ),
            Text(
              '${forecastDays.temp.round().toString()}\u00b0',
              style: GoogleFonts.gabarito(
                textStyle: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End Of State<>
