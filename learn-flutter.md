# 🏗️ Core Flutter & Dart

### 1️⃣ Explain the widget tree. How does it work in Flutter?

**Widget tree = the structure of UI components** in Flutter — but it’s more than visual — it’s a declarative model of your UI at a point in time.

**Key points:**

* Widgets themselves are *immutable* (they describe UI).
* Flutter has 3 trees under the hood:

  * **Widget Tree** → describes configuration (declared by you).
  * **Element Tree** → instances of widgets, manages the life cycle & state.
  * **RenderObject Tree** → actual objects doing layout, paint, hit-testing.
* **Rebuild mechanism**: when `setState` or state change triggers a rebuild, Flutter compares old/new widget trees:

  * *If same type and key → reuses element/render object.*
  * *If different → discards old and creates new elements/render objects.*
* This mechanism allows **high performance** because Flutter minimizes repainting and layout.

---

### 2️⃣ StatelessWidget vs StatefulWidget — when to use which?

* **StatelessWidget** — when UI does not depend on any mutable state after build.

  * Example: static screens, labels, logos.
  * You provide all data via constructor, no state inside the widget.

* **StatefulWidget** — when UI depends on state that can change during lifetime.

  * Example: toggles, lists with pull to refresh, animations.
  * Uses a separate `State` class that manages state and triggers rebuild.

**Architectural mindset:**
*Use StatelessWidget by default — go Stateful only when really needed → improves readability, testability, performance.*

---

### 3️⃣ What is BuildContext? How is it used?

**BuildContext** is the handle Flutter uses to locate position of a widget in the widget tree → it's the connection point between widget and element tree.

Key functions:

* Used to fetch inherited data (`Theme.of(context)`, `MediaQuery.of(context)`).
* Used to navigate (`Navigator.of(context)`).
* Helps in locating ancestor widgets in tree hierarchy.

**Important**:

* You can’t use `context` from one widget inside async calls after that widget is disposed.
* Be careful with using parent context in builders — always use the correct scope.

---

### 4️⃣ How is Flutter’s rendering pipeline structured?

End-to-end architecture:

1️⃣ **Widget Layer** → build() method → immutable description.
2️⃣ **Element Layer** → keeps element tree, manages widget lifecycle & state.
3️⃣ **RenderObject Layer** → layout, paint, hit testing.
4️⃣ **Layer Tree** → composited layers optimized for GPU.
5️⃣ **SceneBuilder** → final scene sent to Skia engine.
6️⃣ **Platform Surface** → rasterized pixels drawn on screen.

**Rendering is decoupled and asynchronous** — this allows Flutter to hit 60-120 fps on modern devices. You can inject performance diagnostics using `PerformanceOverlay`.

---

### 5️⃣ Hot reload vs hot restart — what’s the difference?

| Hot Reload                   | Hot Restart                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------ |
| Rebuilds widget tree         | Restarts app from `main()`                                                     |
| Preserves app state          | Loses app state                                                                |
| Much faster (sub-second)     | Slower (few seconds)                                                           |
| Good for tweaking UI, styles | Needed when you change global state, static fields, dependency injection setup |

Architect tip: use hot reload as much as possible during active UI dev. For dependency injection reconfig, plugin init changes — hot restart is needed.

---

### 6️⃣ What is Keys in Flutter? When should you use GlobalKey?

**Keys** → identify widgets across rebuilds (esp. when they move in the tree). Without keys, Flutter uses widget type & position to infer identity.

**LocalKey** → simple identity for children of parent widget (ValueKey, UniqueKey).

**GlobalKey** → used when you need:

* One widget instance globally referenced.
* Access State object externally (`globalKey.currentState`).
* Useful for:

  * Forms (`FormState` access)
  * Showing tooltips
  * Accessing child state from parent

**Caution** — GlobalKeys add memory and rebuild overhead — don’t overuse.

---

### 7️⃣ What are Mixins in Dart? Give an example.

Mixin = a way to reuse code across multiple classes without traditional inheritance.

Syntax:

```dart
mixin LoggerMixin {
  void log(String message) {
    print('LOG: $message');
  }
}

class MyWidget with LoggerMixin {
  void doSomething() {
    log('Doing something...');
  }
}
```

