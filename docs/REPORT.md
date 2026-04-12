### 1. Introduction

When I started reading the documentation, the task seemed like a lot for a test, but when I read that I could use this project to showcase my skills in future interviews, it seemed very appropriate and I became excited, since having a project that demonstrates my coding abilities, the architecture I use, and how I organize my projects was something I'd been meaning to do.

Choosing clean code with SOLID and TDD principles, using use cases, and organizing the project by features, using `bloc/cubit` for state management, and `getIt` for dependency injection is how I usually work on my projects.

I've been developing projects with Flutter/Dart for six years, and during that time I've experimented with different architectures and state management solutions, but I've concluded that this way of working is an industry standard for developing scalable projects.

### 2. Learning Journey

As mentioned in the introduction, I was highly familiar with the core stack, including the Firebase suite (Firestore, Rules, Auth, and Storage). I reviewed the provided documentation with an open mind, always looking for opportunities to refine my existing knowledge.

The primary new technologies for me in this project were the packages Floor and Retrofit.

#### Floor

My usual preference for local storage is Hive, which feels very natural and familiar when paired with NoSQL solutions like Firestore. Anyway transitioning to Floor's SQLite-based paradigm was simple because the functionality was already integrated to the project. 

#### Retrofit
Historically, I have preferred using Dio directly to handle network requests. I tend to be cautious about relying heavily on packages that depend on code generation (via build_runner), as I believe it can sometimes obscure the underlying implementation and make it slightly harder for new developers to understand the project deeply.

I was familiar with the rest of the technologies, including Firestore, Firestore Rules, Firebase Auth, and Cloud Storage.

### 3. Challenges Faced

The most significant challenge was working with a legacy codebase. The project was initialized two years ago with outdated dependencies, which presented a strategic decision: use FVM to stick to the original environment or modernize the stack.

I chose to update the project to Flutter 3 / Dart 3. This allowed me to:
- **Leverage Modern Dart Features:** I implemented Sealed Classes for the DataState<T> class, improving type safety and making state handling in UI exhaustive and cleaner.
- **Resolve Dependency Conflicts:** While updating, I encountered breaking changes in the Floor package. After evaluating its maintenance status (two years since last update), I successfully migrated/updated the implementation to ensure compatibility with the latest build_runner, ensuring the project remains maintainable.
- **Handle Deprecations:** I updated the Dio implementation, specifically refactoring the error handling logic to align with the latest version's standards.

### 4. Reflection and Future Directions

#### Architectural Improvements
I also had doubts about whether improving the provided project was part of the task, or if I should only focus on developing the missing features. Seeing that the initial project didn't have any tests applied, I decided to proceed with the refactoring, thinking it was another way to demonstrate my skills.
I performed a strategic refactoring to align the project with Clean Architecture and SOLID principles:
- **Dependency Inversion (DIP):** I identified that Dio was being imported directly into the presentation layer (remote_article_state.dart). I resolved this architectural leak by creating a generic Failure class, decoupling the UI from the network client.
- **State Management Best Practices:** I refactored the interaction between the UI and logic. Instead of triggering UI effects (like SnackBars) from functions, I implemented a BlocListener. This ensures a unidirectional data flow and a cleaner separation of concerns.
- **Error display:** Note that the initial project didn't display errors to the user, for example, if articles couldn't be retrieved from the API. I implemented messages in the snack bar for the user whenever they performed actions, so if an error happens the users can notice.
- **Granular UI Components:** I began a refactoring process to extract widgets into a dedicated folder. This reduces file complexity and sets the stage for a reusable component library.
- **Bloc/Cubit:** I believe the provided project uses Bloc to retrieve articles, when, due to its simplicity, it could be a Cubit. I decided to leave it as Bloc anyway, partly due to time constraints and partly because I wasn't sure what new features I would implement in the feed and whether its use would ultimately be worthwhile.

#### UX and Accessibility Decisions
I made a deliberate change to the article feed layout by placing the image above the text. This wasn't just an aesthetic choice but a UX/Accessibility improvement:

- By avoiding a side-by-side layout, the UI remains robust even when users increase their system font size. This ensures the text has enough horizontal space to remain readable without breaking the layout.
- I also implemented a global error-reporting system using SnackBars to ensure the user is always informed of the application's state (e.g., API failures or connectivity issues).

- **Full Theming Implementation:** While I began migrating hardcoded values to a centralized ThemeData, Although a theme was implemented, it wasn't being used. When I work on projects, I never set font sizes or colors in widgets; I always do it through the theme. Widgets should be as clean and simple as possible; I only use hardcoded sizes for icons. Unfortunately, due to lack of time, I couldn't properly implement the theming, but I plan to do so in the coming days.
- **Expanded Test Suite:** I would like to increase the code coverage, specifically adding integration test that I couldnt implement, but plan to do in the nexts days.

### 5. Proof of the project

### 6. Overdelivery


