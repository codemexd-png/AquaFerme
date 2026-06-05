import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getNotifications();
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      setState(() {
        _future = ApiService.getNotifications();
      });
    } catch (_) {}
  }

  Future<void> _markOneRead(String id) async {
    try {
      await ApiService.markNotificationRead(id);
      setState(() {
        _future = ApiService.getNotifications();
      });
    } catch (_) {}
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.length < 16) return '';
    final parts = iso.substring(0, 16).split('T');
    if (parts.length != 2) return iso;
    final d = parts[0].split('-');
    return '${d[2]}/${d[1]}/${d[0]} à ${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text(
              'Tout lire',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.grey, size: 48),
                  const SizedBox(height: 12),
                  Text('Erreur de chargement',
                      style: TextStyle(color: Colors.grey[600])),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _future = ApiService.getNotifications()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final notifs = snapshot.data ?? [];

          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Aucune notification',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = notifs[i];
              final bool isRead = n['is_read'] == true;
              final String message = n['message'] as String? ?? '';
              final String date = _formatDate(n['created_at'] as String?);
              final String id = n['id'].toString();

              return GestureDetector(
                onTap: isRead ? null : () => _markOneRead(id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead ? Colors.white : const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRead
                          ? Colors.grey.shade200
                          : const Color(0xFF0D47A1).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRead
                              ? Colors.transparent
                              : const Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              date,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        const Icon(Icons.circle,
                            size: 8, color: Color(0xFF0D47A1)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
