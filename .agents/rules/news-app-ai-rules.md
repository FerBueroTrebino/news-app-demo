---
trigger: always_on
---

You are an expert in Flutter, Dart, Bloc, Cubit, Freezed  and Firebase.

    Key Principles
    - Follow Clean Code principles always.
    - Write concise, technical Dart code with accurate examples.
    - Use functional and declarative programming patterns where appropriate.
    - Prefer composition over inheritance.
    - Use descriptive variable names with auxiliary verbs (e.g., isLoading, hasError).
    - Structure files: exported widget, subwidgets, helpers, static content, types.
    
    Dart/Flutter
    - Use const constructors for immutable widgets.
    - Leverage Freezed for immutable state classes and unions.
    - Use arrow syntax for simple functions and methods.
    - Prefer expression bodies for one-line getters and setters.
    - Use trailing commas for better formatting and diffs.
    
    Error Handling and Validation
    - Implement error handling in views with SnackBars.
    - Display errors with red color for visibility.
    - Handle empty states within the displaying screen.
    - Manage error handling and loading states within Cubit/Bloc states.
    
    Bloc-Specific Guidelines
    - Use Cubit for managing simple state and Bloc for complex event-driven state management.
    - Extend states with Freezed for immutability.
    - Use descriptive and meaningful event names for Bloc.
    - Handle state transitions and side effects in Bloc's mapEventToState.
    - Prefer context.read() or context.watch() for accessing Cubit/Bloc states in widgets.
    
    Firebase Integration Guidelines
    - Use Firebase Authentication for user sign-in, sign-up, and password management.
    - Integrate Firestore for real-time database interactions with structured and normalized data.
    - Implement Firebase Storage for file uploads and downloads with proper error handling.
    - Handle Firebase exceptions with detailed error messages and appropriate logging.
    - Secure database rules in Firestore and Storage based on user roles and permissions.
    
    Performance Optimization
    - Use const widgets where possible to optimize rebuilds.
    - Implement list view optimizations (e.g., ListView.builder).
    - Use AssetImage for static images and cached_network_image for remote images.
    - Optimize Firebase queries by using indexes and limiting query results.

    Data Fetching Pattern
    - Try-Catch Wrapper: Always wrap the Dio request in a try-catch block.
    - Success Case: If the response status is 200 OK (or relevant success code), return the data wrapped in DataSuccess<T>.
    - Failure Case: In the catch block, ensure the error is captured as a DioException. Return the error wrapped in DataFailed<T>.

    Key Conventions
    1. Optimize for Flutter performance metrics (first meaningful paint, time to interactive).
    2. Prefer stateless widgets:
       - Use BlocBuilder for widgets that depend on Cubit/Bloc state.
       - Use BlocListener for handling side effects, such as navigation or showing dialogs.
    
    UI and Styling
    - Use Flutter's built-in widgets and create custom widgets.
    - Implement responsive design using LayoutBuilder or MediaQuery.
    - Use themes for consistent styling across the app.
    - Use Theme.of(context).textTheme.titleLarge instead of headline6, and headlineSmall instead of headline5 etc.
    
    Model and Database Conventions
    - Include createdAt, updatedAt, and isDeleted fields in Firestore documents.
    - Use Frezzed for models.
    
    Widgets and UI Components
    - Create small, private widget classes instead of methods like Widget _build....
    - Implement RefreshIndicator for pull-to-refresh functionality.
    - In TextFields, set appropriate textCapitalization, keyboardType, and textInputAction.
    - Always include an errorBuilder when using Image.network.
    
    Miscellaneous
    - Use log instead of print for debugging.
    - Use BlocObserver for monitoring state transitions during debugging.
    - Keep lines no longer than 80 characters, adding commas before closing brackets for multi-parameter functions.
    - Use @JsonValue(int) for enums that go to the database.
    
    Code Generation
    - Utilize build_runner for generating code from annotations (Freezed, JSON serialization).
    - Run flutter pub run build_runner build --delete-conflicting-outputs after modifying annotated classes.
    
    Documentation
    - Document complex logic and non-obvious code decisions.
    - Follow official Flutter, Bloc, and Firebase documentation for best practices.
    
    Refer to Flutter, Bloc, and Firebase documentation for Widgets, State Management, and Backend Integration best practices.