# ✅ Dart Cheatsheet for Coding Interviews

A concise, high-signal reference for Dart syntax, collections, algorithms, and interview patterns. Optimized for speed and clarity during interviews.

---

## 📌 1. List (Array) Operations

```dart
List<int> nums = [1, 2, 3];

nums.add(4);               // Add to end
nums.insert(1, 99);        // Insert at index
nums.remove(2);            // Remove first occurrence
nums.removeAt(0);          // Remove at index
nums.removeLast();         // Pop last
nums.clear();              // Clear all

int last = nums.last;
int first = nums.first;

nums.contains(3);
nums.isEmpty;
nums.isNotEmpty;

nums.sort();               // Ascending
nums.reversed.toList();    // Reverse
nums.shuffle();            // Randomize
```

---

## 📌 2. Set (Unique Elements)

```dart
Set<int> seen = {1, 2, 3};

seen.add(4);
seen.remove(2);
seen.contains(1);
```

---

## 📌 3. Map (Hash Table)

```dart
Map<String, int> freq = {'a': 1, 'b': 2};

freq['c'] = 3;
freq['a'] = freq['a']! + 1;

freq.containsKey('b');
freq.containsValue(2);

freq.remove('a');
freq.clear();

freq.forEach((k, v) => print('$k → $v'));
```

---

## 📌 4. String Operations

```dart
String s = "dart";

s.length;
s[0];
s.substring(1, 3);
s.contains("ar");
s.indexOf("r");
s.split("");              // ['d','a','r','t']
s.toUpperCase();
s.toLowerCase();
s.replaceAll("a", "x");

StringBuffer sb = StringBuffer();
sb.write("a");
sb.write("b");
String finalStr = sb.toString();
```

---

## 📌 5. Common Utilities

```dart
List.generate(5, (i) => i * i);   // [0, 1, 4, 9, 16]

List<int> filtered = nums.where((x) => x > 1).toList();
List<String> strList = nums.map((x) => '$x').toList();

int sum = nums.reduce((a, b) => a + b);
int product = nums.fold(1, (a, b) => a * b);
```

---

## 📌 6. Stack & Queue

### Stack (LIFO)

```dart
List<int> stack = [];

stack.add(1);         // push
int top = stack.last;
int popped = stack.removeLast(); // pop
```

### Queue (FIFO)

```dart
List<int> queue = [];

queue.add(1);         // enqueue
int front = queue.first;
int removed = queue.removeAt(0); // dequeue
```

---

## 📌 7. Custom Object Sorting

```dart
class Person {
  String name;
  int age;
  Person(this.name, this.age);
}

List<Person> people = [
  Person('Alice', 30),
  Person('Bob', 25),
];

people.sort((a, b) => a.age.compareTo(b.age));
```

---

## 📌 8. Math Utilities

```dart
import 'dart:math';

max(5, 10);
min(3, -1);
pow(2, 3);        // 8.0
sqrt(16);         // 4.0
```

---

## 📌 9. Indexed Loops

```dart
for (int i = 0; i < nums.length; i++) {
  print('Index $i → ${nums[i]}');
}

for (var entry in nums.asMap().entries) {
  print('Index ${entry.key} → ${entry.value}');
}
```

---

## 📌 10. Edge Case Checks

```dart
if (s.isEmpty || s.length % 2 != 0) return false;
if (!map.containsKey(key)) return false;
if (index < 0 || index >= list.length) return false;
```

---

## 📌 11. Null Safety

```dart
String? nullableStr;
nullableStr ??= "default";

int? x;
int y = x ?? 0;

String? str;
print(str?.length); // null-safe access
```

---

## 📌 12. Interview Templates

### ✅ Two Sum (HashMap)

```dart
Map<int, int> seen = {};
for (int i = 0; i < nums.length; i++) {
  int complement = target - nums[i];
  if (seen.containsKey(complement)) {
    return [seen[complement]!, i];
  }
  seen[nums[i]] = i;
}
```

### ✅ Valid Parentheses (Stack)

