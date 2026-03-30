/// Endpoints de la API centralizados.
abstract final class ApiEndpoints {
  // ── Auth / User ──────────────────────────────────────────────────
  static const String getInfoUser = '/User';
  static const String addInfoUser = '/User/AddInfoUser';
  static const String login = '/User/login';
  static const String addAthlete = '/User/AddAthlete';
  static const String validateEmail = '/User/ValidateEmail';
  static const String searchAthletes = '/User/SearchAthletesForNameAndTeams';
  static const String updatePassword = '/User/UpdatePassword';
  static const String updateUserInfo = '/User/UpdateUserInfo';

  // ── Team ─────────────────────────────────────────────────────────
  static const String addNewTeam = '/Team/AddNewTeam';
  static const String addNewTeamMember = '/Team/AddNewTeamMember';
  static String getTeamsForUser(int coachId) => '/Team/GetTeamsForUser/$coachId';
  static const String getUsersForTeam = '/Team/GetUsersForTeam';
  static const String updateTeam = '/Team/UpdateTeam';
  static const String getRecentStatistics = '/Team/GetRecentStatistics';

  // ── AssessStrength ───────────────────────────────────────────────
  static const String strengthAddEvaluation = '/AssessStrength/AddEvaluation';
  static const String strengthAthletesToEvaluated = '/AssessStrength/AthletesToEvaluated';
  static const String strengthAddDetails = '/AssessStrength/AddDeatilsToEvaluation';
  static String strengthGetActiveEvaluation(int teamId, int coachId) =>
      '/AssessStrength/GetActiveEvaluation/$teamId/$coachId';
  static String strengthDebugEvaluations(int teamId) =>
      '/AssessStrength/DebugEvaluations/$teamId';
  static const String strengthUpdateState = '/AssessStrength/UpdateState';
  static const String strengthCancel = '/AssessStrength/Cancel';
  static String strengthGetTeamEvaluations(int teamId) =>
      '/AssessStrength/GetTeamEvaluations/$teamId';
  static String strengthGetEvaluationStatistics(int assessStrengthId) =>
      '/AssessStrength/GetEvaluationStatistics/$assessStrengthId';
  static String strengthGetEvaluationDetails(int assessStrengthId) =>
      '/AssessStrength/GetEvaluationDetails/$assessStrengthId';

  // ── AssessDirection ──────────────────────────────────────────────
  static const String directionAddEvaluation = '/AssessDirection/AddEvaluation';
  static const String directionAthletesToEvaluated = '/AssessDirection/AthletesToEvaluated';
  static const String directionAddDetails = '/AssessDirection/AddDetailsToEvaluation';
  static String directionGetActiveEvaluation(int teamId, int coachId) =>
      '/AssessDirection/GetActiveEvaluation/$teamId/$coachId';
  static String directionDebugEvaluations(int teamId) =>
      '/AssessDirection/DebugEvaluations/$teamId';
  static const String directionUpdateState = '/AssessDirection/UpdateState';
  static const String directionCancel = '/AssessDirection/Cancel';
  static String directionGetTeamEvaluations(int teamId) =>
      '/AssessDirection/GetTeamEvaluations/$teamId';
  static String directionGetEvaluationStatistics(int assessDirectionId) =>
      '/AssessDirection/GetEvaluationStatistics/$assessDirectionId';
  static String directionGetEvaluationDetails(int assessDirectionId) =>
      '/AssessDirection/GetEvaluationDetails/$assessDirectionId';

