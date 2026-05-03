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
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary(context),
          ),
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

          // Sección: Apariencia
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

          // Sección: Cuenta
          _buildSectionHeader(context, 'Cuenta'),

          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Gestionar notificaciones',
            onTap: () {
              // TODO: Navegar a pantalla de notificaciones
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            subtitle: 'Configuración de privacidad',
            onTap: () {
              // TODO: Navegar a pantalla de privacidad
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.block_outlined,
            title: 'Usuarios bloqueados',
            subtitle: 'Ver usuarios bloqueados',
            onTap: () {
              // TODO: Navegar a pantalla de bloqueados
            },
          ),

          const SizedBox(height: 20),

          // Sección: Soporte
          _buildSectionHeader(context, 'Soporte'),

          _buildSettingTile(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            subtitle: 'Centro de ayuda',
            onTap: () {
              // TODO: Navegar a pantalla de ayuda
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.description_outlined,
            title: 'Términos y condiciones',
            subtitle: 'Leer términos de uso',
            onTap: () {
              // TODO: Navegar a términos
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.policy_outlined,
            title: 'Política de privacidad',
            subtitle: 'Leer política de privacidad',
            onTap: () {
              // TODO: Navegar a política
            },
          ),

          const SizedBox(height: 20),

          // Sección: Sesión
          _buildSectionHeader(context, 'Sesión'),

          _buildSettingTile(
            context,
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta',
            iconColor: Colors.redAccent,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),

          _buildSettingTile(
            context,
            icon: Icons.delete_forever,
            title: 'Eliminar cuenta',
            subtitle: 'Eliminar permanentemente tu cuenta',
            iconColor: Colors.redAccent,
            onTap: () {
              _showDeleteAccountDialog(context);
            },
          ),

          const SizedBox(height: 20),

          // Versión de la app
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
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryPink,
            size: 22,
          ),
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
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary(context),
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary(context),
            ),
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
              // Cerrar sesión con Firebase
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.redAccent),
            ),
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
              // TODO: Implementar eliminación de cuenta
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cuenta eliminada')),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}