import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class StatisticsService {
  final String _base = AppConfig.baseUrl;

  // GET /api/Statistics/RecentStrengthStats?coachId=&teamId=
  Future<Map<String, dynamic>?> getRecentStrengthStats({int? coachId, int? teamId}) async {
    try {
      final uri = Uri.parse('$_base/Statistics/RecentStrengthStats').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (teamId != null) 'teamId': '$teamId',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/TeamStrengthStats/{teamId}
  Future<Map<String, dynamic>?> getTeamStrengthStats(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/TeamStrengthStats/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/TeamStrengthStatsIndividualized/{teamId}
  Future<Map<String, dynamic>?> getTeamStrengthStatsIndividualized(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/TeamStrengthStatsIndividualized/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/AthleteStats/{athleteId}
  Future<Map<String, dynamic>?> getAthleteStats(int athleteId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/AthleteStats/$athleteId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/AllTeamsStats
  Future<Map<String, dynamic>?> getAllTeamsStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/AllTeamsStats'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Statistics/CompareTeams
  Future<Map<String, dynamic>?> compareTeams(List<int> teamIds) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Statistics/CompareTeams'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(teamIds),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/DashboardIndicators?coachId=&teamId=
  Future<Map<String, dynamic>?> getDashboardIndicators({int? coachId, int? teamId}) async {
    try {
      final uri = Uri.parse('$_base/Statistics/DashboardIndicators').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (teamId != null) 'teamId': '$teamId',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/DashboardComplete?coachId=
  Future<Map<String, dynamic>?> getDashboardComplete({int? coachId}) async {
    try {
      final uri = Uri.parse('$_base/Statistics/DashboardComplete').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/TopPerformanceAthletes?coachId=&teamId=&limit=
  Future<Map<String, dynamic>?> getTopPerformanceAthletes({
    int? coachId,
    int? teamId,
    int limit = 5,
  }) async {
    try {
      final uri = Uri.parse('$_base/Statistics/TopPerformanceAthletes').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (teamId != null) 'teamId': '$teamId',
          'limit': '$limit',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/RecentTests?coachId=&teamId=&limit=
  Future<Map<String, dynamic>?> getRecentTests({
    int? coachId,
    int? teamId,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$_base/Statistics/RecentTests').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (teamId != null) 'teamId': '$teamId',
          'limit': '$limit',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/PendingTasks?coachId=&priority=
  Future<Map<String, dynamic>?> getPendingTasks({int? coachId, String? priority}) async {
    try {
      final uri = Uri.parse('$_base/Statistics/PendingTasks').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (priority != null) 'priority': priority,
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/MonthlyEvolution?coachId=&teamId=&months=
  Future<Map<String, dynamic>?> getMonthlyEvolution({
    int? coachId,
    int? teamId,
    int months = 12,
  }) async {
    try {
      final uri = Uri.parse('$_base/Statistics/MonthlyEvolution').replace(
        queryParameters: {
          if (coachId != null) 'coachId': '$coachId',
          if (teamId != null) 'teamId': '$teamId',
          'months': '$months',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/NextSession/{coachId}
  Future<Map<String, dynamic>?> getNextSession(int coachId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/NextSession/$coachId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Statistics/CoachTeamsOverview/{coachId}
  Future<Map<String, dynamic>?> getCoachTeamsOverview(int coachId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Statistics/CoachTeamsOverview/$coachId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
