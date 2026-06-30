import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/user_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_session.dart';
import '../../../data/providers/session_provider.dart';
import '../../../shared/widgets/profile_image_picker.dart';

/// Pantalla para editar la información personal del usuario
/// (incluida la foto de perfil).
///
/// La foto se envía al backend como string Base64 en el campo `image`
/// del endpoint `PUT /api/User/UpdateUserInfo`.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  /// Imagen seleccionada localmente pendiente de subir.
  XFile? _pickedImage;

  /// URL/Base64 actual mostrado en el avatar (puede provenir de la API).
  String? _currentImage;

  bool _loading = false;
  bool _hydrated = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    final session = context.read<SessionProvider>().session;
    if (session != null) {
      _firstNameCtrl.text = session.firstName;
      _lastNameCtrl.text = session.lastName;
      _emailCtrl.text = session.email;
      _dniCtrl.text = session.dni;
      _addressCtrl.text = session.address ?? '';
      _countryCtrl.text = session.country ?? '';
      _categoryCtrl.text = session.category ?? '';
      _currentImage = session.image;
    }
    _hydrated = true;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _dniCtrl.dispose();
    _addressCtrl.dispose();
    _countryCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  // ── Selección de imagen ──────────────────────────────────────────
  Future<void> _onPickImage() async {
    final file = await ProfileImagePicker.pick(context);
    if (file == null) return;

    // Validación de tamaño (~5 MB tras compresión)
    final size = await ProfileImagePicker.sizeInBytes(file);
    if (size > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen es demasiado grande (máx. 5 MB).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _pickedImage = file);
  }

  void _removePickedImage() {
    setState(() => _pickedImage = null);
  }

  // ── Guardar cambios ──────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    final sessionProvider = context.read<SessionProvider>();
    final session = sessionProvider.session;
    if (session == null) {
      setState(() =>
          _errorMessage = 'Sesión no encontrada. Inicia sesión de nuevo.');
      return;
    }

    String? imageBase64;
    if (_pickedImage != null) {
      try {
        final bytes = await File(_pickedImage!.path).readAsBytes();
        imageBase64 = base64Encode(bytes);
      } catch (_) {
        setState(() =>
            _errorMessage = 'No se pudo procesar la imagen seleccionada.');
        return;
      }
    }

    setState(() => _loading = true);

    final result = await UserService().updateUserInfo(
      userId: session.userId,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      category:
          _categoryCtrl.text.trim().isEmpty ? null : _categoryCtrl.text.trim(),
      image: imageBase64,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      // Actualizamos la sesión localmente para reflejar los cambios sin
      // necesidad de volver a hacer login.
      final data = result['data'];
      String? newImage = _currentImage;
      if (data is Map<String, dynamic>) {
        final apiImage = data['image'];
        if (apiImage is String && apiImage.isNotEmpty) {
          newImage = apiImage;
        } else if (imageBase64 != null) {
          newImage = imageBase64; // fallback al base64 que enviamos
        }
      } else if (imageBase64 != null) {
        newImage = imageBase64;
      }

      await sessionProvider.patchSession(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        dni: _dniCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        category: _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
        image: newImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorMessage =
          result['message'] as String? ?? 'No se pudo actualizar el perfil.');
    }
  }

  // ── UI helpers ───────────────────────────────────────────────────
  InputDecoration _decoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.neutral5, size: 20),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _label(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
        ]),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.error.withAlpha((0.35 * 255).round()),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar con cámara ────────────────────────────────────────────
  Widget _buildAvatar(UserSession? session) {
    ImageProvider? bgImage;
    if (_pickedImage != null) {
      bgImage = FileImage(File(_pickedImage!.path));
    } else if (_currentImage != null && _currentImage!.isNotEmpty) {
      bgImage = _imageProviderFromString(_currentImage!);
    }

    final initials = session != null ? _initials(session) : '?';

    return Center(
      child: SizedBox(
        width: 124,
        height: 124,
        child: Stack(
          children: [
            // Avatar
            Container(
              width: 124,
              height: 124,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: bgImage != null
                    ? DecorationImage(image: bgImage, fit: BoxFit.cover)
                    : null,
              ),
              alignment: Alignment.center,
              child: bgImage == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 38,
                      ),
                    )
                  : null,
            ),
            // Botón quitar imagen pendiente (solo si se ha seleccionado una)
            if (_pickedImage != null)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _removePickedImage,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            // Botón cámara
            Positioned(
              bottom: 0,
              right: 0,
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.white, width: 3),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _onPickImage,
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.photo_camera_rounded,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ImageProvider _imageProviderFromString(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    // Soporta tanto base64 puro como con prefijo data:image/...;base64,
    final base64Str = value.contains(',') ? value.split(',').last : value;
    try {
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return const AssetImage('assets/images/isologo-vertical.png');
    }
  }

  static String _initials(UserSession s) {
    final parts = s.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first
        .substring(0, parts.first.length.clamp(0, 2))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>().session;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).padding.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAvatar(session),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: _onPickImage,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: Text(
                      _pickedImage == null
                          ? 'Cambiar foto de perfil'
                          : 'Elegir otra imagen',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tarjeta del formulario ─────────────────────────
                Material(
                  elevation: 2,
                  shadowColor: AppColors.primary20,
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Nombre'),
                        TextFormField(
                          controller: _firstNameCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            hint: 'Tu nombre',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Introduce tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _label('Apellidos'),
                        TextFormField(
                          controller: _lastNameCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            hint: 'Tus apellidos',
                            prefixIcon: Icons.badge_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Introduce tus apellidos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _label('Correo electrónico'),
                        TextFormField(
                          controller: _emailCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _decoration(
                            hint: 'nombre@correo.com',
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Introduce tu correo';
                            }
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v.trim());
                            if (!ok) return 'Correo no válido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _label('Documento (DNI)'),
                        TextFormField(
                          controller: _dniCtrl,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9\-]')),
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: _decoration(
                            hint: 'Número de documento',
                            prefixIcon: Icons.credit_card_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Introduce tu documento';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _label('País', required: false),
                        TextFormField(
                          controller: _countryCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: _decoration(
                            hint: 'País de residencia',
                            prefixIcon: Icons.public_rounded,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _label('Dirección', required: false),
                        TextFormField(
                          controller: _addressCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: _decoration(
                            hint: 'Calle, ciudad, etc.',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                        if (session?.isAthlete ?? false) ...[
                          const SizedBox(height: 18),
                          _label('Categoría', required: false),
                          TextFormField(
                            controller: _categoryCtrl,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.characters,
                            decoration: _decoration(
                              hint: 'Ej. BC1, BC2, BC3, BC4',
                              prefixIcon: Icons.sports_kabaddi_outlined,
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        if (_errorMessage != null) ...[
                          _errorBanner(_errorMessage!),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.actionPrimaryDefault,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor:
                                  AppColors.actionPrimaryDisabled,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Guardar cambios'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: _loading
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 14, color: AppColors.neutral5),
                    const SizedBox(width: 6),
                    Text(
                      'Tu información viaja cifrada de forma segura.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
