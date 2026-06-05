import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../features/screens/notifications_screen.dart';

/// Icône cloche avec badge de notifications non lues.
/// Usage : dans n'importe quel AppBar → actions: [const NotificationBell()]
class NotificationBell extends StatefulWidget {
  /// Couleur de l'icône (blanc pour AppBar sombre, noir pour AppBar clair)
  final Color iconColor;

  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifs = await ApiService.getNotifications();
      final count = notifs.where((n) => n['is_read'] == false).length;
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: widget.iconColor),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            // Rafraîchit le badge au retour
            _loadUnreadCount();
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
