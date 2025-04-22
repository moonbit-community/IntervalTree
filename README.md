# IntervalTree

[English](https://github.com/moonbit-community/IntervalTree/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IntervalTree/blob/master/README_zh_CN.md)


IntervalTree is an efficient interval tree implementation that supports various interval query operations, such as finding overlapping intervals and contained intervals. An interval tree is a special self-balancing binary search tree designed for fast processing of interval queries.

## 🚀 Key Features
• 🔄 Multiple Construction Methods - Support for empty trees, single interval trees, and creating from arrays  
• ➕ Add & Query - Easily insert intervals and check for their existence  
• ❌ Remove - Remove specific intervals from the tree  
• 🔍 Powerful Queries - Support for finding intervals that overlap with or are contained within specific intervals  
• 📐 Interval Types - Support for four interval types: closed [a,b], open (a,b), left-closed right-open [a,b), and left-open right-closed (a,b]  
• 🧠 Generic Support - Can use any type that implements the Compare trait as interval endpoints  
• 🔄 Iteration - Traverse all stored intervals and their associated data  

## 📥 Installation
```bash
moon add kesmeey/IntervalTree
```

## 🚀 Usage Guide

### 🔨 Creating an Interval Tree
You can create an interval tree using the `new()`, `singleton()`, or `from_array()` methods.

```moonbit
// Create an empty interval tree
let tree : T[Int, String] = @IntervalTree.new()

// Create with a single interval
let interval = @IntervalTree.make_interval(10, 20)
let single_tree = @IntervalTree.singleton(interval, "data")

// Create from an array of intervals
let intervals = [
  (@IntervalTree.make_interval(10, 20), "A"),
  (@IntervalTree.make_interval(15, 25), "B"),
  (@IntervalTree.make_interval(5, 15), "C"),
]
let tree_from_array = @IntervalTree.from_array(intervals)
```

### ➕ Adding Intervals and Data
Use the `insert()` method to add intervals and their associated data to the tree.

```moonbit
  let tree : T[Int, String] = @IntervalTree.new() // Create empty tree
  let p1 = tree.insert(@IntervalTree.make_interval(10, 20), "A") // Returns insertion result, true for successful insertion
  println(p1) // true
  println(tree.size()) // 1
```

### 🔍 Querying Intervals
The interval tree supports several powerful query operations. Use the `find_overlaps()` method to find all intervals that overlap with a given interval, use the `find_contained()` method to find all intervals completely contained within a given interval, and use the `contains()` method to check if a specific interval exists in the tree.

```moonbit
// Create a new tree and add data
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
ignore(tree.insert(@IntervalTree.make_interval(30, 40), "D"))

// Find all intervals that overlap with a given interval
let query = @IntervalTree.make_interval(12, 18)
let overlaps = tree.find_overlaps(query)
assert_eq!(overlaps.length(), 3)  // Should find A, B, C

// Find all intervals completely contained within a given interval
let container = @IntervalTree.make_interval(5, 30)
let contained = tree.find_contained(container)
assert_eq!(contained.length(), 3)  // Should find A, B, C

// Check if a specific interval exists
if tree.contains(@IntervalTree.make_interval(10, 20)) {
  // Interval exists
  assert_true!(true)
}
```

### ❌ Removing Intervals
Use the `remove()` method to remove a specific interval.

```moonbit
// Create a new tree and add data
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

// Remove an existing interval
let removed = tree.remove(@IntervalTree.make_interval(10, 20))
assert_eq!(removed, true)  // Returns true if the interval exists and was successfully removed
assert_eq!(tree.size(), 2)
```

### 🧹 Clearing the Tree
Use the `clear()` method to remove all intervals from the tree.

```moonbit
// Create a new tree and add data
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

// Clear the tree
tree.clear()
assert_eq!(tree.size(), 0)
assert_eq!(tree.is_empty(), true)
```

### 📏 Size and Capacity
Use the `size()` and `is_empty()` methods to check the status of the tree.

```moonbit
// Create a new tree and add data
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

// Check size
let size = tree.size()  // Get the number of intervals
assert_eq!(size, 2)

// Check if empty after clearing
tree.clear()
let empty = tree.is_empty()  // Check if the tree is empty
assert_true!(empty)
```

### 🔄 Iteration
Use the `each()` and `eachi()` methods to iterate through all intervals in the tree.

```moonbit
// Create a new tree and add data
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

// Collect iteration results
let values = []

// Iterate through all intervals and data
tree.each(fn(interval, value) {
  values.push(value)
})
assert_eq!(values.length(), 3)

// Iterate with indices
let idx_values = []
tree.eachi(fn(idx, interval, value) {
  idx_values.push((idx, value))
})
assert_eq!(idx_values.length(), 3)
```

### 📋 Converting to Array
Use the `to_array()` method to convert all intervals in the tree to an array.

```moonbit
 // Create a new tree and add data
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

  // Convert to array
  let array = tree.to_array()
  // Returns an array of IntervalMatch objects, each containing interval and data
  assert_eq!(array.length(), 2)
  println(array)
  //[{interval: {low: 10, high: 20}, data: "A"}, {interval: {low: 15, high: 25}, data: "B"}]
```

### 🎯 Index Access
Use the `[]` operator to access intervals by index.

```moonbit
  // Create a new tree and add data
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

  // Access by index
  let match0 = tree[0]
  // Get the first interval's IntervalMatch
  println(match0) //  {interval: {low: 5, high: 15}, data: "C"}
  let match1 = tree[1]
  // Get the second interval's IntervalMatch
  println(match1) // {interval: {low: 10, high: 20}, data: "A"}
```

### 📐 Interval Types
Support different types of intervals by specifying them through the `new_with_options()` method.

```moonbit
  // Create a tree with open intervals
  let open_option = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }

  let open_tree = @IntervalTree.new_with_options(open_option)
  ignore(open_tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  // Create a tree with closed intervals
  let closed_option = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }

  let closed_tree = @IntervalTree.new_with_options(closed_option)
  ignore(closed_tree.insert(@IntervalTree.make_interval(10, 20), "B"))
```

### 🧠 Generic Support
The interval tree supports any type that implements the Compare trait as interval endpoints, such as Float and String types.

```moonbit
  // Using Float type intervals
  let float_tree : T[Float, String] = @IntervalTree.new()
  let p1 = float_tree.insert(@IntervalTree.make_interval(10.5, 20.5), "A")
  assert_eq!(p1, true) // Successful insertion

  // Using String type intervals
  let string_tree : T[String, Int] = @IntervalTree.new()
  let p2 = string_tree.insert(@IntervalTree.make_interval("a", "z"), 1)
  assert_eq!(p2, true) // Successful insertion
```

## 📜 License
This project is licensed under the Apache-2.0 License. See LICENSE for details.

## 📢 Contact & Support
• Moonbit Community: moonbit-community  
• GitHub Issues: [Report an Issue](https://github.com/moonbit-community/IntervalTree/issues)

👋 If you like this project, give it a ⭐! Happy coding! 🚀