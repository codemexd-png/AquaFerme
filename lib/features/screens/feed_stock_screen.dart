import 'package:flutter/material.dart';
import '../../services/api_service.dart';
 
class FeedStockScreen extends StatefulWidget {
  const FeedStockScreen({super.key});
 
  @override
  State<FeedStockScreen> createState() => _FeedStockScreenState();
}
 
class _FeedStockScreenState extends State<FeedStockScreen> {
  late Future<List<dynamic>> _stockFuture;
 
  @override
  void initState() {
    super.initState();
    _stockFuture = ApiService.getFeedStock();
  }
 
  void _refresh() {
    setState(() {
      _stockFuture = ApiService.getFeedStock();
    });
  }
 
  Future<void> _showUpdateDialog(Map<String, dynamic> product) async {
    final controller = TextEditingController(
      text: product['quantity_kg'].toString(),
    );
 
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          product['product_name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouvelle quantité (kg) :',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                suffixText: 'kg',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
 
    if (confirmed == true) {
      final newQty = double.tryParse(controller.text.trim());
      if (newQty == null) return;
 
      try {
        await ApiService.updateFeedStock(
          id: product['id'].toString(),
          quantityKg: newQty,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stock mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          _refresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        title: const Text(
          'Stock Aliments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _stockFuture,
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
                  Text('Erreur : ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            );
          }
 
          final stock = snapshot.data!;
 
          // Sépare les produits en alerte des autres
          final alerts =
              stock.where((p) => _isAlert(p)).toList();
          final normal =
              stock.where((p) => !_isAlert(p)).toList();
 
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Résumé ────────────────────────────────────────────
              Row(
                children: [
                  _SummaryChip(
                    label: '${stock.length} produits',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF0D47A1),
                  ),
                  const SizedBox(width: 10),
                  if (alerts.isNotEmpty)
                    _SummaryChip(
                      label: '${alerts.length} alerte(s)',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                ],
              ),
 
              const SizedBox(height: 20),
 
              // ── Alertes ───────────────────────────────────────────
              if (alerts.isNotEmpty) ...[
                const Text(
                  '⚠️ Stock faible',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 10),
                ...alerts.map((p) => _StockCard(
                      product: p,
                      isAlert: true,
                      onUpdate: () => _showUpdateDialog(p),
                    )),
                const SizedBox(height: 20),
              ],
 
              // ── Stock normal ──────────────────────────────────────
              if (normal.isNotEmpty) ...[
                const Text(
                  'Stock disponible',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...normal.map((p) => _StockCard(
                      product: p,
                      isAlert: false,
                      onUpdate: () => _showUpdateDialog(p),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
 
  bool _isAlert(Map<String, dynamic> product) {
    final qty = double.tryParse(product['quantity_kg'].toString()) ?? 0;
    final threshold =
        double.tryParse(product['alert_threshold_kg'].toString()) ?? 50;
    return qty < threshold;
  }
}
 
// ── Carte produit ─────────────────────────────────────────────────────────────
class _StockCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isAlert;
  final VoidCallback onUpdate;
 
  const _StockCard({
    required this.product,
    required this.isAlert,
    required this.onUpdate,
  });
 
  @override
  Widget build(BuildContext context) {
    final qty = double.tryParse(product['quantity_kg'].toString()) ?? 0;
    final threshold =
        double.tryParse(product['alert_threshold_kg'].toString()) ?? 50;
    final ratio = threshold > 0 ? (qty / threshold).clamp(0.0, 2.0) : 0.0;
 
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isAlert
            ? Border.all(color: Colors.red.shade200, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAlert
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.set_meal,
                  color: isAlert ? Colors.red : const Color(0xFF0D47A1),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['product_name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Seuil d\'alerte : ${threshold.toStringAsFixed(0)} kg',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Badge quantité
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAlert
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAlert ? Colors.red : Colors.green,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${qty.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: isAlert ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
 
          const SizedBox(height: 12),
 
          // Barre de stock
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (ratio / 2).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAlert ? Colors.red : Colors.green,
              ),
            ),
          ),
 
          const SizedBox(height: 12),
 
          // Bouton mise à jour
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Mettre à jour le stock'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D47A1),
                side: const BorderSide(color: Color(0xFF0D47A1)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 
// ── Chip résumé ───────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
 
  const _SummaryChip(
      {required this.label, required this.icon, required this.color});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}