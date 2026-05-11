import 'package:flutter/material.dart';
import '../../controllers/portfolio_controller.dart';
import 'add_portfolio_page.dart';

class PortfolioListPage extends StatefulWidget {
  const PortfolioListPage({super.key});

  @override
  State<PortfolioListPage> createState() => _PortfolioListPageState();
}

class _PortfolioListPageState extends State<PortfolioListPage> {
  final PortfolioController _controller = PortfolioController();
  List<Map<String, dynamic>> _portfolios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _controller.getPortfolios();
    setState(() {
      _portfolios = data;
      _loading = false;
    });
  }

  Future<void> _delete(int idPortfolio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Portfolio?'),
        content: const Text('Portfolio ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _controller.deletePortfolio(idPortfolio);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD59E), Color(0xFFFFF8EE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('My Portfolio',
                        style: TextStyle(fontSize: 17,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _portfolios.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open,
                                  size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text('Belum ada portfolio',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                            : ListView.separated(
                          itemCount: _portfolios.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = _portfolios[index];
                            return _buildCard(p);
                          },
                        ),
                      ),

                      // Add button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddPortfolioPage()),
                              );
                              if (result == true) _load();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB74D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: const Text('+ Add Portfolio',
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: p['thumbnail_url'] != null
                ? Image.network(p['thumbnail_url'],
                width: 70, height: 70, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderThumb())
                : _placeholderThumb(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['judul'] ?? '',
                    style: const TextStyle(fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(p['deskripsi'] ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12,
                        color: Colors.black54)),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddPortfolioPage(existingPortfolio: p),
                    ),
                  );
                  if (result == true) _load();
                },
                child: const Icon(Icons.edit_outlined,
                    color: Color(0xFFCCAA44), size: 22),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _delete(p['id_portfolio']),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 70, height: 70,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}