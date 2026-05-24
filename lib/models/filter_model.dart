class FilterModel {
  final List<String> categories;
  final double? minPrice;
  final double? maxPrice;

  const FilterModel({this.categories = const [], this.minPrice, this.maxPrice});

  bool get isEmpty =>
      categories.isEmpty && minPrice == null && maxPrice == null;
}
