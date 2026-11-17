import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/body_map_widget.dart';

/// Pantalla interactiva del cuerpo humano.
///
/// Permite:
/// - Ver el cuerpo de frente o de espalda (botón para darle la vuelta).
/// - Seleccionar los músculos donde se tiene una molestia (toque interactivo).
/// - Revisar y limpiar la lista de zonas marcadas.
class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  BodyView _view = BodyView.front;

  /// Muestra el contorno de las zonas disponibles para tocar.
  bool _showHints = true;

  /// Músculos seleccionados: id → nombre legible.
  final Map<String, String> _selected = {};

  void _toggleMuscle(MuscleRegion muscle) {
    setState(() {
      if (_selected.containsKey(muscle.id)) {
        _selected.remove(muscle.id);
      } else {
        _selected[muscle.id] = muscle.label;
      }
    });
  }

  void _flip() {
    setState(() {
      _view = _view == BodyView.front ? BodyView.back : BodyView.front;
    });
  }

  void _clear() {
    setState(() => _selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    final isFront = _view == BodyView.front;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Mapa corporal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: _showHints ? 'Ocultar guías' : 'Mostrar guías',
            onPressed: () => setState(() => _showHints = !_showHints),
            icon: Icon(_showHints
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
          ),
          IconButton(
            tooltip: 'Dar la vuelta',
            onPressed: _flip,
            icon: const Icon(Icons.flip_camera_android_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(activeRoute: AppDrawerRoute.mapaCorporal),
      body: SafeArea(
        child: Column(
          children: [
            // ── Selector frente / espalda ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: _ViewToggle(
                isFront: isFront,
                onChanged: (front) {
                  setState(() =>
                      _view = front ? BodyView.front : BodyView.back);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Toca las zonas donde sientes molestia',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral4, fontSize: 13),
              ),
            ),

            // ── Cuerpo interactivo ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: HumanBodyMap(
                  view: _view,
                  selectedMuscles: _selected.keys.toSet(),
                  onMuscleTap: _toggleMuscle,
                  showHints: _showHints,
                ),
              ),
            ),

            // ── Panel de zonas seleccionadas ───────────────────────────
            _SelectedPanel(
              selected: _selected,
              onRemove: (id) => setState(() => _selected.remove(id)),
              onClear: _clear,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _flip,
        icon: const Icon(Icons.flip, color: Colors.white),
        label: Text(
          isFront ? 'Ver espalda' : 'Ver frente',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Interruptor segmentado para alternar entre frente y espalda.
class _ViewToggle extends StatelessWidget {
  final bool isFront;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({required this.isFront, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral8,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _segment('Frente', isFront, () => onChanged(true)),
          _segment('Espalda', !isFront, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : AppColors.neutral3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel inferior con la lista de zonas marcadas.
class _SelectedPanel extends StatelessWidget {
  final Map<String, String> selected;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;

  const _SelectedPanel({
    required this.selected,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Zonas con molestia (${selected.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (selected.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (selected.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Aún no has seleccionado ninguna zona.',
                style: TextStyle(color: AppColors.neutral5),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selected.entries.map((e) {
                    return Chip(
                      backgroundColor: const Color(0x1AE53935),
                      side: const BorderSide(color: Color(0x33E53935)),
                      label: Text(e.value),
                      labelStyle: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      deleteIconColor: const Color(0xFFB71C1C),
                      onDeleted: () => onRemove(e.key),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
