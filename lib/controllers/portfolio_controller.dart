import '../models/portfolio_model.dart';

class PortfolioController {
  final List<String> categories = [
    'UI/UX Design',
    'Web Development',
    'Mobile Development',
    'Graphic Design',
    'Content Writing',
    'Video Editing',
  ];

  final List<PortfolioModel> portfolioList = [];

  void addPortfolio(PortfolioModel portfolio) {
    portfolioList.add(portfolio);
  }
}
