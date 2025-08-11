# 1. `initState` vs `didChangeDependencies` vs `didUpdateWidget`

* `initState()` runs once when the `State` is created — initialize controllers, subscriptions.
* `didChangeDependencies()` runs immediately after `initState` and whenever an inherited dependency (e.g., `InheritedWidget`) changes — good for using `MediaQuery`, `Theme.of`, `Provider` values.
* `didUpdateWidget(oldWidget)` runs when the parent rebuilds and supplies a new widget instance for the same `State` object — use to react to changed widget configuration (compare `oldWidget` and `widget`).

# 2. Widget recreation vs `State` reuse

* Flutter may recreate `Widget` instances on every build, but the framework keeps the existing `State` object if the element’s identity/key/type match. `State` is reused unless the element is removed or key/type change; recreating the widget is cheap, recreating the state is not.

# 3. When to make a widget `const` and why

* Use `const` when the widget and all its constructor parameters are compile-time constants. `const` lets Flutter reuse the same widget instance and avoid rebuild work; it short-circuits equality checks and reduces garbage.

# 4. Why `build()` might be called even if nothing changed

* `build()` can be called due to ancestor rebuilds, `setState`, or framework triggers. `build()` is cheap; expensive work should be avoided inside it. Rebuild doesn’t always imply layout/paint changes.

# 5. How Flutter decides to reuse an element

* The element reuse is based on widget **type** and **key**. If the new widget has the same runtimeType and key as the previous widget for that position, the element (and its `State`) is reused.

# 6. Flutter rendering pipeline: layout → paint → compositing

* **Layout**: compute sizes/positions (`performLayout`).
* **Paint**: draw primitives into layers (`paint`).
* **Compositing**: GPU compositing of layers. The compositing stage is what becomes visible on screen.

# 7. How to check if rebuild triggered layout or only paint

* Use DevTools Timeline and `repaint rainbow`/layer borders. If only paint layers light up, it’s paint-only; if layout metrics jump (layout phase time increases), layout occurred. Also `debugProfileBuildsEnabled` / `debugProfilePaintsEnabled`.

# 8. `RepaintBoundary` & `RenderObject` optimizations; when they hurt

* `RepaintBoundary` isolates paint so child repaints don’t repaint the parent. It helps when children repaint frequently. It can hurt if overused because each boundary creates an extra compositing layer (memory + GPU cost).

# 9. `setState` vs `markNeedsBuild` vs `markNeedsLayout` vs `markNeedsPaint`

* `setState` triggers a rebuild of the widget (calls `build`).
* `markNeedsBuild` schedules a build on the `RenderObject`’s element.
* `markNeedsLayout` schedules a layout pass.
* `markNeedsPaint` schedules only paint. Use the most specific one to minimize work.

# 10. Why `ListView.builder` can still perform poorly and fixes

* Poor performance if items do heavy work on build, decode large images on main thread, or layout is expensive (variable heights). Fixes: `itemExtent` or `prototypeItem`, `RepaintBoundary`, pre-decoding images (isolates), and using `cacheExtent` properly.

# 11. `AnimatedBuilder` vs `AnimatedWidget`

* `AnimatedWidget` is a convenience base class where the widget listens to an `Animation`. `AnimatedBuilder` is more flexible: it takes a `child` that doesn’t rebuild and exposes the animation to a builder — better for isolating static subtrees.

# 12. Running multiple animations in sync without `Ticker` leaks

* Use one `AnimationController` as the master and create multiple `Animation` objects via `CurvedAnimation` and `Interval`. Manage controllers in `State` and always `dispose()` them. Prefer `SingleTickerProviderStateMixin` unless you need multiple tickers.

# 13. Causes of animation jank and profiling approach

* Causes: heavy work on main isolate, expensive layout/paint, image decode on UI thread, too many tickers. Profile with Flutter DevTools Timeline, check frame build/ raster times, and use `repaint rainbow`/`performance overlay`.

# 14. `Opacity` vs `FadeTransition`

* `Opacity` can force an offscreen compositing buffer and repaint children; `FadeTransition` uses compositing when possible and is optimized for animation. `Opacity` is fine for static uses; prefer `FadeTransition` for frequent opacity animations.

# 15. Running animation entirely on GPU

* Use `Transform` (matrix transforms), `Opacity` on composited layers, and ensure no Dart-side rebuild logic runs per frame. Pre-rasterize heavy widgets to a layer (`RepaintBoundary`) and animate transforms.

# 16. How `InheritedWidget` propagates changes

* `InheritedWidget` exposes data; when an `InheritedWidget`’s `updateShouldNotify` returns true, dependent elements (those that called `dependOnInheritedWidgetOfExactType`) are marked dirty and rebuild.

