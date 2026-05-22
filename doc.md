# Kisan Market - Code Structure & Architecture Documentation

This document provides a comprehensive overview of the design patterns, folder structure, state management, and dependencies implemented in the **Kisan Market** Flutter application.

## 1. Architectural Pattern: Clean Architecture

The project strictly follows **Clean Architecture** principles. The goal of this architecture is to separate concerns, making the codebase scalable, testable, and independent of external frameworks or UI changes. 

The codebase is divided into three distinct layers:
1. **Domain**: The innermost layer containing pure business logic.
2. **Data**: The layer responsible for fetching and handling data from external sources.
3. **Presentation**: The UI layer that interacts with the user and manages visual state.

---

## 2. Folder Structure Breakdown

```text
lib/
├── core/                       # Core utilities shared across the entire app
│   ├── errors/                 # Standardized exceptions and failures (Failure, ServerException)
│   ├── network/                # Network utilities (e.g., ApiClient)
│   ├── theme/                  # Application theme definitions (Light & Dark modes)
│   └── usecases/               # Base UseCase contract (UseCase<T, Params>)
├── features/
│   └── product/                # Feature-based grouping (The Product Feature)
│       ├── data/               # Data Layer
│       │   ├── data_sources/   # Remote and local data fetchers (ProductRemoteDataSource)
│       │   ├── models/         # Data transfer objects (DTOs) with fromJson/toJson (ProductModel)
│       │   └── repositories/   # Concrete implementations of Domain repositories (ProductRepositoryImpl)
│       ├── domain/             # Domain Layer
│       │   ├── entities/       # Core business objects without framework logic (ProductEntity)
│       │   ├── repositories/   # Abstract contracts defining required data operations (ProductRepository)
│       │   └── usecases/       # Specific business actions (GetProductsUseCase, AddProductUseCase)
│       └── presentation/       # Presentation Layer
│           ├── cubits/         # State management controllers (ProductCubit, ProductState)
│           ├── pages/          # Full screen views (ProductListPage)
│           └── widgets/        # Reusable UI components (ProductCard, AddProductDialog)
├── injection_container.dart    # Dependency Injection setup (GetIt locators)
└── main.dart                   # Application entry point
```

---

## 3. Layer Details

### A. Domain Layer (The Core)
This layer knows **nothing** about Flutter, APIs, or databases. It only contains pure Dart code.
*   **Entities**: Represent the core business objects. `ProductEntity` holds the raw data structure of a product.
*   **Repositories**: Interfaces (`abstract classes`) that define what data operations the app needs (e.g., `getProducts`).
*   **Use Cases**: Classes that orchestrate specific business logic. `GetProductsUseCase` acts as a middleman between the presentation layer and the repository, ensuring that business rules are applied before data is returned.

### B. Data Layer (The Outside World)
This layer handles all communication with external APIs or local databases.
*   **Models**: `ProductModel` extends `ProductEntity` but adds framework-specific logic like JSON serialization (`fromJson`, `toJson`).
*   **Data Sources**: Where the actual API calls happen. `ProductRemoteDataSource` handles fetching the raw data.
*   **Repository Implementation**: `ProductRepositoryImpl` implements the interface defined in the Domain layer. It catches raw exceptions (like `ServerException`) and converts them into safe, functional `Failure` objects using the `dartz` package.

### C. Presentation Layer (The UI)
This layer handles everything the user sees and interacts with.
*   **State Management (Cubit)**: `ProductCubit` holds the UI state (`ProductLoading`, `ProductLoaded`, `ProductError`). It listens to UI events, calls the Domain layer's Use Cases, and emits new states based on the results.
*   **Pages & Widgets**: The visual Flutter components. They are completely passive and only react to the states emitted by the Cubits.

---

## 4. Key Dependencies & Packages

The following essential packages were added to `pubspec.yaml` to support this architecture:

1.  **`flutter_bloc`**: 
    *   **Use**: State management.
    *   **Detail**: Used to implement the Cubit pattern, separating the UI from the business logic.
