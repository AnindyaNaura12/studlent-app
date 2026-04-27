import '../models/services_model.dart';
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
  List<ServiceModel> getPopularServices() {
    return [
      ServiceModel(
        id: '1',
        title: 'Java Developer Service',
        name: 'Carla',
        rating: 4.9,
        totalReviews: 200,
        skills: 'Java, CSS',
        university: 'Universitas Brawijaya',
        imagePath: 'assets/images/freelancers/freelancer_1.png',
        // Masukkan data harga ke dalam basicPackage
        basicPackage: PackageModel(
          price: 'Rp. 200.000',
          deliveryTime: '3 days',
        ),
      ),
      ServiceModel(
        id: '2',
        title: 'UI/UX Design',
        name: 'Carla',
        rating: 4.9,
        totalReviews: 200,
        skills: 'Java, CSS',
        university: 'Politeknik Negeri Malang',
        imagePath: 'assets/images/freelancers/freelancer_2.png',
        basicPackage: PackageModel(
          price: 'Rp. 250.000',
          deliveryTime: '3 days',
        ),
      ),
      ServiceModel(
        id: '3',
        title: 'Python UI/UX',
        name: 'Reza',
        rating: 4.8,
        totalReviews: 150,
        skills: 'Python, UI/UX',
        university: 'Universitas Negeri Malang',
        imagePath: 'assets/images/freelancers/freelancer_3.png',
        basicPackage: PackageModel(
          price: 'Rp. 175.000',
          deliveryTime: '3 days',
        ),
      ),
    ];
  }
}