# 17. Why `Provider` can cause unintended rebuilds

* `Provider` uses `InheritedWidget` under the hood and will rebuild dependents when the provided value reference changes. If you provide large objects or change object identity frequently, many widgets rebuild. Use selectors (`Selector`, `context.select`) to avoid coarse rebuilds.

# 18. `ValueNotifier` vs `ChangeNotifier` vs `Stream`

* `ValueNotifier`: simple, notifies listeners when value changes — minimal boilerplate.
* `ChangeNotifier`: general, lets multiple fields call `notifyListeners()` — more flexible but coarser.
* `Stream`: asynchronous, supports multiple events and transformation operators — good for async sequences. Use the most appropriate granularity to reduce rebuilds.

# 19. Scoping state updates to part of tree

* Use `InheritedWidget`/`Provider` with narrow scope, `Selector`/`context.select`, or lift small state into localized `StatefulWidget`s so only small subtrees rebuild.

# 20. Calling `setState` after widget disposed

* Calling `setState` after `dispose()` throws an exception (or is ignored). Always guard asynchronous callbacks with `if (!mounted) return;` before calling `setState`.

# 21. Flutter single-threaded UI model

* Dart VM runs event-loop on main isolate for UI. Heavy CPU tasks on main isolate block frames. Use isolates (`compute`, `Isolate.spawn`) to offload CPU-bound work.

# 22. `compute` vs `Isolate.spawn`

* `compute(func, message)` is a simple helper for short-lived tasks — spawns an isolate, runs the function, returns the result. `Isolate.spawn` is low-level for persistent isolates and message ports — use for long-running background workers.

# 23. Why `await Future.delayed` in `build` is bad

* `build` should be synchronous and pure; awaiting inside build breaks the synchronous contract and can cause subtle rebuild loops or unexpected behavior. Schedule side effects in `initState` or `postFrameCallback`.

# 24. Updating UI while doing heavy computation

* Offload heavy computation to isolates; stream partial results back to the main isolate so UI can progressively render. Use `StreamBuilder` or provider pattern to display incremental updates.

# 25. Microtasks vs event tasks in Dart

* Microtasks run before the next event loop iteration (higher priority) — scheduled via `scheduleMicrotask` or `Future.microtask`. Event tasks are queued after microtasks. Use microtasks for short synchronous work; avoid long microtasks that starve UI.

# 26. How Flutter channels work internally

* Platform channels serialize method calls via platform codecs (JSON/Binary) over platform-specific transport. Dart sends messages to host; host replies asynchronously. Frequent synchronous channel calls block the Dart thread waiting for a response.

# 27. Performance implications of many platform channel calls

* Each call serializes/deserializes data and crosses language boundary: expensive if called every frame. Batch calls, reduce frequency, or move to event channels/streams or native-side callbacks.

# 28. Calling native code without `MethodChannel`

* Alternatives: `Platform Views` (embed native UI), `Texture` APIs (share pixel buffers), FFI (dart\:ffi) for calling C libraries directly — use FFI for high-performance native computations.

# 29. Sharing texture data between Flutter and native

* Use `Texture` widgets and `TextureRegistry`/`SurfaceTexture` on Android or `FlutterTexture` on iOS to share GPU-backed buffers efficiently without copying.

# 30. Keeping UI responsive when calling heavy native APIs

* Run heavy native work on background native threads, use callbacks or event channels to update Dart when done; avoid blocking the UI thread on either side.

# 31. Causes of memory leaks in Flutter & detection

* Common leaks: retained listeners (not removed), long-lived `StreamSubscriptions`, large caches, leaked `AnimationController` not disposed, `GlobalKey` misuse. Detect with DevTools memory profiler and heap snapshots (retain cycles, growing allocations).

# 32. Debugging widget rebuild counts

* Use `DevTools`’s Widget rebuild profiler, `debugPrintRebuildDirtyWidgets`, `flutter_test`’s `expect` to assert builds, or wrappers like `RebuildIndicator` during development.

# 33. What is an Element vs Widget vs RenderObject

* **Widget**: immutable configuration.
* **Element**: concrete instance that pairs a widget with a location in the tree and holds `State`.
* **RenderObject**: low-level object that does layout/paint; elements manage render objects for the render tree.

# 34. Debugging GPU vs CPU-bound issues

* Use Flutter DevTools Timeline: CPU-bound shows high build/layout times, GPU-bound shows high raster times. Use `Skia` traces and `profile` builds to pinpoint which stage is expensive.

# 35. Dart GC & retained closures/streams

* Dart GC reclaims unreachable objects. Closures that capture variables or active `StreamSubscriptions` keep references alive; cancel subscriptions and null out references to allow GC.

