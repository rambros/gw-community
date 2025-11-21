import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/schema/structs/index.dart';
import 'backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _onboardingDone = prefs.getBool('ff_onboardingDone') ?? _onboardingDone;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _typeSelectedEvent = 'upcomming';
  String get typeSelectedEvent => _typeSelectedEvent;
  set typeSelectedEvent(String value) {
    _typeSelectedEvent = value;
  }

  List<int> _listStartedJourneys = [];
  List<int> get listStartedJourneys => _listStartedJourneys;
  set listStartedJourneys(List<int> value) {
    _listStartedJourneys = value;
  }

  void addToListStartedJourneys(int value) {
    listStartedJourneys.add(value);
  }

  void removeFromListStartedJourneys(int value) {
    listStartedJourneys.remove(value);
  }

  void removeAtIndexFromListStartedJourneys(int index) {
    listStartedJourneys.removeAt(index);
  }

  void updateListStartedJourneysAtIndex(
    int index,
    int Function(int) updateFn,
  ) {
    listStartedJourneys[index] = updateFn(_listStartedJourneys[index]);
  }

  void insertAtIndexInListStartedJourneys(int index, int value) {
    listStartedJourneys.insert(index, value);
  }

  bool _hasStartedJourney = false;
  bool get hasStartedJourney => _hasStartedJourney;
  set hasStartedJourney(bool value) {
    _hasStartedJourney = value;
  }

  bool _filterOn = false;
  bool get filterOn => _filterOn;
  set filterOn(bool value) {
    _filterOn = value;
  }

  int _filterByAuthorId = 0;
  int get filterByAuthorId => _filterByAuthorId;
  set filterByAuthorId(int value) {
    _filterByAuthorId = value;
  }

  String _filterByYear = '';
  String get filterByYear => _filterByYear;
  set filterByYear(String value) {
    _filterByYear = value;
  }

  int _filterByLocalID = 0;
  int get filterByLocalID => _filterByLocalID;
  set filterByLocalID(int value) {
    _filterByLocalID = value;
  }

  String _filterLine = '';
  String get filterLine => _filterLine;
  set filterLine(String value) {
    _filterLine = value;
  }

  List<String> _filterByTopics = [];
  List<String> get filterByTopics => _filterByTopics;
  set filterByTopics(List<String> value) {
    _filterByTopics = value;
  }

  void addToFilterByTopics(String value) {
    filterByTopics.add(value);
  }

  void removeFromFilterByTopics(String value) {
    filterByTopics.remove(value);
  }

  void removeAtIndexFromFilterByTopics(int index) {
    filterByTopics.removeAt(index);
  }

  void updateFilterByTopicsAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    filterByTopics[index] = updateFn(_filterByTopics[index]);
  }

  void insertAtIndexInFilterByTopics(int index, String value) {
    filterByTopics.insert(index, value);
  }

  int _filterByEventId = 0;
  int get filterByEventId => _filterByEventId;
  set filterByEventId(int value) {
    _filterByEventId = value;
  }

  LoginUserStruct _loginUser =
      LoginUserStruct.fromSerializableMap(jsonDecode('{\"roles\":\"[]\"}'));
  LoginUserStruct get loginUser => _loginUser;
  set loginUser(LoginUserStruct value) {
    _loginUser = value;
  }

  void updateLoginUserStruct(Function(LoginUserStruct) updateFn) {
    updateFn(_loginUser);
  }

  int _filterByJourneyId = 0;
  int get filterByJourneyId => _filterByJourneyId;
  set filterByJourneyId(int value) {
    _filterByJourneyId = value;
  }

  int _filterByGroupId = 0;
  int get filterByGroupId => _filterByGroupId;
  set filterByGroupId(int value) {
    _filterByGroupId = value;
  }

  /// if true the user pass through onbording process
  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;
  set onboardingDone(bool value) {
    _onboardingDone = value;
    prefs.setBool('ff_onboardingDone', value);
  }

  final _listEventsUserManager = FutureRequestManager<List<CcEventsRow>>();
  Future<List<CcEventsRow>> listEventsUser({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<CcEventsRow>> Function() requestFn,
  }) =>
      _listEventsUserManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearListEventsUserCache() => _listEventsUserManager.clear();
  void clearListEventsUserCacheKey(String? uniqueKey) =>
      _listEventsUserManager.clearRequest(uniqueKey);

  final _listJourneyStepsManager =
      FutureRequestManager<List<CcJourneyStepsRow>>();
  Future<List<CcJourneyStepsRow>> listJourneySteps({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<CcJourneyStepsRow>> Function() requestFn,
  }) =>
      _listJourneyStepsManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearListJourneyStepsCache() => _listJourneyStepsManager.clear();
  void clearListJourneyStepsCacheKey(String? uniqueKey) =>
      _listJourneyStepsManager.clearRequest(uniqueKey);

  final _journeyManager = FutureRequestManager<List<CcJourneysRow>>();
  Future<List<CcJourneysRow>> journey({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<CcJourneysRow>> Function() requestFn,
  }) =>
      _journeyManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearJourneyCache() => _journeyManager.clear();
  void clearJourneyCacheKey(String? uniqueKey) =>
      _journeyManager.clearRequest(uniqueKey);

  final _userRowManager = FutureRequestManager<List<CcUsersRow>>();
  Future<List<CcUsersRow>> userRow({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<CcUsersRow>> Function() requestFn,
  }) =>
      _userRowManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserRowCache() => _userRowManager.clear();
  void clearUserRowCacheKey(String? uniqueKey) =>
      _userRowManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
