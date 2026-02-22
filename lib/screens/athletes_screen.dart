import 'package:flutter/material.dart';
import '../widgets/notifications_bottom_sheet.dart';
import '../theme/app_colors.dart';

// Logo reutilizado del dashboard
class _BocciaLogo extends StatelessWidget {
  const _BocciaLogo();
  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/isologo-horizontal.png', height: 72, fit: BoxFit.contain);
  }
}

// ---------------------------------------------------------------------------
// Modelo de atleta (datos de ejemplo; reemplazar por provider/servicio real)
// ---------------------------------------------------------------------------
class Athlete {
  final String id;
  final String name;
  final String classification; // BC1, BC2, BC3, BC4
  final String nationality;
  final String flag;
  final int age;
  final String position; // posición en cancha
  final String status; // 'Activo' | 'Lesionado' | 'Inactivo'
  final double avgScore;

  const Athlete({
    required this.id,
    required this.name,
    required this.classification,
    required this.nationality,
    required this.flag,
    required this.age,
    required this.position,
    required this.status,
    required this.avgScore,
  });
}

// Datos por equipo
const _teamAthletes = <String, List<Athlete>>{
  'Selección de Córdoba': [
    Athlete(id: '1', name: 'María González',    classification: 'BC2', nationality: 'Argentina', flag: '🇦🇷', age: 24, position: 'Lanzadora',  status: 'Activo',    avgScore: 8.4),
    Athlete(id: '2', name: 'Juan Pérez',         classification: 'BC1', nationality: 'Argentina', flag: '🇦🇷', age: 30, position: 'Defensa',     status: 'Activo',    avgScore: 7.9),
    Athlete(id: '3', name: 'Carlos Jiménez',     classification: 'BC3', nationality: 'Argentina', flag: '🇦🇷', age: 27, position: 'Lanzador',    status: 'Lesionado', avgScore: 9.1),
    Athlete(id: '4', name: 'Lucía Rodríguez',    classification: 'BC4', nationality: 'Argentina', flag: '🇦🇷', age: 22, position: 'Mixta',       status: 'Activo',    avgScore: 8.0),
    Athlete(id: '5', name: 'Santiago López',     classification: 'BC2', nationality: 'Argentina', flag: '🇦🇷', age: 35, position: 'Capitán',     status: 'Activo',    avgScore: 8.7),
    Athlete(id: '6', name: 'Valentina Ruiz',     classification: 'BC1', nationality: 'Argentina', flag: '🇦🇷', age: 28, position: 'Lanzadora',   status: 'Inactivo',  avgScore: 6.5),
    Athlete(id: '7', name: 'Matías Fernández',   classification: 'BC3', nationality: 'Argentina', flag: '🇦🇷', age: 31, position: 'Lanzador',    status: 'Activo',    avgScore: 8.2),
    Athlete(id: '8', name: 'Camila Torres',      classification: 'BC4', nationality: 'Argentina', flag: '🇦🇷', age: 25, position: 'Defensa',     status: 'Activo',    avgScore: 7.6),
  ],
  'Equipo Bogotá': [
    Athlete(id: '9',  name: 'Andrés Morales',    classification: 'BC1', nationality: 'Colombia',  flag: '🇨🇴', age: 26, position: 'Lanzador',    status: 'Activo',    avgScore: 8.1),
    Athlete(id: '10', name: 'Daniela Vargas',    classification: 'BC2', nationality: 'Colombia',  flag: '🇨🇴', age: 23, position: 'Mixta',       status: 'Activo',    avgScore: 7.8),
    Athlete(id: '11', name: 'Felipe Castro',     classification: 'BC3', nationality: 'Colombia',  flag: '🇨🇴', age: 29, position: 'Defensa',     status: 'Lesionado', avgScore: 8.9),
    Athlete(id: '12', name: 'Laura Ospina',      classification: 'BC4', nationality: 'Colombia',  flag: '🇨🇴', age: 21, position: 'Lanzadora',   status: 'Activo',    avgScore: 7.3),
    Athlete(id: '13', name: 'Miguel Ángel Ríos', classification: 'BC2', nationality: 'Colombia',  flag: '🇨🇴', age: 34, position: 'Capitán',     status: 'Activo',    avgScore: 8.6),
    Athlete(id: '14', name: 'Isabela Gómez',     classification: 'BC1', nationality: 'Colombia',  flag: '🇨🇴', age: 27, position: 'Lanzadora',   status: 'Inactivo',  avgScore: 6.9),
  ],
  'Equipo Madrid': [
    Athlete(id: '15', name: 'Pablo Martínez',    classification: 'BC2', nationality: 'España',    flag: '🇪🇸', age: 32, position: 'Capitán',     status: 'Activo',    avgScore: 8.8),
    Athlete(id: '16', name: 'Elena Sánchez',     classification: 'BC3', nationality: 'España',    flag: '🇪🇸', age: 24, position: 'Lanzadora',   status: 'Activo',    avgScore: 8.3),
    Athlete(id: '17', name: 'Álvaro García',     classification: 'BC1', nationality: 'España',    flag: '🇪🇸', age: 28, position: 'Defensa',     status: 'Lesionado', avgScore: 7.5),
    Athlete(id: '18', name: 'Nuria López',       classification: 'BC4', nationality: 'España',    flag: '🇪🇸', age: 22, position: 'Mixta',       status: 'Activo',    avgScore: 7.1),
    Athlete(id: '19', name: 'Javier Fernández',  classification: 'BC2', nationality: 'España',    flag: '🇪🇸', age: 30, position: 'Lanzador',    status: 'Activo',    avgScore: 8.0),
  ],
};