2.  **`get_it`**: 
    *   **Use**: Dependency Injection.
    *   **Detail**: Used in `injection_container.dart` to instantiate and provide instances of classes (UseCases, Repositories, DataSources) globally, ensuring loose coupling.
3.  **`dartz`**: 
    *   **Use**: Functional programming and error handling.
    *   **Detail**: Provides the `Either<Left, Right>` type. Used in the Domain layer so methods can return either a `Failure` (Left) or the successful data `T` (Right), forcing the UI to handle both outcomes safely.
4.  **`equatable`**: 
    *   **Use**: Object comparison.
    *   **Detail**: Used in States, Entities, and Models to compare objects by their values rather than their memory references, which is critical for BLoC/Cubit to detect state changes.
5.  **`flutter_screenutil`**: 
    *   **Use**: Responsive UI design.
    *   **Detail**: Allows dimensions, fonts, and paddings to scale dynamically based on the device's screen size using extensions like `.w`, `.h`, `.sp`, and `.r`.

---

## 5. Dependency Injection Flow

The app initializes its dependencies sequentially in `main.dart` by calling `di.init()` from `injection_container.dart`.

1.  **Data Sources** are registered first.
2.  **Repositories** are registered next, requiring the Data Sources.
3.  **Use Cases** are registered, requiring the Repositories.
4.  **Cubits** are registered last, requiring the Use Cases.

This ensures that when `ProductCubit` is requested by the UI, it receives a fully configured instance with all its underlying dependencies injected automatically.

---

## 6. How Use Cases Work (Example: GetProductsUseCase)

In Clean Architecture, a **Use Case** represents a single, specific action or "feature" that your app can perform. In this case, the action is "getting products."

Here is the step-by-step flow of how `GetProductsUseCase` works:

### 1. The Input (Params)
```dart
class GetProductsParams {
  final String? category;
  const GetProductsParams({this.category});
}
```
Whenever the UI wants to fetch products, it might want to filter them (e.g., "Grains" or "Fruits"). Instead of passing raw strings directly into the use case, we bundle all the inputs into a single object called `GetProductsParams`. This makes it easy to add more filters later (like `minPrice` or `searchQuery`) without changing the method signature.

### 2. The Dependency (Repository)
```dart
final ProductRepository repository;

GetProductsUseCase(this.repository);
```
The Use Case doesn't know *how* to get the data (it doesn't know about HTTP calls, APIs, or databases). It only knows that it needs a `ProductRepository` to do the actual fetching. When the app starts, `get_it` (Dependency Injection) automatically passes your `ProductRepositoryImpl` into this class.

### 3. The Execution (`call` method)
```dart
@override
Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) {
  return repository.getProducts(category: params.category);
}
```
This is where the magic happens. By naming the method `call`, Dart allows you to execute the class *as if it were a function*. 
It takes the `params` from the UI, extracts the `category`, and asks the repository to fetch the data. 

### How it all connects in the real code (`ProductCubit`)
To truly understand it, you have to look at how it gets used in your `ProductCubit`. When the UI needs to load products, the Cubit does this:

```dart
// 1. The Cubit executes the Use Case just like a function
final result = await getProductsUseCase(
  GetProductsParams(category: 'Grains') // passing the inputs
);

// 2. The Use Case returns an Either (Left = Failure, Right = Success)
result.fold(
  // If it failed, tell the UI to show an error state
  (failure) => emit(ProductError(failure.message)),
  
  // If it succeeded, tell the UI to show the list of products
  (products) => emit(ProductLoaded(products)),
);
```

### Why do we do it this way?
You might wonder, *"Why not just call the repository directly from the Cubit?"*
Right now, `GetProductsUseCase` is just passing data straight through. But imagine later you need to add a business rule: *"Only show products if the user's subscription is active."* 
Instead of cluttering your UI (Cubit) or your database layer (Repository) with that logic, you would put that check directly inside the `call` method of the Use Case. This keeps your business rules isolated and highly testable!