  // ── AssessSaremas ─────────────────────────────────────────────────
  static const String saremasAddEvaluation = '/AssessSaremas/AddEvaluation';
  static const String saremasAthletesToEvaluated = '/AssessSaremas/AthletesToEvaluated';
  static const String saremasAddDetails = '/AssessSaremas/AddDetailsToEvaluation';
  static String saremasGetActiveEvaluation(int teamId, int coachId) =>
      '/AssessSaremas/GetActiveEvaluation/$teamId/$coachId';
  static const String saremasUpdateState = '/AssessSaremas/UpdateState';
  static const String saremasCancel = '/AssessSaremas/Cancel';
  static String saremasGetTeamEvaluations(int teamId) =>
      '/AssessSaremas/GetTeamEvaluations/$teamId';
  static String saremasGetEvaluationDetails(int saremasEvalId) =>
      '/AssessSaremas/GetEvaluationDetails/$saremasEvalId';
  static String saremasGetEvaluationStatistics(int saremasEvalId) =>
      '/AssessSaremas/GetEvaluationStatistics/$saremasEvalId';
  static String saremasGetAthleteHistory(int athleteId) =>
      '/AssessSaremas/GetAthleteHistory/$athleteId';

  // ── Macrocycle ───────────────────────────────────────────────────
  static const String macrocycleCreate = '/Macrocycle/Create';
  static String macrocycleGetByAthlete(int athleteId) =>
      '/Macrocycle/GetByAthlete/$athleteId';
  static String macrocycleGetByTeam(int teamId) =>
      '/Macrocycle/GetByTeam/$teamId';
  static String macrocycleGetById(int macrocycleId) =>
      '/Macrocycle/GetById/$macrocycleId';
  static const String macrocycleUpdate = '/Macrocycle/Update';
  static String macrocycleDelete(int macrocycleId) =>
      '/Macrocycle/Delete/$macrocycleId';
  static const String macrocycleAddEvent = '/Macrocycle/AddEvent';
  static const String macrocycleUpdateEvent = '/Macrocycle/UpdateEvent';
  static String macrocycleDeleteEvent(int eventId) =>
      '/Macrocycle/DeleteEvent/$eventId';
  static const String macrocycleUpdateMicrocycle = '/Macrocycle/UpdateMicrocycle';
  static String macrocycleGetCoachMacrocycles(int coachId) =>
      '/Macrocycle/GetCoachMacrocycles/$coachId';
  static String macrocycleDuplicate(int macrocycleId) =>
      '/Macrocycle/Duplicate/$macrocycleId';

  // ── Email ────────────────────────────────────────────────────────
  static const String sendCodeVerify = '/Email/SendCodeVerify';
  static const String validateCode = '/Email/ValidateCode';
  static const String testSmtpConnectivity = '/Email/TestSmtpConnectivity';
  static const String sendTestEmail = '/Email/SendTestEmail';

  // ── EmailTest ────────────────────────────────────────────────────
  static const String emailTestSend = '/EmailTest/test-email';
  static const String emailTestDiagnose = '/EmailTest/diagnose';
  static const String emailTestPing = '/EmailTest/ping';

  // ── Notification ─────────────────────────────────────────────────
  static const String notificationGetTypes = '/Notification/GetTypes';
  static String notificationGetType(int id) => '/Notification/GetType/$id';
  static const String notificationCreateType = '/Notification/CreateType';
  static const String notificationUpdateType = '/Notification/UpdateType';
  static String notificationGetMessage(int id) => '/Notification/GetMessage/$id';
  static const String notificationCreateMessage = '/Notification/CreateMessage';
  static const String notificationUpdateMessage = '/Notification/UpdateMessage';
  static String notificationGetMessagesByCoach(int coachId) =>
      '/Notification/GetMessagesByCoach/$coachId';
  static String notificationGetMessagesByAthlete(int athleteId) =>
      '/Notification/GetMessagesByAthlete/$athleteId';
  static const String notificationSendTeamInvitation = '/Notification/SendTeamInvitation';
  static String notificationAcceptTeamInvitation(int notificationMessageId) =>
      '/Notification/AcceptTeamInvitation/$notificationMessageId';

