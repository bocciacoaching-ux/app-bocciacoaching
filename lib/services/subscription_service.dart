import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class SubscriptionService {
  final String _base = AppConfig.baseUrl;

  // GET /api/Subscription/types
  Future<Map<String, dynamic>?> getTypes() async {
    try {
      final response = await http.get(Uri.parse('$_base/Subscription/types'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/types
  Future<Map<String, dynamic>?> createType({
    String? name,
    String? description,
    required double monthlyPrice,
    double? annualPrice,
    String? features,
    int? teamLimit,
    int? athleteLimit,
    int? monthlyEvaluationLimit,
    required bool hasAdvancedStatistics,
    required bool hasPremiumChat,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/types'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'monthlyPrice': monthlyPrice,
          'annualPrice': annualPrice,
          'features': features,
          'teamLimit': teamLimit,
          'athleteLimit': athleteLimit,
          'monthlyEvaluationLimit': monthlyEvaluationLimit,
          'hasAdvancedStatistics': hasAdvancedStatistics,
          'hasPremiumChat': hasPremiumChat,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/types/{id}
  Future<Map<String, dynamic>?> getTypeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/types/$id'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/Subscription/types/{id}
  Future<Map<String, dynamic>?> updateType(int id, {
    String? name,
    String? description,
    required double monthlyPrice,
    double? annualPrice,
    String? features,
    int? teamLimit,
    int? athleteLimit,
    int? monthlyEvaluationLimit,
    required bool hasAdvancedStatistics,
    required bool hasPremiumChat,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Subscription/types/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
          'monthlyPrice': monthlyPrice,
          'annualPrice': annualPrice,
          'features': features,
          'teamLimit': teamLimit,
          'athleteLimit': athleteLimit,
          'monthlyEvaluationLimit': monthlyEvaluationLimit,
          'hasAdvancedStatistics': hasAdvancedStatistics,
          'hasPremiumChat': hasPremiumChat,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // DELETE /api/Subscription/types/{id}
  Future<Map<String, dynamic>?> deleteType(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_base/Subscription/types/$id'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/user/{userId}
  Future<Map<String, dynamic>?> getUserSubscription(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/user/$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/user/{userId}/history
  Future<Map<String, dynamic>?> getUserSubscriptionHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/user/$userId/history'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/create
  Future<Map<String, dynamic>?> createSubscription({
    required int userId,
    required int subscriptionTypeId,
    required bool isAnnual,
    required bool isTrial,
    int? trialDays,
    String? paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'subscriptionTypeId': subscriptionTypeId,
          'isAnnual': isAnnual,
          'isTrial': isTrial,
          'trialDays': trialDays,
          'paymentMethodId': paymentMethodId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/cancel
  Future<Map<String, dynamic>?> cancelSubscription({
    required int subscriptionId,
    required bool cancelAtPeriodEnd,
    String? cancellationReason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
          'cancelAtPeriodEnd': cancelAtPeriodEnd,
          'cancellationReason': cancellationReason,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // PUT /api/Subscription/update
  Future<Map<String, dynamic>?> updateSubscription({
    required int subscriptionId,
    required int newSubscriptionTypeId,
    required bool isAnnual,
    required bool prorationBehavior,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_base/Subscription/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': subscriptionId,
          'newSubscriptionTypeId': newSubscriptionTypeId,
          'isAnnual': isAnnual,
          'prorationBehavior': prorationBehavior,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/reactivate/{subscriptionId}
  Future<Map<String, dynamic>?> reactivateSubscription(int subscriptionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/reactivate/$subscriptionId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/trial/start?userId=&subscriptionTypeId=&trialDays=
  Future<Map<String, dynamic>?> startTrial({
    required int userId,
    required int subscriptionTypeId,
    int trialDays = 7,
  }) async {
    try {
      final uri = Uri.parse('$_base/Subscription/trial/start').replace(
        queryParameters: {
          'userId': '$userId',
          'subscriptionTypeId': '$subscriptionTypeId',
          'trialDays': '$trialDays',
        },
      );
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/trial/available/{userId}/{subscriptionTypeId}
  Future<Map<String, dynamic>?> isTrialAvailable(int userId, int subscriptionTypeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/trial/available/$userId/$subscriptionTypeId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/validate/{userId}?feature=
  Future<Map<String, dynamic>?> validateSubscription(int userId, {String? feature}) async {
    try {
      final uri = Uri.parse('$_base/Subscription/validate/$userId').replace(
        queryParameters: {
          if (feature != null) 'feature': feature,
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

  // GET /api/Subscription/access/{userId}/{featureName}
  Future<Map<String, dynamic>?> checkFeatureAccess(int userId, String featureName) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/access/$userId/$featureName'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/can-create-team
  Future<Map<String, dynamic>?> canCreateTeam(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/can-create-team'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/can-add-athlete/{teamId}
  Future<Map<String, dynamic>?> canAddAthlete(int userId, int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/can-add-athlete/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/can-evaluate
  Future<Map<String, dynamic>?> canEvaluate(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/can-evaluate'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/remaining-teams
  Future<Map<String, dynamic>?> getRemainingTeams(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/remaining-teams'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/remaining-athletes/{teamId}
  Future<Map<String, dynamic>?> getRemainingAthletes(int userId, int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/remaining-athletes/$teamId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/limits/{userId}/remaining-evaluations
  Future<Map<String, dynamic>?> getRemainingEvaluations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/limits/$userId/remaining-evaluations'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/payment/create-intent
  Future<Map<String, dynamic>?> createPaymentIntent({
    required int subscriptionTypeId,
    required int userId,
    required bool isAnnual,
    String? currency,
    String? paymentMethodId,
    required bool confirmPayment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/payment/create-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionTypeId': subscriptionTypeId,
          'userId': userId,
          'isAnnual': isAnnual,
          'currency': currency,
          'paymentMethodId': paymentMethodId,
          'confirmPayment': confirmPayment,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/payment/confirm
  Future<Map<String, dynamic>?> confirmPayment({
    String? paymentIntentId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/payment/confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          'paymentMethodId': paymentMethodId,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET /api/Subscription/payment/{paymentIntentId}
  Future<Map<String, dynamic>?> getPaymentIntent(String paymentIntentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_base/Subscription/payment/$paymentIntentId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST /api/Subscription/payment/cancel/{paymentIntentId}
  Future<Map<String, dynamic>?> cancelPaymentIntent(String paymentIntentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_base/Subscription/payment/cancel/$paymentIntentId'),
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
