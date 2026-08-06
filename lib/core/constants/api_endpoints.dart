/// Endpoints de la API centralizados.
///
/// Nota: Todos los identificadores del backend son `uuid` (GUID), por lo que se
/// representan como `String` en la app.
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
  static String getTeamsForUser(String coachId) =>
      '/Team/GetTeamsForUser/$coachId';
  static const String getUsersForTeam = '/Team/GetUsersForTeam';
  static const String updateTeam = '/Team/UpdateTeam';
  static const String getRecentStatistics = '/Team/GetRecentStatistics';

  // ── AssessStrength ───────────────────────────────────────────────
  static const String strengthAddEvaluation = '/AssessStrength/AddEvaluation';
  static const String strengthAthletesToEvaluated =
      '/AssessStrength/AthletesToEvaluated';
  static const String strengthAddDetails =
      '/AssessStrength/AddDeatilsToEvaluation';
  static String strengthGetActiveEvaluation(String teamId, String coachId) =>
      '/AssessStrength/GetActiveEvaluation/$teamId/$coachId';
  static String strengthDebugEvaluations(String teamId) =>
      '/AssessStrength/DebugEvaluations/$teamId';
  static const String strengthUpdateState = '/AssessStrength/UpdateState';
  static const String strengthCancel = '/AssessStrength/Cancel';
  static String strengthGetTeamEvaluations(String teamId) =>
      '/AssessStrength/GetTeamEvaluations/$teamId';
  static String strengthGetEvaluationStatistics(String assessStrengthId) =>
      '/AssessStrength/GetEvaluationStatistics/$assessStrengthId';
  static String strengthGetEvaluationDetails(String assessStrengthId) =>
      '/AssessStrength/GetEvaluationDetails/$assessStrengthId';
  static String strengthCoachHasEvaluations(String coachId) =>
      '/AssessStrength/CoachHasEvaluations/$coachId';

  // ── AssessDirection ──────────────────────────────────────────────
  static const String directionAddEvaluation = '/AssessDirection/AddEvaluation';
  static const String directionAthletesToEvaluated =
      '/AssessDirection/AthletesToEvaluated';
  static const String directionAddDetails =
      '/AssessDirection/AddDetailsToEvaluation';
  static String directionGetActiveEvaluation(String teamId, String coachId) =>
      '/AssessDirection/GetActiveEvaluation/$teamId/$coachId';
  static String directionDebugEvaluations(String teamId) =>
      '/AssessDirection/DebugEvaluations/$teamId';
  static const String directionUpdateState = '/AssessDirection/UpdateState';
  static const String directionCancel = '/AssessDirection/Cancel';
  static String directionGetTeamEvaluations(String teamId) =>
      '/AssessDirection/GetTeamEvaluations/$teamId';
  static String directionGetEvaluationStatistics(String assessDirectionId) =>
      '/AssessDirection/GetEvaluationStatistics/$assessDirectionId';
  static String directionGetEvaluationDetails(String assessDirectionId) =>
      '/AssessDirection/GetEvaluationDetails/$assessDirectionId';
  static String directionCoachHasEvaluations(String coachId) =>
      '/AssessDirection/CoachHasEvaluations/$coachId';

  // ── AssessSaremas ─────────────────────────────────────────────────
  static const String saremasAddEvaluation = '/AssessSaremas/AddEvaluation';
  static const String saremasAthletesToEvaluated =
      '/AssessSaremas/AthletesToEvaluated';
  static const String saremasAddDetails = '/AssessSaremas/AddDetailsToEvaluation';
  static String saremasGetActiveEvaluation(String teamId, String coachId) =>
      '/AssessSaremas/GetActiveEvaluation/$teamId/$coachId';
  static const String saremasUpdateState = '/AssessSaremas/UpdateState';
  static const String saremasCancel = '/AssessSaremas/Cancel';
  static String saremasGetTeamEvaluations(String teamId) =>
      '/AssessSaremas/GetTeamEvaluations/$teamId';
  static String saremasGetEvaluationDetails(String saremasEvalId) =>
      '/AssessSaremas/GetEvaluationDetails/$saremasEvalId';
  static String saremasGetEvaluationStatistics(String saremasEvalId) =>
      '/AssessSaremas/GetEvaluationStatistics/$saremasEvalId';
  static String saremasGetAthleteHistory(String athleteId) =>
      '/AssessSaremas/GetAthleteHistory/$athleteId';
  static String saremasCoachHasEvaluations(String coachId) =>
      '/AssessSaremas/CoachHasEvaluations/$coachId';

  // ── Macrocycle ───────────────────────────────────────────────────
  static const String macrocycleCreate = '/Macrocycle/Create';
  static String macrocycleGetByAthlete(String athleteId) =>
      '/Macrocycle/GetByAthlete/$athleteId';
  static String macrocycleGetByTeam(String teamId) =>
      '/Macrocycle/GetByTeam/$teamId';
  static String macrocycleGetById(String macrocycleId) =>
      '/Macrocycle/GetById/$macrocycleId';
  static const String macrocycleUpdate = '/Macrocycle/Update';
  static String macrocycleDelete(String macrocycleId) =>
      '/Macrocycle/Delete/$macrocycleId';
  static const String macrocycleAddEvent = '/Macrocycle/AddEvent';
  static const String macrocycleUpdateEvent = '/Macrocycle/UpdateEvent';
  static String macrocycleDeleteEvent(String eventId) =>
      '/Macrocycle/DeleteEvent/$eventId';
  static const String macrocycleUpdateMicrocycle =
      '/Macrocycle/UpdateMicrocycle';
  static String macrocycleGetCoachMacrocycles(String coachId) =>
      '/Macrocycle/GetCoachMacrocycles/$coachId';
  static String macrocycleDuplicate(String macrocycleId) =>
      '/Macrocycle/Duplicate/$macrocycleId';
  static const String macrocycleUpdateMicycleDays =
      '/Macrocycle/UpdateMicycleDays';

  // ── MicrocycleType ───────────────────────────────────────────────
  static const String microcycleTypeCreate = '/MicrocycleType/Create';
  static const String microcycleTypeGetAll = '/MicrocycleType/GetAll';
  static String microcycleTypeGetById(String id) =>
      '/MicrocycleType/GetById/$id';
  static String microcycleTypeGetAllForCoach(String coachId) =>
      '/MicrocycleType/GetAllForCoach/$coachId';
  static String microcycleTypeGetForCoach(String id, String coachId) =>
      '/MicrocycleType/GetForCoach/$id/$coachId';
  static const String microcycleTypeUpdateCoachPercentages =
      '/MicrocycleType/UpdateCoachPercentages';
  static String microcycleTypeResetCoachPercentages(
          String coachId, String microcycleTypeId) =>
      '/MicrocycleType/ResetCoachPercentages/$coachId/$microcycleTypeId';
  static const String microcycleTypeGetOverview = '/MicrocycleType/GetOverview';
  static const String microcycleTypeCreateDayDefault =
      '/MicrocycleType/CreateDayDefault';
  static const String microcycleTypeUpsertCoachDistribution =
      '/MicrocycleType/UpsertCoachDistribution';
  static String microcycleTypeGetCoachDistribution(
          String coachId, String microcycleTypeId) =>
      '/MicrocycleType/GetCoachDistribution/$coachId/$microcycleTypeId';
  static String microcycleTypeGetAllCoachDistributions(String coachId) =>
      '/MicrocycleType/GetAllCoachDistributions/$coachId';
  static String microcycleTypeDeleteCoachDistribution(
          String coachId, String microcycleTypeId) =>
      '/MicrocycleType/DeleteCoachDistribution/$coachId/$microcycleTypeId';

  // ── Rol ──────────────────────────────────────────────────────────
  static const String rolCreate = '/Rol/Create';
  static const String rolGetAll = '/Rol/GetAll';
  static String rolGetById(String id) => '/Rol/GetById/$id';
  static const String rolUpdate = '/Rol/Update';
  static String rolDelete(String id) => '/Rol/Delete/$id';

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
  static String notificationGetType(String id) => '/Notification/GetType/$id';
  static const String notificationCreateType = '/Notification/CreateType';
  static const String notificationUpdateType = '/Notification/UpdateType';
  static String notificationGetMessage(String id) =>
      '/Notification/GetMessage/$id';
  static const String notificationCreateMessage = '/Notification/CreateMessage';
  static const String notificationUpdateMessage = '/Notification/UpdateMessage';
  static String notificationGetMessagesByCoach(String coachId) =>
      '/Notification/GetMessagesByCoach/$coachId';
  static String notificationGetMessagesByAthlete(String athleteId) =>
      '/Notification/GetMessagesByAthlete/$athleteId';
  static const String notificationSendTeamInvitation =
      '/Notification/SendTeamInvitation';
  static String notificationAcceptTeamInvitation(String notificationMessageId) =>
      '/Notification/AcceptTeamInvitation/$notificationMessageId';

  // ── Statistics ───────────────────────────────────────────────────
  static const String recentStrengthStats = '/Statistics/RecentStrengthStats';
  static String teamStrengthStats(String teamId) =>
      '/Statistics/TeamStrengthStats/$teamId';
  static String debugTeamEvaluations(String teamId) =>
      '/Statistics/DebugTeamEvaluations/$teamId';
  static String teamStrengthStatsIndividualized(String teamId) =>
      '/Statistics/TeamStrengthStatsIndividualized/$teamId';
  static String athleteStats(String athleteId) =>
      '/Statistics/AthleteStats/$athleteId';
  static const String allTeamsStats = '/Statistics/AllTeamsStats';
  static const String compareTeams = '/Statistics/CompareTeams';
  static const String dashboardIndicators = '/Statistics/DashboardIndicators';
  static const String dashboardComplete = '/Statistics/DashboardComplete';
  static const String topPerformanceAthletes =
      '/Statistics/TopPerformanceAthletes';
  static const String recentTests = '/Statistics/RecentTests';
  static const String pendingTasks = '/Statistics/PendingTasks';
  static const String monthlyEvolution = '/Statistics/MonthlyEvolution';
  static String nextSession(String coachId) =>
      '/Statistics/NextSession/$coachId';
  static String coachTeamsOverview(String coachId) =>
      '/Statistics/CoachTeamsOverview/$coachId';
  static String saremasTeamStats(String teamId) =>
      '/Statistics/SaremasTeamStats/$teamId';
  static String saremasAthleteStats(String athleteId) =>
      '/Statistics/SaremasAthleteStats/$athleteId';
  static String macrocycleProgress(String macrocycleId) =>
      '/Statistics/MacrocycleProgress/$macrocycleId';
  static String athleteFullDashboard(String athleteId) =>
      '/Statistics/AthleteFullDashboard/$athleteId';

  // ── Subscription ─────────────────────────────────────────────────
  static const String subscriptionTypes = '/Subscription/types';
  static String subscriptionTypeById(String id) => '/Subscription/types/$id';
  static String subscriptionUser(String userId) => '/Subscription/user/$userId';
  static String subscriptionUserHistory(String userId) =>
      '/Subscription/user/$userId/history';
  static const String subscriptionCreate = '/Subscription/create';
  static const String subscriptionCancel = '/Subscription/cancel';
  static const String subscriptionUpdate = '/Subscription/update';
  static String subscriptionReactivate(String subscriptionId) =>
      '/Subscription/reactivate/$subscriptionId';
  static const String subscriptionTrialStart = '/Subscription/trial/start';
  static String subscriptionTrialAvailable(
          String userId, String subscriptionTypeId) =>
      '/Subscription/trial/available/$userId/$subscriptionTypeId';
  static String subscriptionValidate(String userId) =>
      '/Subscription/validate/$userId';
  static String subscriptionAccess(String userId, String featureName) =>
      '/Subscription/access/$userId/$featureName';
  static String subscriptionCanCreateTeam(String userId) =>
      '/Subscription/limits/$userId/can-create-team';
  static String subscriptionCanAddAthlete(String userId, String teamId) =>
      '/Subscription/limits/$userId/can-add-athlete/$teamId';
  static String subscriptionCanEvaluate(String userId) =>
      '/Subscription/limits/$userId/can-evaluate';
  static String subscriptionRemainingTeams(String userId) =>
      '/Subscription/limits/$userId/remaining-teams';
  static String subscriptionRemainingAthletes(String userId, String teamId) =>
      '/Subscription/limits/$userId/remaining-athletes/$teamId';
  static String subscriptionRemainingEvaluations(String userId) =>
      '/Subscription/limits/$userId/remaining-evaluations';
  static const String subscriptionPaymentCreateIntent =
      '/Subscription/payment/create-intent';
  static const String subscriptionPaymentConfirm =
      '/Subscription/payment/confirm';
  static String subscriptionPaymentGet(String paymentIntentId) =>
      '/Subscription/payment/$paymentIntentId';
  static String subscriptionPaymentCancel(String paymentIntentId) =>
      '/Subscription/payment/cancel/$paymentIntentId';
  static const String subscriptionWebhookStripe = '/Subscription/webhooks/stripe';
  static const String subscriptionAdminAll = '/Subscription/admin/all';
  static const String subscriptionAdminStatistics =
      '/Subscription/admin/statistics';

  // ── TrainingSession ──────────────────────────────────────────────
  static const String trainingSessionCreate = '/TrainingSession/Create';
  static String trainingSessionGetById(String sessionId) =>
      '/TrainingSession/GetById/$sessionId';
  static String trainingSessionGetByMicrocycle(String microcycleId) =>
      '/TrainingSession/GetByMicrocycle/$microcycleId';
  static const String trainingSessionUpdate = '/TrainingSession/Update';
  static String trainingSessionDelete(String sessionId) =>
      '/TrainingSession/Delete/$sessionId';
  static const String trainingSessionAddSection =
      '/TrainingSession/AddSection';
  static const String trainingSessionUpdateSection =
      '/TrainingSession/UpdateSection';
  static String trainingSessionDeleteSection(String sectionId) =>
      '/TrainingSession/DeleteSection/$sectionId';

  // ── TrainingSession / Athlete ────────────────────────────────────
  static const String athleteGetSessionsByDateRange =
      '/TrainingSession/Athlete/GetSessionsByDateRange';
  static String athleteGetSessionDetail(String sessionId, String athleteId) =>
      '/TrainingSession/Athlete/GetSessionDetail/$sessionId/$athleteId';
  static const String athleteStartSession =
      '/TrainingSession/Athlete/StartSession';
  static const String athleteFinishSession =
      '/TrainingSession/Athlete/FinishSession';

  // ── Wellness ─────────────────────────────────────────────────────
  static const String wellnessAddDailyWellness = '/Wellness/AddDailyWellness';
  static const String wellnessUpdateDailyWellness =
      '/Wellness/UpdateDailyWellness';
  static String wellnessGetTodayWellness(String athleteId) =>
      '/Wellness/GetTodayWellness/$athleteId';
  static String wellnessGetWellnessByDate(String athleteId, String date) =>
      '/Wellness/GetWellnessByDate/$athleteId/$date';
  static String wellnessGetWellnessById(String dailyWellnessId) =>
      '/Wellness/GetWellnessById/$dailyWellnessId';
  static String wellnessGetAthleteHistory(String athleteId) =>
      '/Wellness/GetAthleteHistory/$athleteId';
  static String wellnessGetTeamWellnessByDate(String teamId, String date) =>
      '/Wellness/GetTeamWellnessByDate/$teamId/$date';
}
