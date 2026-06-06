import 'package:flutter/material.dart';

class RatingReviewPage extends StatefulWidget {
  final int idOrder;
  final int idClient;
  final int idFreelancer;
  final String freelancerName;
  final String freelancerImage;
  final String serviceName;

  const RatingReviewPage({
    super.key,
    required this.idOrder,
    required this.idClient,
    required this.idFreelancer,
    required this.freelancerName,
    required this.freelancerImage,
    required this.serviceName,
  });

  @override
  State<RatingReviewPage> createState() => _RatingReviewPageState();
}

class _RatingReviewPageState extends State<RatingReviewPage> {
  int _rating = 0; 
  bool _isLoading = false;
  final TextEditingController _commentController = TextEditingController();

  static const List<String> _ratingLabels = [
    '', 
    'Very Bad',
    'Bad',
    'Neutral',
    'Good',
    'Very Good',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      _showSnackBar("Pilih rating bintang terlebih dahulu.");
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      _showSnackBar("Komentar tidak boleh kosong.");
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    _showSnackBar("Review submitted successfully!", color: Colors.green[600]);

    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color ?? const Color(0xFFFFA726),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double s(double size) =>
        (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(s(20), s(8), s(20), s(16)),
          child: SizedBox(
            width: double.infinity,
            height: s(54),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                disabledBackgroundColor:
                    const Color(0xFFFFB74D).withOpacity(0.7),
                foregroundColor: Colors.black,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(32)),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: s(22),
                      height: s(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.black54),
                      ),
                    )
                  : Text(
                      "Submit your Review",
                      style: TextStyle(
                        fontSize: s(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFFF8EE),
            elevation: 0,
            pinned: true,
            centerTitle: true, 
            iconTheme: const IconThemeData(color: Colors.black), 
            title: const Text(
              "Reviews and Ratings",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold, 
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(s(16), s(12), s(16), s(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Freelancer info card ──────────────────
                  _buildFreelancerCard(s),

                  SizedBox(height: s(20)),

                  // ── Star rating ───────────────────────────
                  _buildStarRating(s),

                  SizedBox(height: s(20)),

                  // ── Komentar input ────────────────────────
                  _buildCommentInput(s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreelancerCard(double Function(double) s) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: s(14), vertical: s(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: s(14),
            spreadRadius: 0,
            offset: Offset(0, s(3)),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(s(10)),
            child: Image.asset(
              widget.freelancerImage,
              width: s(52),
              height: s(52),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: s(52),
                height: s(52),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(s(10)),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: const Color(0xFFFFA726),
                  size: s(26),
                ),
              ),
            ),
          ),
          SizedBox(width: s(12)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.freelancerName,
                  style: TextStyle(
                    fontSize: s(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: s(3)),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: s(12),
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double Function(double) s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: s(20), vertical: s(22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: s(12),
            spreadRadius: 0,
            offset: Offset(0, s(3)),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "How was the Services?",
            style: TextStyle(
              fontSize: s(14),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.1,
            ),
          ),

          SizedBox(height: s(18)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isActive = starIndex <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: s(5)),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isActive
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: ValueKey('star_${starIndex}_$isActive'),
                      color: isActive
                          ? const Color(0xFFFFB74D)
                          : const Color(0xFFFFD49A),
                      size: s(46),
                    ),
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: s(12)),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _rating > 0
                  ? _ratingLabels[_rating]
                  : 'Tap the star to rate',
              key: ValueKey(_rating),
              style: TextStyle(
                fontSize: s(12),
                fontWeight:
                    _rating > 0 ? FontWeight.w600 : FontWeight.w400,
                color: _rating > 0
                    ? const Color(0xFFFFA726)
                    : Colors.grey[400],
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(double Function(double) s) {
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: s(12),
            spreadRadius: 0,
            offset: Offset(0, s(3)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write your Review",
            style: TextStyle(
              fontSize: s(14),
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 0.1,
            ),
          ),

          SizedBox(height: s(12)),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F4),
              borderRadius: BorderRadius.circular(s(12)),
              border: Border.all(
                color: Colors.grey.withOpacity(0.15),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _commentController,
              maxLines: 5,
              style: TextStyle(
                fontSize: s(13),
                color: Colors.black87,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: "Type here...",
                hintStyle: TextStyle(
                  fontSize: s(13),
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(s(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}