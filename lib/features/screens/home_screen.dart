import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../../widgets/stat_card.dart';
import '../../services/api_service.dart';
import '../task.dart';
import '../../widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getDashboardStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppProvider>();
      provider.checkLocation();
      provider.loadTasks();
    });
  }

  void _refresh() {
    setState(() {
      _statsFuture = ApiService.getDashboardStats();
    });
    context.read<AppProvider>().loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final bool isOnSite = appProvider.isOnSite;
    final bool isLoadingGPS = appProvider.isLoadingLocation;

    // Tâches du jour depuis le provider
    final today = DateTime.now();
    final todayTasks = appProvider.tasks.where((t) {
      return t.scheduledDate.day == today.day &&
          t.scheduledDate.month == today.month &&
          t.scheduledDate.year == today.year;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'D Alimentation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: isLoadingGPS
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isOnSite ? Icons.location_on : Icons.location_off,
                    color: isOnSite ? Colors.greenAccent : Colors.redAccent,
                  ),
          ),
          const SizedBox(width: 4),
          const NotificationBell(iconColor: Colors.white),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isOnSite && !isLoadingGPS) ...[
            _warningGps(),
            const SizedBox(height: 22),
          ],

          // ── Titre de bienvenue ──────────────────────────────────────
          Consumer<AppProvider>(
            builder: (context, provider, _) => Text(
              'Bonjour, ${provider.username ?? ''}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Résumé de votre ferme piscicole',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 22),

          // ── Stats dynamiques ────────────────────────────────────────
          FutureBuilder<Map<String, dynamic>>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SizedBox(
                  height: 80,
                  child: Center(
                    child: TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              final totalFish = data['total_fish']?.toString() ?? '—';
              final activePonds = data['active_ponds']?.toString() ?? '—';
              final totalPonds = data['total_ponds']?.toString() ?? '—';
              final avgOccupation = data['avg_occupation'] != null
                  ? '${data['avg_occupation']}%'
                  : '—';
              final barrageFish = data['barrage_fish']?.toString() ?? '—';

              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.0,
                children: [
                  StatCard(
                    icon: Icons.set_meal,
                    value: totalFish,
                    title: 'Total poissons',
                    color: Colors.blue,
                  ),
                  StatCard(
                    icon: Icons.waves,
                    value: '$activePonds/$totalPonds',
                    title: 'Étangs actifs',
                    color: Colors.teal,
                  ),
                  StatCard(
                    icon: Icons.pie_chart,
                    value: avgOccupation,
                    title: 'Occupation moy.',
                    color: Colors.green,
                  ),
                  StatCard(
                    icon: Icons.water_drop,
                    value: barrageFish,
                    title: 'Barrage',
                    color: Colors.indigo,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 25),

          // ── Tâches du jour ──────────────────────────────────────────
          const Text(
            'Tâches du jour',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (appProvider.isLoadingTasks)
            const Center(child: CircularProgressIndicator())
          else if (todayTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available,
                      color: Colors.grey[400], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Aucune tâche prévue aujourd\'hui',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ...todayTasks.map((task) => _TaskCard(task: task)),

          const SizedBox(height: 25),

          // ── Accès rapide ────────────────────────────────────────────
          const Text(
            'Accès rapide',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.1,
            children: [
              _QuickCard(
                title: 'Étangs A',
                subtitle: '8 étangs • 900 m²',
                color: const Color(0xFF1976D2),
                onTap: () => context.push('/pond-list?category=A'),
              ),
              _QuickCard(
                title: 'Étangs B',
                subtitle: '5 étangs • 600 m²',
                color: const Color(0xFF009688),
                onTap: () => context.push('/pond-list?category=B'),
              ),
              _QuickCard(
                title: 'Étangs C',
                subtitle: '3 étangs • 150 m²',
                color: const Color(0xFF43A047),
                onTap: () => context.push('/pond-list?category=C'),
              ),
              _QuickCard(
                title: 'Étangs D',
                subtitle: '2 étangs • 400 m²',
                color: const Color(0xFF5E35B1),
                onTap: () => context.push('/pond-list?category=D'),
              ),
              _QuickCard(
                title: 'Barrage',
                subtitle: "Suivi du niveau d'eau",
                color: const Color(0xFF1565C0),
                onTap: () => context.push('/dam'),
              ),
              _QuickCard(
                title: 'Stock Aliments',
                subtitle: 'Gérer les produits',
                color: const Color(0xFF00897B),
                onTap: () => context.push('/feed-stock'),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _warningGps() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_off, color: Colors.red),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Vous n'êtes pas sur le site. La saisie de données est désactivée.",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte tâche du jour ───────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (task.priority) {
      case TaskPriority.urgent:
        color = Colors.red;
        break;
      case TaskPriority.high:
        color = Colors.orange;
        break;
      case TaskPriority.medium:
        color = Colors.blue;
        break;
      case TaskPriority.low:
        color = Colors.grey;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.task_alt, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (task.description.isNotEmpty)
                  Text(
                    task.description,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task.priorityLabel,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Carte accès rapide ────────────────────────────────────────────────────────

class _QuickCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.waves, color: Colors.white, size: 24),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
