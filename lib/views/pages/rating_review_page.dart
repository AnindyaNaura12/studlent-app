import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RatingReviewPage extends StatefulWidget {
  final int idOrder;
  final int idFreelancer;
  final int idService;
  final String freelancerName;
  final String freelancerImage;
  final String serviceName;

  const RatingReviewPage({
    super.key,
    required this.idOrder,
    required this.idFreelancer,
    required this.idService,
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

  static const List<String> _ratingLabels = [
    '',
    'Very Bad',
    'Bad',
    'Neutral',
    'Good',
    'Very Good',
  ];

  double _s(double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (size * (screenWidth / 375)).clamp(size * 0.75, size * 1.3);
  }

  Future<int> _getCurrentClientId() async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;

    if (authUser == null || authUser.email == null || authUser.email!.isEmpty) {
      throw Exception('Logged-in user not found.');
    }

    final userRow = await supabase
        .from('users')
        .select('id_user')
        .eq('email', authUser.email!)
        .maybeSingle();

    if (userRow == null || userRow['id_user'] == null) {
      throw Exception('Client data was not found in users table.');
    }

    return userRow['id_user'] as int;
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      _showSnackBar("Please select a star rating first.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final int currentClientId = await _getCurrentClientId();

      final existing = await supabase
          .from('reviews')
          .select('id_review')
          .eq('id_order', widget.idOrder)
          .limit(1)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('reviews').insert({
          'id_order': widget.idOrder,
          'id_client': currentClientId,
          'id_freelancer': widget.idFreelancer,
          'id_service': widget.idService,
          'rating': _rating,
          'komentar': null,
        });

        final reviewsData = await supabase
            .from('reviews')
            .select('rating')
            .eq('id_service', widget.idService);

        final ratings = (reviewsData as List)
            .map((r) => (r['rating'] as num).toDouble())
            .toList();

        if (ratings.isNotEmpty) {
          final avg = ratings.reduce((a, b) => a + b) / ratings.length;
          final avgRounded = double.parse(avg.toStringAsFixed(1));

          await supabase
              .from('services')
              .update({'rating_avg': avgRounded})
              .eq('id_service', widget.idService);
        }

        final allReviews = await supabase
            .from('reviews')
            .select('rating')
            .eq('id_freelancer', widget.idFreelancer);

        final allRatings = (allReviews as List)
            .map((r) => (r['rating'] as num).toDouble())
            .toList();

        if (allRatings.isNotEmpty) {
          final freelancerAvg =
              allRatings.reduce((a, b) => a + b) / allRatings.length;

          await supabase
              .from('freelancer_profiles')
              .update({
                'rating_avg': double.parse(freelancerAvg.toStringAsFixed(1)),
                'total_rating': allRatings.length,
              })
              .eq('id_user', widget.idFreelancer);
        }
      }

      await supabase
          .from('orders')
          .update({'status': 'selesai'})
          .eq('id_order', widget.idOrder);

      _showSnackBar(
        existing == null
            ? "Rating submitted successfully!"
            : "Order completed successfully!",
        color: Colors.green,
      );

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        _showSnackBar(
          "Database access denied. Please check the reviews policy in Supabase.",
        );
      } else {
        _showSnackBar("Failed to submit rating: ${e.message}");
      }
    } catch (e) {
      _showSnackBar("Failed to submit rating: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(_s(20), _s(8), _s(20), _s(16)),
          child: SizedBox(
            width: double.infinity,
            height: _s(54),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                disabledBackgroundColor: const Color(
                  0xFFFFB74D,
                ).withOpacity(0.7),
                foregroundColor: Colors.black,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_s(32)),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: _s(22),
                      height: _s(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black54,
                        ),
                      ),
                    )
                  : Text(
                      "Submit Rating",
                      style: TextStyle(
                        fontSize: _s(15),
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
              "Ratings",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(_s(16), _s(12), _s(16), _s(32)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFreelancerCard(),
                  SizedBox(height: _s(20)),
                  _buildStarRating(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreelancerCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _s(14), vertical: _s(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: _s(14),
            spreadRadius: 0,
            offset: Offset(0, _s(3)),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_s(10)),
            child: widget.freelancerImage.isNotEmpty
                ? Image.network(
                    widget.freelancerImage,
                    width: _s(52),
                    height: _s(52),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                  )
                : _buildAvatarPlaceholder(),
          ),
          SizedBox(width: _s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.freelancerName,
                  style: TextStyle(
                    fontSize: _s(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _s(3)),
                Text(
                  widget.serviceName,
                  style: TextStyle(
                    fontSize: _s(12),
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

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: _s(52),
      height: _s(52),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(_s(10)),
      ),
      child: Icon(
        Icons.person_rounded,
        color: const Color(0xFFFFA726),
        size: _s(26),
      ),
    );
  }

  Widget _buildStarRating() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _s(20), vertical: _s(22)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_s(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: _s(12),
            spreadRadius: 0,
            offset: Offset(0, _s(3)),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "How was the Service?",
            style: TextStyle(
              fontSize: _s(14),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: _s(18)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isActive = starIndex <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: _s(5)),
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
                      size: _s(46),
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: _s(12)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _rating > 0 ? _ratingLabels[_rating] : 'Tap the star to rate',
              key: ValueKey(_rating),
              style: TextStyle(
                fontSize: _s(12),
                fontWeight: _rating > 0 ? FontWeight.w600 : FontWeight.w400,
                color: _rating > 0 ? const Color(0xFFFFA726) : Colors.grey[400],
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