  // ── Statistics ───────────────────────────────────────────────────
  static const String recentStrengthStats = '/Statistics/RecentStrengthStats';
  static String teamStrengthStats(int teamId) => '/Statistics/TeamStrengthStats/$teamId';
  static String debugTeamEvaluations(int teamId) =>
      '/Statistics/DebugTeamEvaluations/$teamId';
  static String teamStrengthStatsIndividualized(int teamId) =>
      '/Statistics/TeamStrengthStatsIndividualized/$teamId';
  static String athleteStats(int athleteId) => '/Statistics/AthleteStats/$athleteId';
  static const String allTeamsStats = '/Statistics/AllTeamsStats';
  static const String compareTeams = '/Statistics/CompareTeams';
  static const String dashboardIndicators = '/Statistics/DashboardIndicators';
  static const String dashboardComplete = '/Statistics/DashboardComplete';
  static const String topPerformanceAthletes = '/Statistics/TopPerformanceAthletes';
  static const String recentTests = '/Statistics/RecentTests';
  static const String pendingTasks = '/Statistics/PendingTasks';
  static const String monthlyEvolution = '/Statistics/MonthlyEvolution';
  static String nextSession(int coachId) => '/Statistics/NextSession/$coachId';
  static String coachTeamsOverview(int coachId) =>
      '/Statistics/CoachTeamsOverview/$coachId';
  static String saremasTeamStats(int teamId) =>
      '/Statistics/SaremasTeamStats/$teamId';
  static String saremasAthleteStats(int athleteId) =>
      '/Statistics/SaremasAthleteStats/$athleteId';
  static String macrocycleProgress(int macrocycleId) =>
      '/Statistics/MacrocycleProgress/$macrocycleId';
  static String athleteFullDashboard(int athleteId) =>
      '/Statistics/AthleteFullDashboard/$athleteId';

  // ── Subscription ─────────────────────────────────────────────────
  static const String subscriptionTypes = '/Subscription/types';
  static String subscriptionTypeById(int id) => '/Subscription/types/$id';
  static String subscriptionUser(int userId) => '/Subscription/user/$userId';
  static String subscriptionUserHistory(int userId) =>
      '/Subscription/user/$userId/history';
  static const String subscriptionCreate = '/Subscription/create';
  static const String subscriptionCancel = '/Subscription/cancel';
  static const String subscriptionUpdate = '/Subscription/update';
  static String subscriptionReactivate(int subscriptionId) =>
      '/Subscription/reactivate/$subscriptionId';
  static const String subscriptionTrialStart = '/Subscription/trial/start';
  static String subscriptionTrialAvailable(int userId, int subscriptionTypeId) =>
      '/Subscription/trial/available/$userId/$subscriptionTypeId';
  static String subscriptionValidate(int userId) => '/Subscription/validate/$userId';
  static String subscriptionAccess(int userId, String featureName) =>
      '/Subscription/access/$userId/$featureName';
  static String subscriptionCanCreateTeam(int userId) =>
      '/Subscription/limits/$userId/can-create-team';
  static String subscriptionCanAddAthlete(int userId, int teamId) =>
      '/Subscription/limits/$userId/can-add-athlete/$teamId';
  static String subscriptionCanEvaluate(int userId) =>
      '/Subscription/limits/$userId/can-evaluate';
  static String subscriptionRemainingTeams(int userId) =>
      '/Subscription/limits/$userId/remaining-teams';
  static String subscriptionRemainingAthletes(int userId, int teamId) =>
      '/Subscription/limits/$userId/remaining-athletes/$teamId';
  static String subscriptionRemainingEvaluations(int userId) =>
      '/Subscription/limits/$userId/remaining-evaluations';
  static const String subscriptionPaymentCreateIntent =
      '/Subscription/payment/create-intent';
  static const String subscriptionPaymentConfirm = '/Subscription/payment/confirm';
  static String subscriptionPaymentGet(String paymentIntentId) =>
      '/Subscription/payment/$paymentIntentId';
  static String subscriptionPaymentCancel(String paymentIntentId) =>
      '/Subscription/payment/cancel/$paymentIntentId';
  static const String subscriptionWebhookStripe = '/Subscription/webhooks/stripe';
  static const String subscriptionAdminAll = '/Subscription/admin/all';
  static const String subscriptionAdminStatistics = '/Subscription/admin/statistics';
}