# 36. `GlobalKey` causing subtree to keep state when moved

* `GlobalKey` preserves element identity across moves; when you move a widget with a `GlobalKey`, Flutter matches by key and reuses the same `State`, which preserves state across different positions.

# 37. Hot reload vs hot restart vs full restart

* **Hot reload**: injects code changes, preserves state where possible.
* **Hot restart**: restarts the Dart VM and resets app state; faster than full rebuild.
* **Full restart**: kills and restarts the app process — all state and native side reset.

# 38. `MediaQuery.of(context)` returning old values after orientation change

* If `MediaQuery.of(context)` is called using a `context` that isn’t under the rebuilt `MediaQuery` (e.g., stored earlier), it can return stale values. Use a context inside `build` or `didChangeDependencies` to get updated values.

# 39. `const` with a mutable object inside

* `const` constructors make the widget instance immutable, but if you pass a mutable object as a parameter (not const), you break the immutability assumption — avoid passing mutable objects to `const` constructors.

# 40. Can `StatefulWidget` be `const`?

* You can declare the `StatefulWidget` constructor `const` if all constructor arguments are compile-time constants. The widget instance is const but the `State` is still mutable — `const` only optimizes the widget instance creation.

---

## **Flashcard Deck – Flutter Interview Keywords**

**1️⃣ Avoiding unnecessary rebuilds**
**Front:** *“How do you prevent widgets from rebuilding unnecessarily?”*
**Back:**

* **Keywords:** Widget Tree vs Element Tree, Keys (ValueKey, ObjectKey), const constructors, Build Scope Minimization
* **Example Line:** “I minimize rebuild scope using const constructors where possible, and assign stable Keys so Flutter can reuse existing Elements.”

---

**2️⃣ Optimizing rendering**
**Front:** *“What if a widget’s repaint is causing performance issues?”*
**Back:**

* **Keywords:** RepaintBoundary, Offscreen Layer Caching, RenderObject
* **Example Line:** “I wrap high-frequency repaint widgets in RepaintBoundary so they don’t invalidate the parent render tree.”

---

**3️⃣ State management strategy**
**Front:** *“How do you decide between Provider, BLoC, or Riverpod?”*
**Back:**

* **Keywords:** Ephemeral State vs App State, Immutable State, BLoC separation (BlocBuilder/BlocListener), Selector pattern
* **Example Line:** “For UI-local state I stick with setState or ValueNotifier, but for shared immutable state I prefer BLoC with selective rebuilds.”

---

**4️⃣ Handling heavy computation**
**Front:** *“How do you process heavy data without freezing the UI?”*
**Back:**

* **Keywords:** Isolates, compute(), Memoization
* **Example Line:** “Large JSON parsing runs in a compute isolate, so the main thread remains under the 16ms frame budget.”

---

**5️⃣ Networking performance**
**Front:** *“How do you optimize network calls in Flutter?”*
**Back:**

* **Keywords:** Debouncing, Throttling, Stream-based Pagination, Lazy Loading
* **Example Line:** “I debounce rapid search queries and use stream-based pagination so the UI renders partial results without blocking.”

---

**6️⃣ Handling jank**
**Front:** *“How do you ensure smooth animations at 60fps?”*
**Back:**

* **Keywords:** Frame Budget (16ms rule), Shader Compilation Jank, Layout Shifts
* **Example Line:** “I precompile shaders with SkSL warm-up and avoid unnecessary layout recalculations during animations.”

---

**7️⃣ Animations**
**Front:** *“When would you use explicit over implicit animations?”*
**Back:**

* **Keywords:** AnimationController, TickerProviderStateMixin, TweenSequence
* **Example Line:** “I use explicit animations when I need timeline control, like chaining multiple Tweens in a TweenSequence.”

---

**8️⃣ Platform-specific code**
**Front:** *“How do you handle platform-specific features?”*
**Back:**

* **Keywords:** Platform Channels, MethodChannel, EventChannel
* **Example Line:** “For native sensors I bridge via MethodChannel, keeping platform code isolated for testability.”

---

**9️⃣ Widget lifecycle**
**Front:** *“What’s the difference between initState and didChangeDependencies?”*
**Back:**

* **Keywords:** initState (one-time init), didChangeDependencies (called on inherited widget changes)
* **Example Line:** “I fetch data in initState, but subscribe to theme or locale changes in didChangeDependencies.”

---

**🔟 Debugging & profiling**
**Front:** *“How do you diagnose performance issues?”*
**Back:**

* **Keywords:** Flutter DevTools, Performance Overlay, Widget Inspector, Timeline view
* **Example Line:** “I start with DevTools’ frame chart, identify long-running frames, then drill down using the Timeline to see expensive builds.”