// ---------------------------------------------------------------------------
// Colores de estado
// ---------------------------------------------------------------------------
Color _statusColor(String status) {
  switch (status) {
    case 'Lesionado':
      return AppColors.warning;
    case 'Inactivo':
      return AppColors.error;
    default:
      return AppColors.success;
  }
}

Color _statusBg(String status) => _statusColor(status).withAlpha(28);

// ---------------------------------------------------------------------------
// Lista de equipos (misma que en dashboard)
// ---------------------------------------------------------------------------
const _teams = <Map<String, dynamic>>[
  {'name': 'Selección de Córdoba', 'country': 'Argentina', 'flag': '🇦🇷', 'subtitle': 'Solo Córdoba', 'athletes': 8},
  {'name': 'Equipo Bogotá',        'country': 'Colombia',  'flag': '🇨🇴', 'subtitle': 'Solo Bogotá',  'athletes': 6},
  {'name': 'Equipo Madrid',        'country': 'España',    'flag': '🇪🇸', 'subtitle': 'Solo Madrid',  'athletes': 5},
];

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------
class AthletesScreen extends StatefulWidget {
  final String teamName;
  final String teamFlag;
  final String teamSubtitle;

  const AthletesScreen({
    super.key,
    required this.teamName,
    required this.teamFlag,
    required this.teamSubtitle,
  });

  @override
  State<AthletesScreen> createState() => _AthletesScreenState();
}

enum _ViewMode { cards, table }

class _AthletesScreenState extends State<AthletesScreen> {
  _ViewMode _viewMode = _ViewMode.cards;
  String _search = '';
  String? _filterStatus; // null = todos
  int _notificationCount = 3;

