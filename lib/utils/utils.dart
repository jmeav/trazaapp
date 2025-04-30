import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:io' show gzip;

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
      final maxWidth = 480; // Reducido de 640 a 480
      final maxHeight = 480; // Reducido de 640 a 480
      final resizedImage = img.copyResize(
        originalImage,
        width: originalImage.width > maxWidth ? maxWidth : originalImage.width,
        height: originalImage.height > maxHeight ? maxHeight : originalImage.height,
        interpolation: img.Interpolation.linear,
      );

      // Aplicar compresión más agresiva
      // 1. Reducir la calidad a 25%
      final compressedBytes = img.encodeJpg(
        resizedImage,
        quality: 25, // Reducido de 40 a 25
      );
      
      // Verificar el tamaño final
      final finalSizeInKB = compressedBytes.length / 1024;
      print('📏 Tamaño imagen comprimida: ${finalSizeInKB.toStringAsFixed(2)}KB');
      
      if (finalSizeInKB > 150) { // Si la imagen es mayor a 150KB (antes 200KB)
        // Aplicar compresión adicional
        final moreCompressedImage = img.copyResize(
          resizedImage,
          width: (resizedImage.width * 0.7).round(), // Reducir un 30% más (antes 20%)
          height: (resizedImage.height * 0.7).round(),
          interpolation: img.Interpolation.linear,
        );
        
        final finalBytes = img.encodeJpg(
          moreCompressedImage,
          quality: 20, // Calidad aún más baja (antes 30)
        );
        
        print('📏 Tamaño imagen súper comprimida: ${(finalBytes.length / 1024).toStringAsFixed(2)}KB');
        return base64Encode(finalBytes);
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
  
  // Nueva función para comprimir PDF a base64 con tamaño reducido
  static Future<String?> pdfToCompressedBase64(File pdfFile) async {
    try {
      // Verificar tamaño del archivo original
      final fileSize = await pdfFile.length();
      final fileSizeInMB = fileSize / (1024 * 1024);
      print('📄 Tamaño PDF original: ${fileSizeInMB.toStringAsFixed(2)}MB');
      
      // Si es demasiado grande, rechazar
      if (fileSizeInMB > 8) {
        print('❌ Archivo PDF demasiado grande (${fileSizeInMB.toStringAsFixed(2)}MB)');
        return null;
      }
      
      // Leer bytes del PDF
      final bytes = await pdfFile.readAsBytes();
      
      // Usar gzip para comprimir los bytes
      final List<int> compressed = gzip.encode(bytes);
      final compressedSizeInMB = compressed.length / (1024 * 1024);
      print('📄 Tamaño PDF comprimido: ${compressedSizeInMB.toStringAsFixed(2)}MB');
      
      // Convertir a base64
      final base64String = base64Encode(compressed);
      return base64String;
    } catch (e) {
      print('❌ Error al comprimir PDF: $e');
      return null;
    }
  }
} 