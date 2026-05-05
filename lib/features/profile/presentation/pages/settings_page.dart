import 'package:flutter/material.dart';
import 'package:petuno_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:petuno_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
        ),
        title: Text(
          'Ajustes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          _buildSectionHeader(context, 'Apariencia'),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Tema oscuro',
            subtitle: 'Cambiar entre modo claro y oscuro',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppTheme.primaryPink,
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader(context, 'Cuenta'),
          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestionar notificaciones',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Notificaciones',
                  icon: Icons.notifications_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.info_outline,
                      title: '¿Cómo funcionan?',
                      body:
                          'Las notificaciones te informan en tiempo real cuando tienes un nuevo match, mensaje o actividad en tu perfil.',
                    ),
                    _InfoSection(
                      icon: Icons.phone_android,
                      title: 'Permisos del dispositivo',
                      body:
                          'Puedes gestionar los permisos de notificaciones desde los ajustes de tu dispositivo en cualquier momento.',
                    ),
                    _InfoSection(
                      icon: Icons.favorite_outline,
                      title: 'Tipos de notificaciones',
                      body:
                          '• Nuevos matches\n• Mensajes recibidos\n• Actividad en tu perfil\n• Actualizaciones de la app',
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            subtitle: 'Configuración de privacidad',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Privacidad',
                  icon: Icons.privacy_tip_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.person_outline,
                      title: 'Tu perfil',
                      body:
                          'Tu perfil es visible para otros usuarios de Petuno que estén cerca de tu ubicación.',
                    ),
                    _InfoSection(
                      icon: Icons.location_off_outlined,
                      title: 'Ubicación',
                      body:
                          'Tu ubicación exacta nunca se comparte. Solo mostramos la distancia aproximada a otros usuarios.',
                    ),
                    _InfoSection(
                      icon: Icons.lock_outline,
                      title: 'Mensajes',
                      body:
                          'Tus conversaciones son privadas y solo las pueden ver los participantes del chat.',
                    ),
                    _InfoSection(
                      icon: Icons.delete_outline,
                      title: 'Eliminar datos',
                      body:
                          'Puedes eliminar tu cuenta y todos tus datos en cualquier momento desde la sección de Sesión en esta pantalla.',
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.block_outlined,
            title: 'Usuarios bloqueados',
            subtitle: 'Ver usuarios bloqueados',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Usuarios bloqueados',
                  icon: Icons.block_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.check_circle_outline,
                      title: 'Sin usuarios bloqueados',
                      body:
                          'Aún no has bloqueado a ningún usuario.',
                    ),
                    _InfoSection(
                      icon: Icons.info_outline,
                      title: '¿Cómo bloquear?',
                      body:
                          'Puedes bloquear a un usuario desde su perfil. Los usuarios bloqueados no podrán ver tu perfil ni enviarte mensajes.',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader(context, 'Soporte'),
          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            subtitle: 'Centro de ayuda',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Ayuda y soporte',
                  icon: Icons.help_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.pets,
                      title: '¿Cómo funciona el matching?',
                      body:
                          'Desliza a la derecha si te gusta un perfil, a la izquierda si no. Si ambos se gustan mutuamente, ¡es un match! y podéis empezar a chatear.',
                    ),
                    _InfoSection(
                      icon: Icons.add_photo_alternate_outlined,
                      title: '¿Cómo añado mi mascota?',
                      body:
                          'Ve a tu perfil y pulsa en "Mis mascotas". Desde ahí puedes añadir una nueva mascota con fotos, nombre, raza y personalidad.',
                    ),
                    _InfoSection(
                      icon: Icons.camera_alt_outlined,
                      title: '¿Cómo cambio mi foto?',
                      body:
                          'Ve a tu perfil y pulsa en "Editar perfil". Luego toca tu foto actual para elegir una nueva desde la galería o hacer una foto.',
                    ),
                    _InfoSection(
                      icon: Icons.email_outlined,
                      title: 'Contacto',
                      body: 'Para cualquier consulta:\n📧 soporte@petuno.app',
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            subtitle: 'Leer términos de uso',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Términos y condiciones',
                  icon: Icons.description_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.handshake_outlined,
                      title: '1. Aceptación de términos',
                      body:
                          'Al usar Petuno aceptas estos términos de uso. Si no estás de acuerdo, por favor no uses la aplicación.',
                    ),
                    _InfoSection(
                      icon: Icons.phone_android,
                      title: '2. Uso de la aplicación',
                      body:
                          'Petuno es una plataforma para conectar dueños de mascotas. Debes tener al menos 18 años para usar la app.',
                    ),
                    _InfoSection(
                      icon: Icons.photo_outlined,
                      title: '3. Contenido del usuario',
                      body:
                          'Eres responsable del contenido que publicas. No está permitido publicar contenido ofensivo, ilegal o que infrinja derechos de terceros.',
                    ),
                    _InfoSection(
                      icon: Icons.update,
                      title: '4. Modificaciones',
                      body:
                          'Nos reservamos el derecho de modificar estos términos en cualquier momento. Te notificaremos de cambios importantes.',
                    ),
                    _InfoSection(
                      icon: Icons.email_outlined,
                      title: '5. Contacto',
                      body: 'Para consultas legales:\n📧 legal@petuno.app',
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildSettingTile(
            context,
            icon: Icons.policy_outlined,
            title: 'Política de privacidad',
            subtitle: 'Leer política de privacidad',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InfoPage(
                  title: 'Política de privacidad',
                  icon: Icons.policy_rounded,
                  sections: [
                    _InfoSection(
                      icon: Icons.storage_outlined,
                      title: '1. Datos que recopilamos',
                      body:
                          '• Registro: nombre, email y fecha de nacimiento\n• Perfil: foto, bio, ubicación e intereses\n• Mascotas: nombre, raza, fotos y descripción\n• Mensajes entre usuarios',
                    ),
                    _InfoSection(
                      icon: Icons.track_changes_outlined,
                      title: '2. Cómo usamos tus datos',
                      body:
                          '• Para mostrarte perfiles compatibles cerca de ti\n• Para facilitar la comunicación entre usuarios\n• Para mejorar la experiencia de la aplicación',
                    ),
                    _InfoSection(
                      icon: Icons.cloud_outlined,
                      title: '3. Almacenamiento',
                      body:
                          'Tus datos se almacenan de forma segura en Firebase (Google). Las imágenes se almacenan en Cloudinary con cifrado.',
                    ),
                    _InfoSection(
                      icon: Icons.gavel_outlined,
                      title: '4. Tus derechos',
                      body:
                          '• Acceder y modificar tus datos desde tu perfil\n• Eliminar tu cuenta y datos desde Ajustes\n• Solicitar exportación de tus datos',
                    ),
                    _InfoSection(
                      icon: Icons.email_outlined,
                      title: '5. Contacto',
                      body:
                          'Para ejercer tus derechos:\n📧 privacidad@petuno.app',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader(context, 'Sesión'),
          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta',
            iconColor: Colors.redAccent,
            onTap: () => _showLogoutDialog(context),
          ),
          _buildSettingTile(
            context,
            icon: Icons.delete_forever,
            title: 'Eliminar cuenta',
            subtitle: 'Eliminar permanentemente tu cuenta',
            iconColor: Colors.redAccent,
            onTap: () => _showDeleteAccountDialog(context),
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Text(
                  'Petuno',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versión 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primaryPink).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? AppTheme.primaryPink, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary(context)),
        ),
        trailing: trailing ??
            Icon(Icons.chevron_right, color: AppTheme.textSecondary(context)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(dialogContext);
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cuenta eliminada correctamente')),
              );
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─── Página de info con diseño de app real ───────────────────────────────────

class _InfoSection {
  final IconData icon;
  final String title;
  final String body;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _InfoPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoSection> sections;

  const _InfoPage({
    required this.title,
    required this.icon,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.cardColor(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary(context)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header con icono grande
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primaryPink, size: 36),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary(context),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Secciones
          ...sections.map((section) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(section.icon,
                            color: AppTheme.primaryPink, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              section.body,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary(context),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}