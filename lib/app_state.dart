import 'package:flutter/material.dart';
import 'utils/request_manager.dart';
import '/data/models/structs/index.dart';
import 'data/services/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/flutter_flow_util.dart';

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

  String typeSelectedEvent = 'upcomming';

  List<int> listStartedJourneys = [];

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
    listStartedJourneys[index] = updateFn(listStartedJourneys[index]);
  }

  void insertAtIndexInListStartedJourneys(int index, int value) {
    listStartedJourneys.insert(index, value);
  }

  bool hasStartedJourney = false;

  bool filterOn = false;

  int filterByAuthorId = 0;

  String filterByYear = '';

  int filterByLocalID = 0;

  String filterLine = '';

  List<String> filterByTopics = [];

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
    filterByTopics[index] = updateFn(filterByTopics[index]);
  }

  void insertAtIndexInFilterByTopics(int index, String value) {
    filterByTopics.insert(index, value);
  }

  int filterByEventId = 0;

  LoginUserStruct loginUser = LoginUserStruct.fromSerializableMap(jsonDecode('{\"roles\":\"[]\"}'));

  void updateLoginUserStruct(Function(LoginUserStruct) updateFn) {
    updateFn(loginUser);
  }

  int filterByJourneyId = 0;

  int filterByGroupId = 0;

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
  void clearListEventsUserCacheKey(String? uniqueKey) => _listEventsUserManager.clearRequest(uniqueKey);

  final _listJourneyStepsManager = FutureRequestManager<List<CcJourneyStepsRow>>();
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
  void clearListJourneyStepsCacheKey(String? uniqueKey) => _listJourneyStepsManager.clearRequest(uniqueKey);

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
  void clearJourneyCacheKey(String? uniqueKey) => _journeyManager.clearRequest(uniqueKey);

  final _userRowManager = FutureRequestManager<List<CcMembersRow>>();
  Future<List<CcMembersRow>> userRow({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<CcMembersRow>> Function() requestFn,
  }) =>
      _userRowManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserRowCache() => _userRowManager.clear();
  void clearUserRowCacheKey(String? uniqueKey) => _userRowManager.clearRequest(uniqueKey);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}
