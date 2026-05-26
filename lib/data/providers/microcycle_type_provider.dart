import 'package:flutter/foundation.dart';
import '../../core/services/microcycle_type_service.dart';
import '../models/microcycle_type_dto.dart';

/// Provider que gestiona los tipos de microciclo obtenidos desde la API.
///
/// Uso: cargarlo una vez al inicializar el flujo de creación de macrociclo.
class MicrocycleTypeProvider extends ChangeNotifier {
  final MicrocycleTypeService _service = MicrocycleTypeService();

  List<MicrocycleTypeDto> _types = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MicrocycleTypeDto> get types => List.unmodifiable(_types);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTypes => _types.isNotEmpty;

  /// Busca un tipo por su ID.
  MicrocycleTypeDto? findById(String id) {
    try {
      return _types.firstWhere((t) => t.microcycleTypeId == id);
    } catch (_) {
      return null;
    }
  }

  /// Indica si los tipos cargados son los predeterminados (fallback local).
  bool _usingDefaults = false;
  bool get usingDefaults => _usingDefaults;

  /// Carga todos los tipos de microciclo desde la API.
  /// Si ya están cargados, no vuelve a llamar a menos que [force] sea true.
  /// Si la API falla, usa [MicrocycleTypeDto.defaultTypes] como fallback.
  Future<void> loadAll({bool force = false}) async {
    if (_types.isNotEmpty && !force) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getAll();
      if (result != null && result.isNotEmpty) {
        _types = result;
        _usingDefaults = false;
      } else {
        // Fallback a los tipos por defecto
        _types = MicrocycleTypeDto.defaultTypes;
        _usingDefaults = true;
        _errorMessage = null; // No es un error, solo usamos los defaults
        debugPrint('[MicrocycleTypeProvider] API sin datos, usando tipos por defecto.');
      }
    } catch (e) {
      // Si la API falla completamente, usar los defaults
      _types = MicrocycleTypeDto.defaultTypes;
      _usingDefaults = true;
      _errorMessage = null;
      debugPrint('[MicrocycleTypeProvider] loadAll error: $e → usando tipos por defecto.');
    }

    _isLoading = false;
    notifyListeners();
  }
}
