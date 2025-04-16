import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class Utils {
  static Future<String> imageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decodificar la imagen
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar la imagen a un tamaño más pequeño
      final maxWidth = 640; // Reducido de 800 a 640
      final maxHeight = 640; // Reducido de 800 a 640
      final resizedImage = img.copyResize(
        originalImage,
        width: originalImage.width > maxWidth ? maxWidth : originalImage.width,
        height: originalImage.height > maxHeight ? maxHeight : originalImage.height,
        interpolation: img.Interpolation.linear,
      );

      // Aplicar compresión más agresiva
      // 1. Reducir la calidad a 40%
      final compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 40, // Reducido de 70 a 40
      );
      
      // Verificar el tamaño final
      final finalSizeInKB = compressedBytes.length / 1024;
      if (finalSizeInKB > 200) { // Si la imagen es mayor a 200KB
        // Aplicar compresión adicional
        final moreCompressedImage = img.copyResize(
          resizedImage,
          width: (resizedImage.width * 0.8).round(), // Reducir un 20% más
          height: (resizedImage.height * 0.8).round(),
          interpolation: img.Interpolation.linear,
        );
        
        return base64Encode(img.encodeJpg(
          moreCompressedImage,
          quality: 30, // Calidad aún más baja
        ));
      }
      
      // Convertir a base64
      final String base64Image = base64Encode(compressedBytes);
      return base64Image;
    } catch (e) {
      print('❌ Error al convertir imagen a base64: $e');
      rethrow;
    }
  }

  static Uint8List base64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('❌ Error al convertir base64 a imagen: $e');
      rethrow;
    }
  }
} 