import '../models/freelancer_model.dart';
import '../models/category_model.dart';

class HomeController {
  /// Daftar kategori layanan
  List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        title: 'Website Development',
        iconPath: 'assets/images/categories/website_development.png',
      ),
      CategoryModel(
        title: 'Graphic Design',
        iconPath: 'assets/images/categories/graphic_design.png',
      ),
      CategoryModel(
        title: 'Photography',
        iconPath: 'assets/images/categories/photography.png',
      ),
      CategoryModel(
        title: 'Video Editing',
        iconPath: 'assets/images/categories/video_editing.png',
      ),
      CategoryModel(
        title: 'Image Editing',
        iconPath: 'assets/images/categories/image_editing.png',
      ),
      CategoryModel(
        title: 'Writing & Translation',
        iconPath: 'assets/images/categories/writing_translation.png',
      ),
    ];
  }

  /// Daftar freelancer populer
  List<FreelancerModel> getPopularFreelancers() {
    return [
      FreelancerModel(
        name: 'Carla',
        rating: 4.9,
        reviewCount: 200,
        experience: '3 years of experience.',
        skills: 'Java, CSS',
        university: 'Universitas Brawijaya',
        price: 'Rp. 200.000',
        imagePath: 'assets/images/freelancers/freelancer_1.png',
      ),
      FreelancerModel(
        name: 'Carla',
        rating: 4.9,
        reviewCount: 200,
        experience: '3 years of experience',
        skills: 'Java, CSS',
        university: 'Politeknik Negeri Malang',
        price: 'Rp. 250.000',
        imagePath: 'assets/images/freelancers/freelancer_2.png',
      ),
      FreelancerModel(
        name: 'Reza',
        rating: 4.8,
        reviewCount: 150,
        experience: '2 years of experience',
        skills: 'Python, UI/UX',
        university: 'Universitas Negeri Malang',
        price: 'Rp. 175.000',
        imagePath: 'assets/images/freelancers/freelancer_3.png',
      ),
    ];
  }
}
