import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category});
  Future<ProductModel> addProduct(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  // In-memory mock list for demo / offline capability
  final List<ProductModel> _mockProducts = [
    const ProductModel(
      id: '1',
      name: 'Premium Basmati Rice',
      pricePerKg: 95.0,
      quantityAvailable: 450.0,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=400',
      farmerName: 'Sardar Baldev Singh',
      location: 'Amritsar, Punjab',
      category: 'Grains',
      rating: 4.9,
    ),
    const ProductModel(
      id: '2',
      name: 'Organic Alphanso Mangoes',
      pricePerKg: 180.0,
      quantityAvailable: 120.0,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?q=80&w=400',
      farmerName: 'Ramesh Patil',
      location: 'Ratnagiri, Maharashtra',
      category: 'Fruits',
      rating: 4.8,
    ),
    const ProductModel(
      id: '3',
      name: 'Fresh Farm Tomatoes',
      pricePerKg: 35.0,
      quantityAvailable: 300.0,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?q=80&w=400',
      farmerName: 'Anil Deshmukh',
      location: 'Nashik, Maharashtra',
      category: 'Vegetables',
      rating: 4.6,
    ),
    const ProductModel(
      id: '4',
      name: 'Golden Blossom Honey',
      pricePerKg: 450.0,
      quantityAvailable: 50.0,
      unit: 'bottle',
      imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=400',
      farmerName: 'Vasudevan Nair',
      location: 'Wayanad, Kerala',
      category: 'Organic',
      rating: 5.0,
    ),
    const ProductModel(
      id: '5',
      name: 'Premium Wheat (Kanak)',
      pricePerKg: 42.0,
      quantityAvailable: 1000.0,
      unit: 'kg',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?q=80&w=400',
      farmerName: 'Gurpreet Singh',
      location: 'Ludhiana, Punjab',
      category: 'Grains',
      rating: 4.7,
    ),
  ];

  @override
  Future<List<ProductModel>> getProducts({String? category}) async {
    try {
      // For testing clean architecture with real networking:
      // final response = await apiClient.get(ApiEndpoints.products, queryParameters: category != null ? {'category': category} : null);
      // final list = response.data as List;
      // return list.map((e) => ProductModel.fromJson(e)).toList();

      // Mock delay to demonstrate premium shimmer UI and state changes:
      await Future.delayed(const Duration(milliseconds: 1200));

      if (category == null || category.isEmpty || category == 'All') {
        return _mockProducts;
      }
      return _mockProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch products from server');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      // Simulating post request
      // final response = await apiClient.post(ApiEndpoints.products, data: product.toJson());
      // return ProductModel.fromJson(response.data);

      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Simulate adding to local memory
      final newProduct = ProductModel(
        id: (double.parse(_mockProducts.last.id) + 1).toInt().toString(),
        name: product.name,
        pricePerKg: product.pricePerKg,
        quantityAvailable: product.quantityAvailable,
        unit: product.unit,
        imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?q=80&w=400',
        farmerName: product.farmerName.isNotEmpty ? product.farmerName : 'Self',
        location: product.location.isNotEmpty ? product.location : 'My Farm',
        category: product.category,
        rating: 5.0,
      );
      _mockProducts.add(newProduct);
      return newProduct;
    } catch (e) {
      throw ServerException(message: 'Failed to add product');
    }
  }
}