```dart
List<String> stack = [];
Map<String, String> pairs = {'(': ')', '[': ']', '{': '}'};

for (var ch in s.split('')) {
  if (pairs.containsKey(ch)) {
    stack.add(ch);
  } else {
    if (stack.isEmpty || pairs[stack.removeLast()] != ch) return false;
  }
}
return stack.isEmpty;
```

### ✅ Frequency Counter

```dart
Map<String, int> freq = {};
for (var ch in s.split('')) {
  freq.update(ch, (v) => v + 1, ifAbsent: () => 1);
}
```

### ✅ Two Pointers Template

```dart
int left = 0, right = nums.length - 1;

while (left < right) {
  int sum = nums[left] + nums[right];
  if (sum == target) {
    // Found
  } else if (sum < target) {
    left++;
  } else {
    right--;
  }
}
```

## 📌 13. Sliding Window (Fixed & Variable Length)

### ✅ Fixed-Length Window (e.g., max sum of subarray size k)

```dart
int maxSum(List<int> nums, int k) {
  int windowSum = 0;
  int maxSum = 0;

  for (int i = 0; i < k; i++) {
    windowSum += nums[i];
  }
  maxSum = windowSum;

  for (int i = k; i < nums.length; i++) {
    windowSum += nums[i] - nums[i - k];
    maxSum = max(maxSum, windowSum);
  }

  return maxSum;
}
```

### ✅ Variable-Length Window (e.g., smallest subarray ≥ target sum)

```dart
int minSubArrayLen(int target, List<int> nums) {
  int left = 0, sum = 0, minLen = nums.length + 1;

  for (int right = 0; right < nums.length; right++) {
    sum += nums[right];

    while (sum >= target) {
      minLen = min(minLen, right - left + 1);
      sum -= nums[left++];
    }
  }

  return minLen == nums.length + 1 ? 0 : minLen;
}
```

---

## 📌 14. Recursion Patterns

### ✅ Basic Recursion Template

```dart
void recurse(int i) {
  if (i == 0) return;         // base case
  recurse(i - 1);             // recursive call
}
```

### ✅ Factorial

```dart
int factorial(int n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}
```

### ✅ Fibonacci (without memoization)

```dart
int fib(int n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}
```

### ✅ Fibonacci (with memoization)

```dart
Map<int, int> memo = {};

int fib(int n) {
  if (n <= 1) return n;
  if (memo.containsKey(n)) return memo[n]!;
  memo[n] = fib(n - 1) + fib(n - 2);
  return memo[n]!;
}
```

### ✅ Backtracking Skeleton

```dart
void backtrack(List<int> current, List<int> choices) {
  if (someCondition(current)) {
    result.add([...current]);     // copy if valid
    return;
  }

  for (var choice in choices) {
    if (isValid(choice)) {
      current.add(choice);
      backtrack(current, choices);
      current.removeLast();       // undo move
    }
  }
}
```

#### 1. **Binary Search Template**

Frequently needed in search-related problems:

```dart
int binarySearch(List<int> nums, int target) {
  int left = 0, right = nums.length - 1;
  while (left <= right) {
    int mid = left + (right - left) ~/ 2;
    if (nums[mid] == target) return mid;
    if (nums[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return -1;
}
```

#### 2. **DFS/BFS (Graph/Tree Style)**

Good for tree/graph or matrix traversal problems:

```dart
void dfs(int node, Set<int> visited, Map<int, List<int>> graph) {
  if (visited.contains(node)) return;
  visited.add(node);
  for (int neighbor in graph[node] ?? []) {
    dfs(neighbor, visited, graph);
  }
}
```

#### 3. **Matrix Traversal (for grid-based problems)**

```dart
List<List<int>> dirs = [[0,1], [1,0], [0,-1], [-1,0]];

void traverse(List<List<int>> grid, int i, int j) {
  if (i < 0 || j < 0 || i >= grid.length || j >= grid[0].length) return;
  // handle cell...
}
```

#### 4. **Custom Comparator for Sorting**

Sometimes needed beyond `age` field:

```dart
list.sort((a, b) {
  if (a.score == b.score) return a.name.compareTo(b.name);
  return b.score.compareTo(a.score); // descending
});
```