**Architectural benefit** → you avoid bloating base classes or misusing inheritance. Composition over inheritance.

---

### 8️⃣ Explain async/await and Future in Dart.

* **Future** → represents a value that will be available later (either success or failure).

  * Example: network call, disk IO, compute-intensive work.

* **async / await** = syntactic sugar:

  * Makes asynchronous code look like synchronous code.
  * `await` suspends execution until Future completes.

Example:

```dart
Future<String> fetchData() async {
  final data = await http.get(...);
  return data.body;
}
```

* **Under the hood** → Dart event loop (microtask queue + event queue) schedules Futures.

**Architectural note**:
If you do heavy compute inside Futures — offload to isolates. Futures run on main isolate → not real threads.

Here are **deep, architectural-level answers** — real-world patterns, not just textbook points:

---
---
---
# ⚙️ State Management

### 1️⃣ Which state management approaches have you used? (setState, Provider, Riverpod, Bloc, etc.)

**setState**

* Simple → good for local, component-level state.
* Tight coupling between UI & logic — avoid for anything beyond simple UIs.

**Provider**

* Minimal boilerplate.
* Good for mid-sized apps → holds shared state, dependency injection.
* Lacks strict separation of business logic — tends to become messy as app grows.

**Riverpod (esp. Riverpod 2.x)**

* Much better dependency injection model.
* Works outside widget tree — easier to test.
* Safer reactivity model vs Provider.
* Scales better — can handle complex business logic cleanly.

**Bloc (flutter\_bloc)**

* Clear separation between UI and business logic (Bloc layer).
* Great for complex apps needing testable flows.
* Built-in handling of streams, side effects (BlocListener, BlocConsumer).
* Slight boilerplate — but scalable.

**GetX, MobX**

* Fast reactive models, but sometimes too magic — prefer to avoid for long-term maintainability unless small projects.

**Summary:**

* I use **setState** for local state.
* **Riverpod** for scalable apps needing injection & clean testability.
* **Bloc** for fintech or enterprise apps — multi-screen, complex flows, strict testability required.

---

### 2️⃣ Bloc vs Provider — which one to pick in a complex app?

**Bloc:**

* Better for **multi-screen, complex business flows**.
* You have defined states & events — formal, predictable state transitions.
* Easy to test.
* Cleaner for large team codebases — promotes clear architecture.

**Provider:**

* Simpler for single-page or smaller apps.
* Gets messy for multi-screen, multi-flow apps — harder to track interactions.
* Lacks enforced patterns — more room for mistakes.

**Architectural decision:**

* For fintech/productivity apps with complex user flows, API chaining, offline/online state → **Bloc wins**.
* For small internal tools, dashboards — **Provider or Riverpod** is faster to develop.

---

### 3️⃣ How do you manage state across multiple screens?

**Patterns I use:**

1️⃣ For **small/simple apps**:

```dart
ChangeNotifierProvider (Provider package) or Riverpod StateProvider.
```

2️⃣ For **mid to large apps**:

```dart
Bloc (Cubit or Bloc) + Repository pattern for API layer.
Shared state flows through Blocs injected via MultiBlocProvider.
```

3️⃣ Special cases:

* **Navigation state** → often separate NavigationBloc.
* **Authentication state** → global AuthBloc or AppBloc to drive app flow (login → home, onboarding, logout).

**Tips:**

* Do not pass state via Navigator arguments — causes tight coupling.
* Use top-level injected state providers or Blocs.

---

### 4️⃣ How do you manage app-wide state?

**Approach:**

1️⃣ Global `AppBloc` or `AppController` (Riverpod Provider):
\- Holds app-wide things: auth state, locale, theme mode.
\- Provided at root of widget tree (MultiProvider or Riverpod root).

2️⃣ Each sub-feature has its own Bloc/Provider:
\- Modular → e.g. OrdersBloc, ProfileBloc, DashboardBloc.

3️⃣ Use a DI (dependency injection) approach:
\- Riverpod for DI is excellent.
\- Or use GetIt + Bloc.

4️⃣ For **non-UI state (caching, persistence, user session)**:
\- Use Repository pattern → inject Repo into Blocs/Providers.

---

**Summary architecture — for a large Flutter app**:

