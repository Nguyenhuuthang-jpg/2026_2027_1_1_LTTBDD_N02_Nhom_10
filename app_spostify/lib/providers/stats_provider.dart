import 'package:flutter/foundation.dart';

import '../data/repositories/stats_repository.dart';

/// Số liệu màn Tổng quan (admin).
class StatsProvider extends ChangeNotifier {
  StatsProvider({StatsRepository? repository})
      : _repository = repository ?? StatsRepository();

  final StatsRepository _repository;

  DashboardStats _stats = DashboardStats.empty;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _stats = await _repository.fetchDashboard();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
