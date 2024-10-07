import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import './model/CurrentCityDataModel.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  // dio - initState
  @override
  void initState() {
    super.initState();
    currentWeatherFuture = sendRequestCurrentWeather(
        cityName); // set value for our future of our future class model.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // it is basic structure/ layout of an app.
      backgroundColor: Colors.blue[900],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      primary: true,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        shadowColor: Colors.black,
        elevation: 15,
        primary: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 65.5,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 5.5,
          ),
          child: BackButton(
            color: Colors.white,
            onPressed: () => exit(0),
          ),
        ),
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
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
              color: Colors.blue[900],
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
              itemBuilder: (BuildContext context) => myPopUpMenuItems(),
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
                    'images/nightSkyBackground.jpg',
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
                                  label: const Text(
                                    'Find',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: const InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    hintText: 'Enter A City name',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                      ),
                                    ),
                                    helper: Text(
                                      'Locations',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 14,
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
                          cityDataModel.cityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.5,
                        ),
                        child: Text(
                          cityDataModel.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(
                              .8,
                            ),
                            fontSize: 18,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 60,
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
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      .6,
                                    ),
                                    fontSize: 17,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 5.5,
                                  ),
                                  child: Text(
                                    '${cityDataModel.temp_max}\u00b0',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
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
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .6,
                                      ),
                                      fontSize: 17,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5.5,
                                    ),
                                    child: Text(
                                      '${cityDataModel.temp_min}\u00b0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
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
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                      .7,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 9.9,
                                  ),
                                  child: Text(
                                    '${cityDataModel.windSpeed}m/s',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
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
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      sunrise,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      sunset,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(
                                        .7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 9.9,
                                    ),
                                    child: Text(
                                      '${cityDataModel.humidity}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
    var apiKey = '7d1052bc34ba250a23eadd88724a76ea';
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

    return dataModel;
  } // End Of SendRequestCurrentWeather()

  List<PopupMenuItem<String>> myPopUpMenuItems() {
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
              style: const TextStyle(
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
} // End Of State<>
