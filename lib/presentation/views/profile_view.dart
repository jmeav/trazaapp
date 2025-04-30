import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trazaapp/data/models/appconfig/appconfig_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            const CircleAvatar(
              radius: 50,
              child: Icon(FontAwesomeIcons.userLarge, size: 50),
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
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: _CarnetWidget(user: user),
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
                    _buildInfoRow(context, FontAwesomeIcons.buildingUser, 'Organización', user.idOrganizacion),
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
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
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
    final fechaEmision = DateTime.now();
    final fechaVencimiento = DateTime(fechaEmision.year + 1, fechaEmision.month, fechaEmision.day);
    final formatoFecha = DateFormat('dd/MM/yyyy');

    return Container(
      width: 320,
      height: 500,
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
          // Fondo semitransparente para mejorar legibilidad
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.0),
            ),
          ),
          // Contenido del carnet
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Texto superior
                  SizedBox(height: 80,),
                  Text(
                    'DIRECCION DE TRAZABILIDAD\nPECUARIA\nHABILITADO DE TRAZABILIDAD BOVINA',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                   const SizedBox(height: 10),
                  // const Spacer(),
                  // // Foto (avatar)
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Nombre y datos
                  Text(
                    user.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    user.cedula,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'HB: ${user.codHabilitado}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'FE: ${formatoFecha.format(fechaEmision)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'FV: ${formatoFecha.format(fechaVencimiento)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  // const Spacer(),
                  // Código QR de validación
                  QrImageView(
                    data: 'https://usuarioactivo.com',
                    version: QrVersions.auto,
                    size:60,
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 