```text
AppBloc (global app state — auth, theme, locale)
|
+-- FeatureBloc1 (e.g. Orders)
|
+-- FeatureBloc2 (e.g. Portfolio)
|
+-- SharedRepo (services: API, local DB)
|
+-- DI (via Riverpod or GetIt)
```

---
---
---

Here’s your **deep, architecture-level breakdown** for the UI/Animation section — real-world usable:

---
# 🎨 UI / Animation

### 1️⃣ How do you make custom widgets?

**Why:** Encapsulation, reusability, testability, visual consistency.

**Patterns:**

* **Composable Widgets** → build from basic widgets (`Container`, `Row`, `Column`, `Padding`, etc.) and package together.

```dart
class MyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const MyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

* **With Inheritance** → extend common base classes when needed (rarely).
* **With Composition + mixins** → more scalable.

**Architectural tips:**

* Avoid deep widget nesting (hard to maintain).
* Extract styles/themes centrally (ThemeData, Design System).
* Parameterize all sizes/colors → testable & customizable.

---

### 2️⃣ How to handle responsive design in Flutter?

**Approaches:**

1️⃣ **MediaQuery.of(context).size**
→ Basic responsiveness (width, height).

2️⃣ **LayoutBuilder**
→ For parent constraints-based responsive widgets.

3️⃣ **OrientationBuilder**
→ Handle portrait vs landscape.

4️⃣ **FractionallySizedBox / Expanded / Flexible**
→ For relative sizing — best to avoid hard-coded px.

5️⃣ **Packages**:

* `flutter_screenutil` → px -> dp converter.
* `responsive_framework` → scale breakpoints.

**Best practice**:

* Build using flexible widgets — avoid “fixed size” Container.
* Centralize breakpoints — don’t scatter `MediaQuery` everywhere.

---

### 3️⃣ What is a CustomPainter?

**CustomPainter** = low-level painting → draw shapes, paths, gradients manually.

**When to use:**

* Complex UIs where no existing widgets suffice.
* Custom charts, graphs, gauges.
* Dynamic effects (waveforms, game UIs).

**How:**
You override `paint(Canvas canvas, Size size)` → use Canvas API to draw.

```dart
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(size.center(Offset.zero), 40, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

Performance tip:

* Mark `shouldRepaint` carefully.
* Wrap in RepaintBoundary to limit redraw area.

---

### 4️⃣ Explain Hero animations.

**Hero animations** = shared element transitions between screens.

**How:**

* Wrap widgets with `Hero` widget, give common `tag`.
* On navigation (push), Flutter transitions element between old → new screen.
* Internally handled by Flutter’s overlay stack.

```dart
Hero(
  tag: 'profile-pic',
  child: Image.network(...),
)
```

**Architectural uses:**

* Profile pic transitions.
* Product → detail screen.
* Onboarding animations.

---

### 5️⃣ How do you optimize complex lists (ListView/GridView)?

**Problem:** ListView/GridView can easily rebuild or overload on big data.

**Optimizations:**

1️⃣ **Use ListView\.builder / GridView\.builder**
→ Builds items lazily — avoids O(N) widget creation.

2️⃣ **Use const constructors where possible** → avoids rebuilds.

3️⃣ **Use keys when lists are reorderable or dynamic**
→ Helps Flutter match widget → element on rebuild.

4️⃣ **Cache images (CachedNetworkImage)** → avoids jank from image loading.

5️⃣ **Wrap in RepaintBoundary**
→ Limits over-painting on scrolling.

6️⃣ **Pagination**
→ Don’t load entire list → fetch on scroll.

---

### 6️⃣ Lazy loading in lists — how would you implement it?

**Approach:**

1️⃣ **Detect end of list**:

* Listen to `ScrollController` — `position.extentAfter < threshold`.

```dart
_scrollController.addListener(() {
  if (_scrollController.position.extentAfter < 300) {
    // Fetch more data
  }
});
```

2️⃣ **Or use ListView\.builder with “loading” footer**:

* Show a spinner or progress indicator at end.
* When visible → trigger load.

3️⃣ **State Management:**

* Track `isLoadingMore` & `hasMoreData`.

4️⃣ **API-side:**

* Implement pagination (offset/limit or cursors).

**Tips:**

* Always debounce scroll events (throttle loadMore triggers).
* Avoid duplicate API calls — track current loading state.

---
---
---

# 📦 Networking & Local Storage

Here’s your **deep, production-grade explanation** of Networking & Local Storage in Flutter — tuned for real-world systems, especially fintech/product-heavy apps:

---

### 1️⃣ How do you make network calls in Flutter?

**At the base**, all network calls in Flutter use `dart:io` or `dart:html` depending on the platform. At app level, we use packages like `http` or `dio`.

**Typical structure (clean code):**

1. **API Service Layer** → handles request/response, logging, headers.
2. **Repository Layer** → abstracted per feature/domain (auth, profile, etc).
3. **Model Layer** → decodes JSON using `fromJson` / `freezed`.

```dart
final response = await http.get(Uri.parse('https://api.com/data'));
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return DataModel.fromJson(data);
}
```

**Best practices:**

* Use `Future` or `async` APIs for clarity.
* Inject services (DI via Riverpod/GetIt).
* Centralize headers, base URL, interceptors.

---

### 2️⃣ Dio vs http — pros and cons

| Feature                  | `http` package      | `dio` package                      |
| ------------------------ | ------------------- | ---------------------------------- |
| Simplicity               | ✅ Very simple       | ❌ More setup needed                |
| Interceptors             | ❌ Not built-in      | ✅ Built-in support                 |
| Cancel tokens            | ❌ Manual workaround | ✅ Native support                   |
| Retry                    | ❌ Manual            | ✅ With plugins (e.g., `dio_retry`) |
| Form data                | ❌ Basic             | ✅ Native support                   |
| Upload/Download Progress | ❌ Not native        | ✅ Native                           |
| Logging                  | ❌ Manual            | ✅ Interceptors/log plugin          |

**TL;DR:**

* `http` → use in small projects or quick POCs.
* `dio` → better for complex APIs, enterprise codebases, error handling, and monitoring.

---

### 3️⃣ How do you handle API errors?

**Centralize error handling in API service layer.**

**Strategy:**

```dart
try {
  final response = await dio.get(...);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    throw NetworkError('Timeout');
  } else if (e.response?.statusCode == 401) {
    throw AuthError('Unauthorized');
  } else {
    throw ServerError('Something went wrong');
  }
}
```

* **Map status codes** → (401 → logout, 403 → forbidden).
* **Retry logic** (exponential backoff) → optional for network failures.
* **UI layer** → catches app-level errors and shows user feedback (SnackBars, dialogs).

**Bonus:** use sealed classes or `Result<T>` style patterns to propagate clean outcomes.

---

### 4️⃣ Local storage: preferences vs database (Hive/SQLite)?

| Use Case          | `SharedPreferences`       | `Hive` / `SQLite`                  |
| ----------------- | ------------------------- | ---------------------------------- |
| Type              | Key-value store           | Structured (DB)                    |
| Ideal for         | Tokens, flags, user prefs | Offline data, complex models       |
| Structure         | Flat, string-keyed        | Hive (NoSQL) / SQLite (Relational) |
| Performance       | ✅ Fast                    | Hive: ✅ fast, SQLite: good         |
| Encryption        | ❌ Manual                  | Hive: ✅ via encryptionBox          |
| Platform overhead | ✅ Lightweight             | SQLite: needs setup, schema        |

**My recommendation:**

* For auth tokens, feature flags → use `SharedPreferences` or `flutter_secure_storage` (see next point).
* For offline-first apps, complex data models → use `Hive` (easy, performant) or `Isar` (newer, indexed).

---

### 5️⃣ How to secure sensitive data in Flutter apps?

**Goal:** Protect tokens, credentials, PII even if app is rooted or reverse engineered.

**Techniques:**

1. **Use flutter\_secure\_storage**

   * Stores data in native encrypted store (Keystore on Android, Keychain on iOS).
   * Use for auth tokens, passwords, session info.

2. **Use encryption for local DBs**

   * Hive: `Hive.openEncryptedBox(...)`.
   * SQLite: use SQLCipher + platform-specific setup.

3. **Obfuscate & minify builds**

   * Dart obfuscation (`--obfuscate --split-debug-info`) in release mode.
   * Makes reverse-engineering harder.

4. **Secure APIs**

   * Add SSL pinning (possible via `dio` or platform-native).
   * Avoid hardcoded API keys — use remote config or native layer.

5. **Session Management**

   * Auto logout on inactivity.
   * Invalidate tokens on root detection (if needed, use plugins like `root_checker`).

---
---
---

# 🚀 Performance

Here’s the **architect-level breakdown** on **Flutter Performance** — practical and interview-strong:

---

### 1️⃣ How do you profile a Flutter app?

**Tooling:**

✅ **DevTools (Flutter Inspector → Performance tab)**

* Tracks frame build times.
* Monitors slow frame jank → target is <16.6 ms/frame (for 60 FPS).
* Frame timeline view → break down build, layout, paint, raster.

✅ **Flutter run --profile / --release**

* Profile build = near production conditions.
* Run on real device → emulator ≠ real-world perf.

✅ **Flutter DevTools → Memory tab**

* Detects leaks, large allocations, GC cycles.

✅ **flutter build appbundle --analyze-size**

* App size profile → find bloat from heavy fonts, images.

**Architect tip:**
Set up CI/CD profiling steps — track perf over releases.

---

### 2️⃣ What are common performance issues in Flutter?

**Hotspots I’ve seen in real apps:**

🚩 **Excessive widget rebuilds**

* setState → entire subtree rebuilds unintentionally.

🚩 **Inefficient Lists**

* ListView without `.builder`
* No caching for images.

🚩 **Overdraw**

* Stack of semi-transparent widgets causing multiple paint layers → GPU bottleneck.

🚩 **Heavy animations**

* Poorly optimized transitions → frame drops.

🚩 **Too many Offstage / Visibility widgets**

* Keep mounted widgets consuming memory even when hidden.

🚩 **Synchronous heavy computation** on main isolate

* Doing parsing, crypto, etc. → must use isolates.

🚩 **Large images unoptimized**

* Loading 4K image for small Image widget.

---

### 3️⃣ How do you reduce widget rebuilds?

**Practical patterns:**

✅ **const constructors**

* Use `const` widgets where possible → compiler avoids rebuild.

✅ **Separate widget subtrees**

* Split heavy sub-widgets into separate StatefulWidgets → localize rebuild.

✅ **Selector (Provider) or BlocSelector**

* Rebuild only the widget that depends on specific state.

✅ **Keys**

* Use keys to preserve widgets during reorder (e.g., lists).

✅ **Avoid rebuilding ListView/GridView unnecessarily**

* Extract list items into stateless widgets.

✅ **Avoid excessive setState**

* Localize setState → do not call on parent when child changes.

---

### 4️⃣ When to use RepaintBoundary?

**RepaintBoundary** → tells Flutter “don’t repaint this widget unless you must.”

**Use cases:**

✅ Complex sub-trees that rarely change
✅ Widgets with static content + animations outside
✅ Expensive widgets inside scrolling lists
✅ Caching image effects or composited layers

**How it works:**
It creates a separate layer → reduces parent → child repaints → lowers GPU usage.

**Architect tip:**
Don’t overuse — too many RepaintBoundary can increase memory.

**How to detect:**
In DevTools → enable “Show paint” → flashing = repaint hotspot → optimize with RepaintBoundary.

---
---
---

# 📱 Platform Integration

Here’s the **architecture-level breakdown** of **Platform Integration** — key area for senior Flutter interviews:

---

### 1️⃣ How do you call native code in Flutter?

**Approach:** via **Platform Channels**.

Why? Flutter is built on Dart & Skia — it needs a bridge to talk to native (Kotlin/Java/Swift/ObjC).

**Ways:**

✅ **MethodChannel** (traditional):

* Call Android/iOS APIs.

```dart
const platform = MethodChannel('my.channel');
final result = await platform.invokeMethod('getBatteryLevel');
```

✅ **EventChannel**

* For continuous streams (sensor events, location, etc).

✅ **BasicMessageChannel**

* For raw data exchange — text, binary.

✅ **FFI (dart\:ffi)**

* If calling C/C++ libraries directly.

✅ **PlatformView**

* Embed native UI views in Flutter tree.

**Architectural notes:**

* Keep platform code in `android/ios` folders — clean separation.
* Use versioned platform channels → avoid breaking changes.
* For complex native work → write a dedicated plugin.

---

### 2️⃣ What is platform channel?

**Platform Channel** = bridge to talk between Dart layer and platform (Java/Kotlin/Swift/ObjC).

* It’s a **binary messenger** — passes messages as PlatformChannelMessages.
* Three types:

  1. **MethodChannel** → request-response.
  2. **EventChannel** → streams.
  3. **BasicMessageChannel** → basic bidirectional.

**How it works under the hood:**

* Uses a **binary codec** (StandardMethodCodec).
* Messages sent over a named channel → Platform Plugin → Platform code responds.

**Best practices:**

* Do NOT bloat Dart with platform logic → isolate in service layer.
* Handle platform failures gracefully.
* Version your channels.

---

### 3️⃣ Handling permissions in Flutter apps?

**How I do it:**

✅ **flutter\_permission\_handler** (community-standard plugin):

* Wraps native runtime permissions.
* Easy cross-platform abstraction.

```dart
var status = await Permission.camera.status;
if (!status.isGranted) {
  await Permission.camera.request();
}
```

✅ **Check permission flow:**

1. Check status.
2. If denied → request.
3. If permanently denied → open app settings.

✅ **Handle platform differences:**

* iOS: add required usage descriptions to Info.plist.
* Android: add permissions to AndroidManifest.xml → handle API-level specifics (runtime vs manifest).

✅ **Architectural tip:**

* Centralize permissions logic — do not scatter across widgets.
* Handle user-friendly fallback if permissions denied (especially for location, camera).

---
---
---

Here is a **deep, architecture-level answer** for **Testing in Flutter** — this is often where 90% of devs give shallow answers. This is how senior engineers and good product companies really want it:

---

### 1️⃣ How do you test Flutter widgets?

**Widget test = unit-test the widget tree in isolation.**

* Runs in memory — no device/emulator needed.
* Uses `testWidgets` from `flutter_test`.

```dart
testWidgets('MyButton shows correct label', (WidgetTester tester) async {
  await tester.pumpWidget(MyButton(label: 'Click Me', onTap: () {}));
  expect(find.text('Click Me'), findsOneWidget);
});
```

**What to test:**
✅ Visual appearance (find text/icon/widget).
✅ State change after interaction (tap, scroll, drag).
✅ Animation state (via pump with duration).
✅ Complex widget logic (switch states, error UI).

**Architectural note:**

* Keep widgets pure (Stateless / minimal Stateful) → easy to test.
* Avoid direct platform calls in widget logic → makes it testable.

---

### 2️⃣ Difference between widget test vs integration test

| Aspect             | Widget Test                    | Integration Test            |
| ------------------ | ------------------------------ | --------------------------- |
| Scope              | Single widget subtree          | Full app                    |
| Speed              | ⚡ Fast (ms to seconds)         | 🐢 Slower (seconds/minutes) |
| Dependencies       | No real device/emulator needed | Needs real device/emulator  |
| What it tests      | UI + state of widget           | UI, navigation, network, DB |
| Real APIs/DB       | ❌ Mock or fake                 | ✅ Real (or mock)            |
| Example frameworks | flutter\_test                  | integration\_test, e2e      |

**Architect tip:**

* Use **Widget Tests** for 80% of coverage — fast feedback.
* **Integration Tests** for final QA (flows, bugs, visual checks).
* Avoid over-relying only on integration tests → expensive in CI.

---

### 3️⃣ How do you mock API responses for testing?

✅ **Mock using dio + dio\_adapter (for Dio apps):**

```dart
final dio = Dio();
dio.httpClientAdapter = MockAdapter()
  ..onGet('/test', (request) => ResponseBody.fromString('{"success":true}', 200));
```

✅ **Mock using Mockito (for repositories):**

```dart
class MockApiService extends Mock implements ApiService {}

final mockApi = MockApiService();
when(() => mockApi.getData()).thenAnswer((_) async => FakeData());
```

✅ **Use fake implementations for repositories:**

* Write a `FakeAuthRepo`, `FakeProductRepo` → used in widget tests.

✅ **Architectural tip:**

* Use Dependency Injection (Riverpod/Provider) → swap real API with mock in tests.
* Never hardcode singletons — makes testing painful.

---

### 4️⃣ How would you setup your app project to make it super easy to test all components independently and together?

**Architecture that enables testability:**

1️⃣ **Separation of layers:**

```text
UI (Widget) Layer → only visuals  
State Management Layer → (Bloc/Cubit/Riverpod) — no API logic  
Repository Layer → pure business logic  
Service Layer → API/DB  
```

2️⃣ **Dependency Injection everywhere:**

* No hard singletons.
* Use Riverpod providers, or GetIt with factory pattern.
* Each test can inject mocks easily.

3️⃣ **Use pure Dart for Business Logic:**

* Avoid putting logic in UI Widgets or State classes.
* Pure classes → testable with `test` package.

4️⃣ **Mock abstractions:**

* Never mock Dio or http directly in upper tests.
* Mock Repository → verify behavior → not wire format.

5️⃣ **Example folder structure:**

```text
/lib
  /features
    /auth
      /data (repo, models)
      /domain (business rules)
      /presentation (widgets)
  /shared
    /services (api_service.dart, storage_service.dart)
    /utils (formatter.dart)
```

6️⃣ **Testing folders:**

```text
/test
  /features
    /auth
      auth_bloc_test.dart
      auth_widget_test.dart
      auth_integration_test.dart
```

**Summary:**

* Separate UI/state/logic → test layers independently.
* Use DI → swap real vs mock easily.
* Build pure business logic → testable without WidgetTest.
* Build fast widget tests → cover flows.
* Keep integration tests minimal but complete.


🎛️ Architecture & DevOps

Here’s the **real-world, architecture-level answer** to 🎛️ Architecture & DevOps — exactly what senior interviewers want:

---

### 1️⃣ How do you structure large-scale Flutter projects?

**For scalable apps:**
👉 Modular, layered, DI-friendly.
👉 Clear separation of **features**, **shared components**, **infra**.

My pattern (inspired by Clean + Modular):

```
lib/
  core/                # Common stuff (network, themes, logging, etc.)
    api/
    database/
    di/
    env/
    error_handling/
    themes/
    utils/

  features/            # Modular by domain/feature
    auth/
      data/
      domain/
      presentation/
    portfolio/
    orders/
    settings/

  shared/              # Common widgets, models
    widgets/
    models/
    mixins/
```

---

### 2️⃣ Folder structure you prefer and why?

**Why this way:**

✅ **Modular features** → easier to test, scale, onboard new devs.
✅ **Domain separation** → UI doesn’t mix with business logic.
✅ **Core vs Shared** → no spaghetti dependencies.
✅ **Flat, predictable** → easy to navigate.

**Key: Avoid this:**

```text
lib/screens/ → bloated with 50+ screens
lib/helpers/ → grab-bag mess
lib/services/ → random stuff
```

---

### 3️⃣ Have you worked with CI/CD for Flutter?

Yes — typical production setup I’ve used (including fintech):

✅ **Azure DevOps / GitHub Actions / Bitrise / GitLab CI**
✅ Builds for: Android (APK, AAB), iOS (IPA)
✅ Support for flavors (dev / qa / prod)
✅ Pipeline steps:

```text
1. Lint → flutter analyze, dart format check
2. Test → unit tests, widget tests
3. Build
    - Android APK / AAB
    - iOS IPA (Mac runner with Xcode)
4. Upload artifacts
    - Firebase App Distribution / Play Store / TestFlight
5. (optional) Version bump
6. (optional) Notify Slack / Teams
```

✅ Caching Flutter SDK & pods for faster builds
✅ Parallelized tests
✅ Flutter version pinned in CI

---

### 4️⃣ How do you manage app versioning?

✅ **Version controlled in pubspec.yaml**

```yaml
version: 2.5.1+203
```

✅ In CI:

* Read from pubspec.yaml
* Inject into build:

  * Android: `versionName` / `versionCode`
  * iOS: `CFBundleShortVersionString` / `CFBundleVersion`

✅ Auto-increment versionCode for builds:

* For each CI build → append build number
* GitHub Actions → use commit SHA or CI run number

✅ For release pipelines:

* Manual version bump + changelog
* Build artifact named like:

```text
app-prod-2.5.1-203.apk
```

---

**Summary**

✅ Scalable architecture = modular features + core separation
✅ Folder structure → predictable, testable
✅ CI/CD → automated build/test/deploy pipelines
✅ Versioning → consistent, automated in CI
