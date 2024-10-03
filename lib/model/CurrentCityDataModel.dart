class CurrentCityDataModel {
  final String _cityname;
  final String _main;
  final String _description;
  final String _country;
  final _lon;
  final _lat;
  final _temp;
  final _temp_min;
  final _temp_max;
  final _pressure;
  final _humidity;
  final _windSpeed;
  final _dataTime;
  final _sunrise;
  final _sunset;

  CurrentCityDataModel(
    this._cityname,
    this._main,
    this._description,
    this._country,
    this._lon,
    this._lat,
    this._temp,
    this._temp_min,
    this._temp_max,
    this._pressure,
    this._humidity,
    this._windSpeed,
    this._dataTime,
    this._sunrise,
    this._sunset,
  );

  String get cityname => _cityname;
  String get main => _main;
  String get description => _description;
  String get country => _country;
  get lon => _lon;
  get lat => _lat;
  get temp => _temp;
  get temp_min => _temp_min;
  get temp_max => _temp_max;
  get pressure => _pressure;
  get humidity => _humidity;
  get windSpeed => _windSpeed;
  get dataTime => _dataTime;
  get sunrise => _sunrise;
  get sunset => _sunset;
}