  // Equipo activo (puede cambiar desde el endDrawer)
  late String _selectedTeam;
  late String _selectedFlag;
  late String _selectedSubtitle;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedTeam    = widget.teamName;
    _selectedFlag    = widget.teamFlag;
    _selectedSubtitle = widget.teamSubtitle;
  }

  List<Athlete> get _filtered {
    final all = _teamAthletes[_selectedTeam] ?? [];
    return all.where((a) {
      final matchSearch = _search.isEmpty ||
          a.name.toLowerCase().contains(_search.toLowerCase()) ||
          a.classification.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _filterStatus == null || a.status == _filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      endDrawer: _buildTeamEndDrawer(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : _viewMode == _ViewMode.cards
                      ? _buildCardsView()
                      : _buildTableView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregar atleta — en desarrollo')),
          );
        },
        backgroundColor: AppColors.actionPrimaryDefault,
        foregroundColor: AppColors.actionPrimaryInverted,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Agregar atleta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ── AppBar con hamburguesa (drawer) + chip de equipo (endDrawer) ─────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textSecondary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: _buildTeamChip(),
      actions: [
        _buildNotificationButton(),
        _buildProfileMenu(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTeamChip() {
    return GestureDetector(
      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedFlag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTeam,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  _selectedSubtitle,
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Drawer de navegación (igual al del dashboard) ─────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              color: AppColors.white,
              child: Center(child: _BocciaLogo()),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(Icons.home_outlined, 'Inicio', onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
                    }),
                    _drawerItem(Icons.fitness_center_outlined, 'Entrenamiento', onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/evaluations');
                    }),
                    _drawerItem(Icons.group_outlined, 'Atletas', active: true, onTap: () {
                      Navigator.of(context).pop(); // ya estamos aquí
                    }),
                    _drawerItem(Icons.bar_chart_outlined, 'Análisis y estadísticas', onTap: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                  heroTag: 'drawer_close',
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: AppColors.surface,
                  child: const Icon(Icons.close, color: AppColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: active ? const Color.fromRGBO(0, 0, 0, 0.04) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 56,
              color: active ? AppColors.black : Colors.transparent,
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.neutral2),
                  const SizedBox(width: 16),
                  Text(label, style: const TextStyle(fontSize: 16, color: AppColors.neutral2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EndDrawer de cambio de equipo (igual al del dashboard) ───────────────
  Widget _buildTeamEndDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.group_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cambiar equipo',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black)),
                        Text('Selecciona tu equipo activo',
                            style: TextStyle(fontSize: 11, color: AppColors.neutral2)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.neutral2, size: 20),
                  ),
                ],
              ),
            ),
            Container(height: 3, color: AppColors.primary),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      'EQUIPOS ACTIVOS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.neutral5, letterSpacing: 1.2),
                    ),
                  ),
                  ..._teams.map((team) {
                    final bool isSelected = _selectedTeam == team['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTeam     = team['name'] as String;
                          _selectedFlag     = team['flag'] as String;
                          _selectedSubtitle = team['subtitle'] as String;
                          // Resetear búsqueda y filtro al cambiar equipo
                          _search       = '';
                          _filterStatus = null;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 72,
                            color: isSelected ? AppColors.primary : Colors.transparent,
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSelected
                                    ? [const BoxShadow(color: AppColors.primary10, blurRadius: 8, offset: Offset(0, 2))]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Text(team['flag'] as String, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(team['name'] as String,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isSelected ? AppColors.black : AppColors.neutral2)),
                                        const SizedBox(height: 2),
                                        Text(team['country'] as String,
                                            style: const TextStyle(fontSize: 12, color: AppColors.neutral5)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary10
                                          : AppColors.neutral9,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person_outline, size: 12,
                                            color: isSelected ? AppColors.primary : AppColors.neutral5),
                                        const SizedBox(width: 3),
                                        Text('${team['athletes']}',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? AppColors.primary : AppColors.neutral5)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  isSelected
                                      ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                                      : const Icon(Icons.radio_button_unchecked, color: AppColors.neutral5, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => showNotificationsBottomSheet(context),
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') Navigator.of(context).pushNamed('/profile');
        if (value == 'logout') Navigator.of(context).pushReplacementNamed('/');
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          enabled: false,
          value: 'plan',
          child: Row(children: [
            Icon(Icons.card_membership, size: 20),
            SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Plan Premium Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text('Válido hasta 31 dic 2026', style: TextStyle(fontSize: 10, color: AppColors.neutral5)),
            ]),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: Row(children: [
            Icon(Icons.person_outline, size: 20),
            SizedBox(width: 12),
            Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout, size: 20, color: AppColors.error),
            SizedBox(width: 12),
            Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.error)),
          ]),
        ),
      ],
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.secondary,
        child: Text('OB', style: TextStyle(color: AppColors.actionSecondaryInverted, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  // ── Barra de búsqueda + filtros + toggle de vista ────────────────────────
  Widget _buildToolbar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atletas · $_selectedTeam',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Contador de atletas filtrados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filtered.length} atletas',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de búsqueda + toggle
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar atleta o clasificación…',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.neutral5),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.neutral7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.neutral7),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Toggle de vista
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral7),
                ),
                child: Row(
                  children: [
                    _viewToggleBtn(Icons.grid_view_rounded, _ViewMode.cards),
                    _viewToggleBtn(Icons.table_rows_rounded, _ViewMode.table),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chips de filtro por estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(null, 'Todos'),
                const SizedBox(width: 8),
                _filterChip('Activo', 'Activos'),
                const SizedBox(width: 8),
                _filterChip('Lesionado', 'Lesionados'),
                const SizedBox(width: 8),
                _filterChip('Inactivo', 'Inactivos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggleBtn(IconData icon, _ViewMode mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 20, color: active ? AppColors.actionPrimaryInverted : AppColors.neutral5),
      ),
    );
  }

  Widget _filterChip(String? status, String label) {
    final active = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.neutral7,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.actionPrimaryInverted : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Vista en tarjetas ────────────────────────────────────────────────────
  Widget _buildCardsView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _AthleteCard(athlete: _filtered[i]),
    );
  }

  // ── Vista en tabla ───────────────────────────────────────────────────────
  Widget _buildTableView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.background),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral2,
            ),
            dataTextStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            columnSpacing: 18,
            horizontalMargin: 16,
            dividerThickness: 0.8,
            columns: const [
              DataColumn(label: Text('Atleta')),
              DataColumn(label: Text('Clasificación')),
              DataColumn(label: Text('Posición')),
              DataColumn(label: Text('Edad')),
              DataColumn(label: Text('Prom.')),
              DataColumn(label: Text('Estado')),
            ],
            rows: _filtered.map((a) {
              return DataRow(
                onSelectChanged: (_) =>
                    Navigator.of(context).pushNamed('/athlete-profile', arguments: a),
                cells: [
                // Nombre con avatar
                DataCell(Row(children: [
                  _miniAvatar(a),
                  const SizedBox(width: 8),
                  Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ])),
                DataCell(_ClassBadge(classification: a.classification)),
                DataCell(Text(a.position)),
                DataCell(Text('${a.age} a')),
                DataCell(Text(a.avgScore.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                DataCell(_StatusChip(status: a.status)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _miniAvatar(Athlete a) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: AppColors.primary10,
      child: Text(
        a.name.split(' ').map((w) => w[0]).take(2).join(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: AppColors.neutral7),
          const SizedBox(height: 12),
          const Text('Sin resultados', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral5, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Intenta con otro nombre o ajusta los filtros',
              style: TextStyle(fontSize: 12, color: AppColors.neutral6)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: tarjeta de atleta
// ---------------------------------------------------------------------------
class _AthleteCard extends StatelessWidget {
  final Athlete athlete;
  const _AthleteCard({required this.athlete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/athlete-profile', arguments: athlete);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar con iniciales
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary10,
              child: Text(
                athlete.name.split(' ').map((w) => w[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              athlete.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '${athlete.flag}  ${athlete.nationality}',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral5),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ClassBadge(classification: athlete.classification),
                _StatusChip(status: athlete.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.accent2),
                  const SizedBox(width: 2),
                  Text(
                    athlete.avgScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                ]),
                Text(
                  athlete.position,
                  style: const TextStyle(fontSize: 10, color: AppColors.neutral5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badges reutilizables
// ---------------------------------------------------------------------------
class _ClassBadge extends StatelessWidget {
  final String classification;
  const _ClassBadge({required this.classification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        classification,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(status)),
      ),
    );
  }
}
