import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import '../../controllers/home_controller.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final HomeController _controller = HomeController();

  int? _selectedCategoryIndex;
  int? _selectedPriceIndex;

  final List<String> _priceRanges = [
    'Rp 0 - 50.000',
    'Rp 51.000 - 100.000',
    'Rp 101.000 - 150.000',
    'Rp 151.000 - 200.000',
    'Rp 201.000 - 250.000',
    'Rp 251.000 - 300.000',
    'Rp 301.000 - 350.000',
    'Rp 351.000 - 400.000',
    'Rp 401.000 - 450.000',
  ];

  void _reset() {
    setState(() {
      _selectedCategoryIndex = null;
      _selectedPriceIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    final categories = _controller.getCategories();

    return DraggableScrollableSheet(
      // Muncul setengah layar, bisa di-drag sampai 90%
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [

              // ================= DRAG HANDLE =================
              Padding(
                padding: EdgeInsets.only(top: s(12), bottom: s(4)),
                child: Container(
                  width: s(40),
                  height: s(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(s(10)),
                  ),
                ),
              ),

              // ================= HEADER =================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: s(16),
                  vertical: s(8),
                ),
                child: Row(
                  children: [
                    // Back / close button
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: s(22)),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // Title
                    Expanded(
                      child: Text(
                        'Filter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: s(18),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Reset button
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFB74D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= CONTENT =================
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: s(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: s(8)),

                      // ================= SERVICE CATEGORIES =================
                      Text(
                        'Service Categories',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: s(14)),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: s(10),
                          mainAxisSpacing: s(10),
                          childAspectRatio: 1.1,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            category: categories[index],
                            isSelected: _selectedCategoryIndex == index,
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex =
                                    _selectedCategoryIndex == index ? null : index;
                              });
                            },
                          );
                        },
                      ),

                      SizedBox(height: s(28)),

                      // ================= PRICE =================
                      Text(
                        'Price',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      SizedBox(height: s(14)),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: s(10),
                          mainAxisSpacing: s(10),
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _priceRanges.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedPriceIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPriceIndex = isSelected ? null : index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFFFFD8A8), Color(0xFFFFF3E0)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(s(10)),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFF9800) : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.orange.withOpacity(0.4)
                                        : Colors.orange.withOpacity(0.15),
                                    blurRadius: s(8),
                                    offset: Offset(0, s(4)),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: s(4)),
                                  child: Text(
                                    _priceRanges[index],
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: s(9),
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: s(30)),
                    ],
                  ),
                ),
              ),

              // ================= APPLY BUTTON =================
              Padding(
                padding: EdgeInsets.fromLTRB(s(20), s(12), s(20), s(20)),
                child: SizedBox(
                  width: double.infinity,
                  height: s(52),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'categoryIndex': _selectedCategoryIndex,
                        'priceIndex': _selectedPriceIndex,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB74D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(s(30)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: s(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}