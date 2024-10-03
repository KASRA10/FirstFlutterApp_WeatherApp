class ForecastDaysModel {
  final _dataTime;
  final _temp;
  final String _main;
  final String _description;

  ForecastDaysModel(
    this._dataTime,
    this._temp,
    this._main,
    this._description,
  );

  get dataTime => _dataTime;
  get temp => _temp;
  String get main => _main;
  String get description => _description;
}
