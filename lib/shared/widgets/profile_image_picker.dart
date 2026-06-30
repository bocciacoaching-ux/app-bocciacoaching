import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';

/// Helper centralizado para que el usuario seleccione una imagen de perfil
/// desde la **cámara** o la **galería**, con un bottom sheet consistente
/// con el sistema de diseño de la app.
///
/// La imagen se devuelve como un objeto [XFile] (referencia al archivo
/// temporal) listo para ser leído como bytes y enviado a la API.
abstract final class ProfileImagePicker {
  static final ImagePicker _picker = ImagePicker();

  /// Muestra un bottom sheet con las opciones disponibles y devuelve la
  /// imagen seleccionada, o `null` si el usuario cancela / hay error.
  ///
  /// La imagen se comprime automáticamente (máx. 1024px, calidad 80) para
  /// reducir el tamaño antes de enviarla a la API.
  static Future<XFile?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) => const _SourcePickerSheet(),
    );

    if (source == null) return null;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      return picked;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo acceder a la imagen: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }
  }

  /// Devuelve el tamaño en bytes del archivo seleccionado (útil para
  /// validar antes de subir).
  static Future<int> sizeInBytes(XFile file) async {
    return File(file.path).length();
  }
}

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      margin: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle visual
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto de perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Selecciona el origen de la imagen',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _SourceOption(
                icon: Icons.photo_camera_rounded,
                title: 'Tomar foto',
                subtitle: 'Usa la cámara del dispositivo',
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 10),
              _SourceOption(
                icon: Icons.photo_library_rounded,
                title: 'Elegir de la galería',
                subtitle: 'Selecciona una foto existente',
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: AppColors.textSecondary,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.neutral9,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral8),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.neutral5,
            ),
          ],
        ),
      ),
    );
  }
}
