import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/local/models/appconfig/appconfig_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<AppConfig>('appConfig');
    final user = box.get('config');
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: const Center(child: Text('No hay información de usuario.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.foto.isNotEmpty
                  ? CachedNetworkImageProvider(user.foto)
                  : null,
              child: user.foto.isEmpty
                  ? const Icon(FontAwesomeIcons.userLarge, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(user.nombre, style: theme.textTheme.headlineSmall),
            Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),
            const Divider(),

            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Datos Personales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildInfoRow(context, Icons.badge_outlined, 'Cédula', user.cedula),
                        _buildInfoRow(context, Icons.phone_android_outlined, 'Móvil', user.movil),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: FloatingActionButton.small(
                        heroTag: 'carnetBtn',
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: const Text('Carnet de Habilitado'),
                                ),
                                body: Center(
                                  child: SingleChildScrollView(
                                    child: _CarnetWidget(user: user),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.credit_card, size: 22),
                        tooltip: 'Ver Carnet',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Datos de la Aplicación', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, FontAwesomeIcons.buildingUser, 'Organización', user.organizacion),
                    _buildInfoRow(context, FontAwesomeIcons.tags, 'Categoría', user.categoria),
                    _buildInfoRow(context, Icons.vpn_key_outlined, 'Código Habilitado', user.codHabilitado),
                    _buildInfoRow(context, Icons.perm_device_information, 'IMEI', user.imei),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget para mostrar el carnet
class _CarnetWidget extends StatelessWidget {
  final AppConfig user;
  const _CarnetWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    final formatoFecha = DateFormat('dd/MM/yyyy');
    final fechaEmision = user.fechaEmision.isNotEmpty 
        ? DateTime.parse(user.fechaEmision)
        : DateTime.now();
    final fechaVencimiento = user.fechaVencimiento.isNotEmpty
        ? DateTime.parse(user.fechaVencimiento)
        : DateTime(fechaEmision.year + 1, fechaEmision.month, fechaEmision.day);

    // Obtener el tamaño de la pantalla
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.9; // 90% del ancho de la pantalla
    final cardHeight = cardWidth * 1.5; // Proporción 2:3 para el carnet

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/formatcarnet.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.0),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: cardHeight * 0.15),
                  Text(
                    'DIRECCION DE TRAZABILIDAD\nPECUARIA\nHABILITADO DE TRAZABILIDAD BOVINA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cardWidth * 0.04,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.02),
                  CircleAvatar(
                    radius: cardWidth * 0.12,
                    backgroundColor: Colors.white,
                    backgroundImage: user.foto.isNotEmpty
                        ? CachedNetworkImageProvider(user.foto)
                        : null,
                    child: user.foto.isEmpty
                        ? Icon(Icons.person, size: cardWidth * 0.15, color: Colors.grey)
                        : null,
                  ),
                  SizedBox(height: cardHeight * 0.03),
                  Text(
                    user.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cardWidth * 0.04,
                      color: Colors.black
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    user.cedula,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cardWidth * 0.035,
                      color: Colors.black
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: cardHeight * 0.02),
                  Text(
                    'HB: ${user.codHabilitado}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cardWidth * 0.035,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'FE: ${formatoFecha.format(fechaEmision)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: cardWidth * 0.035,
                          color: Colors.black
                        ),
                      ),
                      Text(
                        'FV: ${formatoFecha.format(fechaVencimiento)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: cardWidth * 0.035,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                  QrImageView(
                    data: user.qr.isNotEmpty ? user.qr : 'https://usuarioactivo.com',
                    version: QrVersions.auto,
                    size: cardWidth * 0.20,
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  ),
                  SizedBox(height: cardHeight * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 