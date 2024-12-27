import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/processing/sort_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'product_list_search_state.dart';

class ProductListSearchCubit extends Cubit<ProductListSearchState> {
  ProductListSearchCubit() : super(const ProductListSearchState());

  Future<void> initialize(String? initialSearchText) async {
    emit(state.copyWith(searchText: initialSearchText));

    if (Database().productList.isEmpty) {
      await Database().initialize();
    }

    emit(state.copyWith(
      productList: Database().productList,
      manufacturerList: Database().manufacturerList,
      selectedManufacturerList: Database().manufacturerList,
      selectedCategoryList: CategoryEnum.values.toList(),
    ));

    updateSearchText(state.searchText);
    applyFilters();
  }

  void updateFilter({
    List<CategoryEnum>? selectedCategoryList,
    List<Manufacturer>? selectedManufacturerList,
    String? minPrice,
    String? maxPrice,
  }) {
    emit(state.copyWith(
      selectedCategoryList: selectedCategoryList,
      selectedManufacturerList: selectedManufacturerList,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  void updateSearchText(String? searchText) {
    emit(state.copyWith(searchText: searchText));
  }

  void updateSortOption(SortEnum selectedOption) {
    emit(state.copyWith(selectedOption: selectedOption));
  }

  void applyFilters() {
    final double min = double.tryParse(state.minPrice) ?? 0;
    final double max = double.tryParse(state.maxPrice) ?? double.infinity;

    final filteredProducts = Database().productList.where((product) {
      if (product.price == null) return false;
      
      final matchesSearchText = state.searchText == null || 
          product.productName.toLowerCase().contains(state.searchText!.toLowerCase());
      final matchesCategory = state.selectedCategoryList.contains(product.category);
      final matchesManufacturer = state.selectedManufacturerList.contains(product.manufacturer);
      final matchesPrice = (product.price! >= min) && (product.price! <= max);
      
      return matchesSearchText && matchesCategory && matchesManufacturer && matchesPrice;
    }).toList();

    if (state.selectedOption == SortEnum.bestSeller) {

    } else if (state.selectedOption == SortEnum.lowestPrice) {
      filteredProducts.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (state.selectedOption == SortEnum.highestPrice) {
      filteredProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    }

    emit(state.copyWith(productList: filteredProducts));
  }

  void toggleFavorite(String productId) {
    final updatedFavorites = Set<String>.from(state.favoriteProductIds);
    if (updatedFavorites.contains(productId)) {
      updatedFavorites.remove(productId);
    } else {
      updatedFavorites.add(productId);
    }
    emit(state.copyWith(favoriteProductIds: updatedFavorites));
  }
}