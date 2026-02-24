import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../models/team_member.dart';
import '../services/team_service.dart';

enum TeamLoadingStatus { idle, loading, success, error }

class TeamProvider extends ChangeNotifier {
  final TeamService _teamService = TeamService();

  // ── Estado de equipos ─────────────────────────────────────────────────
  List<Team> _teams = [];
  Team? _selectedTeam;
  TeamLoadingStatus _status = TeamLoadingStatus.idle;
  String? _errorMessage;

  List<Team> get teams => List.unmodifiable(_teams);
  Team? get selectedTeam => _selectedTeam;
  TeamLoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == TeamLoadingStatus.loading;
  bool get hasError => _status == TeamLoadingStatus.error;
  bool get hasTeams => _teams.isNotEmpty;

  // ── Estado de miembros (atletas) del equipo seleccionado ──────────────
  List<TeamMember> _members = [];
  TeamLoadingStatus _membersStatus = TeamLoadingStatus.idle;
  String? _membersErrorMessage;

  List<TeamMember> get members => List.unmodifiable(_members);
  TeamLoadingStatus get membersStatus => _membersStatus;
  String? get membersErrorMessage => _membersErrorMessage;

  bool get isMembersLoading => _membersStatus == TeamLoadingStatus.loading;
  bool get hasMembersError => _membersStatus == TeamLoadingStatus.error;
  bool get hasMembers => _members.isNotEmpty;

  // ── Equipos ───────────────────────────────────────────────────────────

  /// Obtiene los equipos del coach desde GET /api/Team/GetTeamsForUser/{coachId}
  Future<void> fetchTeams(int coachId) async {
    if (_status == TeamLoadingStatus.loading) return;

    _status = TeamLoadingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _teamService.getTeamsForUser(coachId: coachId);

    if (result != null) {
      _teams = result;
      // Si no hay equipo seleccionado o el seleccionado ya no existe, seleccionar el primero.
      if (_selectedTeam == null ||
          !_teams.any((t) => t.teamId == _selectedTeam!.teamId)) {
        _selectedTeam = _teams.isNotEmpty ? _teams.first : null;
      }
      _status = TeamLoadingStatus.success;
    } else {
      _errorMessage =
          'No se pudieron cargar los equipos. Verifica tu conexión e intenta de nuevo.';
      _status = TeamLoadingStatus.error;
    }

    notifyListeners();

    // Cargar los miembros del equipo seleccionado automáticamente.
    if (_selectedTeam != null) {
      await fetchMembers(_selectedTeam!.teamId);
    }
  }

  /// Selecciona un equipo activo y carga sus miembros.
  Future<void> selectTeam(Team team) async {
    _selectedTeam = team;
    notifyListeners();
    await fetchMembers(team.teamId);
  }

  // ── Miembros (atletas) ────────────────────────────────────────────────

  /// Obtiene los atletas (rolId = 3) del equipo desde
  /// POST /api/Team/GetUsersForTeam
  Future<void> fetchMembers(int teamId) async {
    if (_membersStatus == TeamLoadingStatus.loading) return;

    _membersStatus = TeamLoadingStatus.loading;
    _membersErrorMessage = null;
    notifyListeners();

    final result = await _teamService.getUsersForTeam(
      teamId: teamId,
      rolId: 3, // 3 = deportista
    );

    if (result != null) {
      _members = result;
      _membersStatus = TeamLoadingStatus.success;
    } else {
      _membersErrorMessage =
          'No se pudieron cargar los atletas. Verifica tu conexión e intenta de nuevo.';
      _membersStatus = TeamLoadingStatus.error;
    }

    notifyListeners();
  }

  /// Limpia toda la información (útil al cerrar sesión).
  void clear() {
    _teams = [];
    _selectedTeam = null;
    _status = TeamLoadingStatus.idle;
    _errorMessage = null;
    _members = [];
    _membersStatus = TeamLoadingStatus.idle;
    _membersErrorMessage = null;
    notifyListeners();
  }
}
