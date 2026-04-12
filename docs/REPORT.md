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

Defining the functional scope presented a unique challenge regarding user roles. The brief highlights the Journalist persona, yet the news feed is a feature typically designed for a General User. To address this, I treated the application as a multi-persona platform, ensuring the data layer could seamlessly handle both local, author-generated content and external API-sourced news for the end reader.

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

#### Initial analysis of tasks and potential improvements: 
Before writing a single line of code, I created the [Benchmarking&Functional_Scope_Definition](Benchmarking_and_Functional_Scope_Definition.md) document to establish a clear picture of the project's requirements and potential.

The document covers three progressive layers of analysis: first, a breakdown of the required functionality; then a brainstorming session of desirable features that could meaningfully enhance the app; and finally, a competitive analysis of two globally recognized news platforms — the New York Times and The Guardian — to validate assumptions and surface patterns worth adopting.

This exercise helped me enter the implementation phase with a well-defined scope and a prioritized sense of what to build, what to defer, and what to prototype.

#### 1. New Features Implemented:

##### 1. Global Error Reporting via SnackBars
The original project did not surface errors to the user (e.g., API failures, connectivity issues). A **global error-reporting system** was implemented using SnackBars, ensuring users are always informed of the application's current state after any action they perform.

##### 2. Test Suite *(In Progress)*
Implementation of Unit and Widget test covering the full project.
Integration tests are planned and will be added in the coming days.

##### 3. Authentication — Firebase Auth with Google Sign-In
Implemented Firebase Authentication to ensure that only logged-in users can create and publish articles, as proposed in the Benchmarking document. To avoid the time cost of building a custom registration and login screen, **Sign in with Google** was adopted as the sole authentication method, providing a seamless and secure onboarding experience without requiring a dedicated auth UI.

##### 4. Author Profile — User Entity & Auto-Registration
Designed an `AuthorEntity` data model to represent registered authors, capturing key fields including display name, biography, profile image, linked articles, total views, and activity timestamps. On every Google Sign-In, the app checks whether the user already exists in the database — if not, a new author record is created automatically. This implements the author identity requirement proposed in the Benchmarking document.

##### 5. Article Creation
Authors can create articles through a dedicated creation screen, with the following capabilities:

- **Category selection** — articles are assigned a category at creation time
- **Draft or Publish** — authors choose whether to save the article as a draft or publish it immediately
- **Image picker** — opens the device gallery to select a photo, as per the project requirements
- **Markdown support** — the article body supports Markdown formatting for subtitles and bullets.
- **Post-creation navigation** — if saved as a draft, the user is redirected to *My Articles*; if published, they are redirected to the home feed where the new article is immediately visible
- **App Bar actions** — the creation screen provides quick access to logout and to the *My Articles* page

##### 6. My Articles Page — Author Profile
A dedicated page where authors can view all of their created articles, with a clear indication of whether each article is **published** or in **draft** status. This implements a basic author profile and article management features proposed in the Benchmarking document.

##### 7. Combined Article Feed
The main feed was extended to display articles from two sources simultaneously: articles fetched from the **News API** and articles published by authors stored in **Firestore**. This delivers a unified reading experience that blends external news with community-created content.

##### 8. Image Caching
Integrated an image caching package to store article images locally after the first load. This reduces redundant network requests, improves scroll performance in the feed, and lowers data consumption for the user.

#### 2. Prototypes Created:

##### 1. Bottom Navigation Bar
Instead of a Floating Action Button to navigate to article creation, a Bottom Navigation Bar would replace it, providing three main destinations:

Feed — the main article feed
My Articles — the author's article management page
Profile — the author's profile page

This structure creates a more intuitive and scalable navigation pattern, and avoids hiding key actions behind a single FAB.

##### 2. Category Drawer Menu
A drawer-style side menu accessible from the main feed's App Bar. When opened, it displays the available article categories. Tapping a category filters the feed to show only articles from that category, following the pattern observed in the competitive benchmarking of the New York Times and The Guardian.

##### 3. Feed Search
A search bar integrated into the drawer menu (see P2), allowing users to search across all articles in the feed — both from the News API and from Firestore-authored content.

##### 4. Article Detail — Author Info & Profile Page
When an article was written by a registered author, the article detail screen displays the author's name and profile image below the article body. Tapping on the author navigates to a dedicated Author Detail Page showing:

Profile photo
Display name
Short biography
A list of the author's published articles

This directly implements the author profile feature proposed in the Benchmarking & Functional Scope Definition document.

##### 5. Related Articles
At the bottom of each article detail screen, a horizontal scrollable list of articles from the same category would be shown, helping users discover related content and increasing session depth. This feature was identified during the analysis of The Guardian.

#### 3. How Can You Improve This:

##### 1. My Articles — Full Article Management
The current My Articles page only displays the list of articles (drafts and published). The planned improvements include:

Edit article — modify title, content, image, and category
Change publication status — toggle between draft and published
Markdown preview — visualize the rendered output before saving
Delete article — permanently remove an article

##### 2. Author Profile Page
A dedicated profile page where the author can view and edit their own information:

Display name
Profile photo
Short biography

This implements the author identity feature proposed in the Benchmarking document and complements the Author Detail Page (P4) that other users would see.

##### 3. Most Read Articles & Read Tracking
A reading tracking system where, if a user spends at least half of the estimated reading time on an article, it is marked as read. This enables:

A feed filter to sort articles by date or by most read
A most read section on each author's profile, showing which of their articles have had the most engagement

##### 4. Estimated Reading Time
Display the estimated reading time for each article directly in the feed, calculated from the article's word count. This feature was consistently observed across both The New York Times and The Guardian during benchmarking and is planned for implementation in the coming days.

##### 5. Article Sharing
Allow users to share an article via a share button in the article detail screen. Full implementation requires:

Deep link routing between pages
Publishing the app to the web or a public environment

This feature was identified during benchmarking of both The New York Times and The Guardian.

##### 6. Text-to-Speech
A button in the article detail screen that reads the article content aloud using the device's text-to-speech engine. This feature was observed in The New York Times during benchmarking and is planned for implementation in the coming days.









