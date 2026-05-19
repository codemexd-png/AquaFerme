// ─── Écran Planning ──────────────────────────────────────────────────────────
// Affiche la liste des tâches via AppProvider (Consumer).
// Deux vues disponibles : vue semaine (navigation par flèches) et toutes les tâches.
// PlanningPage = wrapper Scaffold + BottomNav. PlanningScreen = contenu seul.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../task.dart';
import 'add_task_screen.dart';
import 'screen_shared.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final weekTasks = provider.getTasksForWeek(_selectedWeekStart);
        final allTasks = provider.tasks..sort(
            (a, b) => a.scheduledDate.compareTo(b.scheduledDate));

        return Column(
          children: [
            // Week selector
            Container(
              color: Theme.of(context).colorScheme.primary.withAlpha(13),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _selectedWeekStart = _selectedWeekStart
                          .subtract(const Duration(days: 7));
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Column(
                    children: [
                      Text(
                        'Semaine du',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${DateFormat('dd MMM').format(_selectedWeekStart)} - '
                        '${DateFormat('dd MMM yyyy').format(_selectedWeekStart.add(const Duration(days: 6)))}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _selectedWeekStart =
                          _selectedWeekStart.add(const Duration(days: 7));
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Vue Semaine'),
                Tab(text: 'Toutes les tâches'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vue semaine
                  weekTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune tâche cette semaine',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : _buildWeekView(weekTasks, provider),

                  // Toutes les tâches
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: allTasks.length,
                    itemBuilder: (_, i) =>
                        _TaskCard(task: allTasks[i], provider: provider),
                  ),
                ],
              ),
            ),

            // FAB area
            if (provider.canEnterData || provider.isAdmin)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddTaskScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une tâche'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWeekView(List<Task> tasks, AppProvider provider) {
    final days = List.generate(7, (i) => _selectedWeekStart.add(Duration(days: i)));
    final dayNames = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (_, dayIndex) {
        final day = days[dayIndex];
        final dayTasks = tasks
            .where((t) =>
                t.scheduledDate.day == day.day &&
                t.scheduledDate.month == day.month &&
                t.scheduledDate.year == day.year)
            .toList();

        final isToday = day.day == DateTime.now().day &&
            day.month == DateTime.now().month &&
            day.year == DateTime.now().year;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF0D47A1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dayNames[dayIndex]} ${DateFormat('dd/MM').format(day)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
            if (dayTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  'Pas de tâche',
                  style: TextStyle(
                      color: Colors.grey[400], fontStyle: FontStyle.italic),
                ),
              )
            else
              ...dayTasks.map((t) => _TaskCard(task: t, provider: provider)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

// ─── Carte de tâche ──────────────────────────────────────────────────────────
// Affiche titre, description, statut, assigné et priorité (badge coloré).
// Un appui ouvre un BottomSheet permettant de changer le statut ou supprimer.
class _TaskCard extends StatelessWidget {
  final Task task;
  final AppProvider provider;

  const _TaskCard({required this.task, required this.provider});

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = Colors.red;
        break;
      case TaskPriority.high:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.blue;
        break;
      case TaskPriority.low:
        priorityColor = Colors.grey;
        break;
    }

    Color statusColor;
    IconData statusIcon;
    switch (task.status) {
      case TaskStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle;
        break;
      case TaskStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showTaskActions(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          task.statusLabel,
                          style: TextStyle(fontSize: 11, color: statusColor),
                        ),
                        const SizedBox(width: 8),
                        if (task.assignedTo != null) ...[
                          const Icon(Icons.person, size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            task.assignedTo!,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.priorityLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_circle, color: Colors.blue),
              title: const Text('Marquer en cours'),
              onTap: () {
                provider.updateTaskStatus(task.id, TaskStatus.inProgress);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Marquer terminé'),
              onTap: () {
                provider.updateTaskStatus(task.id, TaskStatus.completed);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text('Annuler'),
              onTap: () {
                provider.updateTaskStatus(task.id, TaskStatus.cancelled);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer'),
              onTap: () {
                provider.deleteTask(task.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page wrapper (Scaffold + AppBar + BottomNav) ─────────────────────────────

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.set_meal, color: Color(0xFF1565C0), size: 26),
            SizedBox(width: 6),
            Text(
              'AquaTrack',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: const PlanningScreen(),
      bottomNavigationBar: const ScreenBottomNav(currentIndex: 3),
    );
  }
}
