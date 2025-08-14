///|
pub fn[V, D] new() -> T[V, D] {
  { root: None, size: 0, options: default_options() }
}

///|
/// Creates a new interval tree with options.
pub fn[V, D] new_with_options(options : IntervalOptions) -> T[V, D] {
  { root: None, size: 0, options }
}

///|
/// Creates a new interval tree with a single interval.
pub fn[V : Compare, D] singleton(
  interval : Interval[V],
  data : D,
  options~ : IntervalOptions = default_options(),
) -> T[V, D] {
  let tree = new_with_options(options)
  ignore(tree.insert(interval, data))
  tree
}

///|
/// Creates a new interval tree from an array of intervals and data.
pub fn[V : Compare, D] from_array(
  intervals : Array[(Interval[V], D)],
  options~ : IntervalOptions = default_options(),
) -> T[V, D] {
  let tree = new_with_options(options)
  for i in 0..<intervals.length() {
    let (interval, data) = intervals[i]
    ignore(tree.insert(interval, data))
  }
  tree
}

///|
/// Inserts an interval with associated data into the tree.
/// Returns true if the interval was inserted, false if it was rejected or updated.
pub fn[V : Compare, D] insert(
  self : T[V, D],
  interval : Interval[V],
  data : D,
) -> Bool {
  // Validate interval
  if is_valid_interval(interval) == false {
    println("Invalid interval: low > high")
    return false
  }

  // If duplicates are not allowed and the same interval exists, update the data
  if self.options.allow_duplicates == false {
    match self.find_exact(interval) {
      Some(node) => {
        // Update data in existing node
        node.data = data
        return false
      }
      None => ()
    }
  } // Continue with insertion
  let new_node = {
    interval,
    data,
    max_high: interval.high,
    left: None,
    right: None,
    height: 1,
  }

  // Insert new node

  match self.root {
    None => {
      self.root = Some(new_node)
      self.size += 1
      return true
    }
    Some(root) => {
      let inserted = insert_node(root, new_node)
      if inserted {
        self.size += 1
      }
      return inserted
    }
  }
}

///|
/// Removes an interval from the tree.
/// Returns true if the interval was found and removed.
pub fn[V : Compare, D] remove(self : T[V, D], interval : Interval[V]) -> Bool {
  match self.root {
    None => return false
    Some(_) => {
      let result = remove_node(self.root, interval)
      match result.removed {
        true => {
          self.root = result.node
          self.size -= 1
          return true
        }
        false => return false
      }
    }
  }
}

///|
/// Finds all intervals that overlap with the query interval.
pub fn[V : Compare, D] find_overlaps(
  self : T[V, D],
  query : Interval[V],
) -> Array[IntervalMatch[V, D]] {
  let results = []
  match self.root {
    None => results
    Some(root) => {
      find_overlaps_helper(root, query, results, self.options.interval_type)
      results
    }
  }
}

///|
/// Finds all intervals in the subtree that overlap with the query interval.
pub fn[V : Compare, D] find_overlaps_helper(
  node : Node[V, D],
  query : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType,
) -> Unit {
  // Check if the current node's interval overlaps with the query interval
  if intervals_overlap(node.interval, query, interval_type~) {
    // Add the current node to the result list
    results.push({ interval: node.interval, data: node.data })
  }

  // Check the left subtree
  // If the left subtree exists and its max_high >= the query interval's low, there may be overlap
  match node.left {
    Some(left_node) =>
      if endpoints_overlap(left_node.max_high, query.low, interval_type) {
        find_overlaps_helper(left_node, query, results, interval_type)
      }
    None => ()
  }

  // Check the right subtree
  // If the query interval's high >= the current node's low, there may be overlap in the right subtree
  match node.right {
    Some(right_node) =>
      if endpoints_overlap(query.high, node.interval.low, interval_type) {
        find_overlaps_helper(right_node, query, results, interval_type)
      }
    None => ()
  }
}

///|
/// Finds all intervals that are completely contained within the query interval.
pub fn[V : Compare, D] find_contained(
  self : T[V, D],
  query : Interval[V],
) -> Array[IntervalMatch[V, D]] {
  let results = []
  match self.root {
    None => results
    Some(root) => {
      find_contained_helper(root, query, results, self.options.interval_type)
      results
    }
  }
}

///|
/// Finds an interval exactly matching the query.
pub fn[V : Compare, D] find_exact(
  self : T[V, D],
  query : Interval[V],
) -> Node[V, D]? {
  match self.root {
    None => None
    Some(root) => find_exact_helper(root, query)
  }
}

///|
/// Returns true if the tree contains an interval that exactly matches the query.
pub fn[V : Compare, D] contains(self : T[V, D], query : Interval[V]) -> Bool {
  match self.find_exact(query) {
    Some(_) => true
    None => false
  }
}

///|
/// Clears all intervals from the tree.
pub fn[V, D] clear(self : T[V, D]) -> Unit {
  self.root = None
  self.size = 0
}

///|
/// Returns the number of intervals in the tree.
pub fn[V, D] size(self : T[V, D]) -> Int {
  self.size
}

///|
/// Returns true if the tree is empty.
pub fn[V, D] is_empty(self : T[V, D]) -> Bool {
  self.size == 0
}

// Helper functions for tree operations

///|
/// Inserts a node into the tree.
pub fn[V : Compare, D] insert_node(
  node : Node[V, D],
  new_node : Node[V, D],
) -> Bool {
  // Use the low endpoint of the interval as the BST key
  let comp = new_node.interval.low.compare(node.interval.low)

  // Insert into the left subtree
  if comp < 0 {
    match node.left {
      None => {
        node.left = Some(new_node)
        update_height_and_max_high(node)
        return true
      }
      Some(left) => {
        let inserted = insert_node(left, new_node)
        if inserted {
          update_height_and_max_high(node)
          balance(node)
        }
        return inserted
      }
    }
  } else if comp > 0 {
    match node.right {
      None => {
        node.right = Some(new_node)
        update_height_and_max_high(node)
        return true
      }
      Some(right) => {
        let inserted = insert_node(right, new_node)
        if inserted {
          update_height_and_max_high(node)
          balance(node)
        }
        return inserted
      }
    }
  } else if new_node.interval.high == node.interval.high {
    // Update data
    node.data = new_node.data
    return false
    // Decide insertion position based on high endpoint
  } else if new_node.interval.high.compare(node.interval.high) < 0 {
    // Change if node.left.is_none() to match
    match node.left {
      None => {
        node.left = Some(new_node)
        update_height_and_max_high(node)
        return true
      }
      Some(left) => {
        let inserted = insert_node(left, new_node)
        if inserted {
          update_height_and_max_high(node)
          balance(node)
        }
        return inserted
      }
    }
  } else {
    // Change if node.right.is_none() to match
    match node.right {
      None => {
        node.right = Some(new_node)
        update_height_and_max_high(node)
        return true
      }
      Some(right) => {
        let inserted = insert_node(right, new_node)
        if inserted {
          update_height_and_max_high(node)
          balance(node)
        }
        return inserted
      }
    }
  }
}

///|
/// Removal result
pub struct RemoveResult[V, D] {
  node : Node[V, D]?
  removed : Bool
}

///|
pub fn[V : Compare, D] remove_node(
  node : Node[V, D]?,
  interval : Interval[V],
) -> RemoveResult[V, D] {
  match node {
    None => { node: None, removed: false }
    Some(current) => {
      let comp = interval.low.compare(current.interval.low)

      // Search in the left subtree
      if comp < 0 {
        let result = remove_node(current.left, interval)
        current.left = result.node
        if result.removed {
          update_height_and_max_high(current)
          balance(current)
          { node: Some(current), removed: true }
        } else {
          { node: Some(current), removed: false }
        }
        // Search in the right subtree
      } else if comp > 0 {
        let result = remove_node(current.right, interval)
        current.right = result.node
        if result.removed {
          update_height_and_max_high(current)
          balance(current)
          { node: Some(current), removed: true }
        } else {
          { node: Some(current), removed: false }
        }
        // Found a node with the same low endpoint, check the high endpoint
      } else if current.interval.high != interval.high {
        // Same low endpoint but different high endpoint, may be in the subtree
        let result = remove_node(current.right, interval)
        current.right = result.node
        if result.removed {
          update_height_and_max_high(current)
          balance(current)
          { node: Some(current), removed: true }
        } else {
          { node: Some(current), removed: false }
        }
      } else {
        // Found the node to be removed
        match (current.left, current.right) {
          // Case 1: Leaf node
          (None, None) => { node: None, removed: true }
          // Case 2a: Only right child
          (None, Some(_)) => { node: current.right, removed: true }
          // Case 2b: Only left child
          (Some(_), None) => { node: current.left, removed: true }
          // Case 3: Two children
          (Some(_), Some(_)) => {
            // Find the minimum node in the right subtree
            let successor = find_min(current.right.unwrap())

            // Copy the successor's value to the current node
            current.interval = successor.interval
            current.data = successor.data

            // Remove the successor node
            let result = remove_node(current.right, successor.interval)
            current.right = result.node
            update_height_and_max_high(current)
            balance(current)
            { node: Some(current), removed: true }
          }
        }
      }
    }
  }
}

///|
/// Finds the node with the minimum value in the subtree.

///|
/// Finds the node with the minimum value in the subtree.
pub fn[V, D] find_min(node : Node[V, D]) -> Node[V, D] {
  let mut current = node
  while true {
    match current.left {
      None => break
      Some(left) => current = left
    }
  }
  current
}

///|
/// Finds a node with exactly matching interval.
pub fn[V : Compare, D] find_exact_helper(
  node : Node[V, D],
  query : Interval[V],
) -> Node[V, D]? {
  let low_comp = query.low.compare(node.interval.low)
  if low_comp == 0 && query.high == node.interval.high {
    return Some(node)
  }
  if low_comp < 0 {
    match node.left {
      Some(left) => find_exact_helper(left, query)
      None => None
    }
  } else {
    match node.right {
      Some(right) => find_exact_helper(right, query)
      None => None
    }
  }
}

///|

///|
/// Finds all intervals in the subtree that are completely contained within the query interval.
pub fn[V : Compare, D] find_contained_helper(
  node : Node[V, D],
  query : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType,
) -> Unit {
  // Check if the current node's interval is completely contained within the query interval
  // Check if the current node's interval is completely contained within the query interval
  if interval_contains(query, node.interval, interval_type~) {
    // Create object first, then push into array
    let match_obj = { interval: node.interval, data: node.data }
    results.push(match_obj)
  }

  // Use match to check the left subtree
  match node.left {
    Some(left_node) =>
      if endpoints_leq(query.low, node.interval.low, interval_type) {
        find_contained_helper(left_node, query, results, interval_type)
      }
    None => ()
  }

  // Use match to check the right subtree
  match node.right {
    Some(right_node) =>
      if endpoints_geq(query.high, node.interval.high, interval_type) {
        find_contained_helper(right_node, query, results, interval_type)
      }
    None => ()
  }
}

// This duplicate definition has been removed
// AVL Tree balancing functions

///|
/// Updates height and max_high values of a node.
pub fn[V : Compare, D] update_height_and_max_high(node : Node[V, D]) -> Unit {
  // Update height
  node.height = 1 +
    @cmp.maximum(
      match node.left {
        Some(left) => left.height
        None => 0
      },
      match node.right {
        Some(right) => right.height
        None => 0
      },
    )

  // Update max_high
  node.max_high = node.interval.high
  match node.left {
    Some(left) =>
      if left.max_high.compare(node.max_high) > 0 {
        node.max_high = left.max_high
      }
    None => ()
  }
  match node.right {
    Some(right) =>
      if right.max_high.compare(node.max_high) > 0 {
        node.max_high = right.max_high
      }
    None => ()
  }
}

///|
/// Gets the balance factor of a node.
pub fn[V, D] get_balance_factor(node : Node[V, D]) -> Int {
  let left_height = match node.left {
    Some(left) => left.height
    None => 0
  }
  let right_height = match node.right {
    Some(right) => right.height
    None => 0
  }
  left_height - right_height
}

///|
/// Balances a node if needed.
pub fn[V : Compare, D] balance(node : Node[V, D]) -> Unit {
  let balance = get_balance_factor(node)

  // Left subtree is heavier
  if balance > 1 {
    let left = node.left.unwrap()

    // Left-Left case or Left-Right case
    if get_balance_factor(left) >= 0 {
      right_rotate(node)
    } else {
      left_rotate(left)
      right_rotate(node)
    }
    // Right subtree is heavier
  } else if balance < -1 {
    let right = node.right.unwrap()

    // Right-Right case or Right-Left case
    if get_balance_factor(right) <= 0 {
      left_rotate(node)
    } else {
      right_rotate(right)
      left_rotate(node)
    }
  }
}

///|
/// Right rotation.
pub fn[V : Compare, D] right_rotate(y : Node[V, D]) -> Unit {
  match y.left {
    Some(x) => {
      let t2 = x.right

      // Perform rotation
      x.right = Some(y)
      y.left = t2

      // Update height and max_high
      update_height_and_max_high(y)
      update_height_and_max_high(x)

      // Additional handling needed: make the parent node point to the new subtree root x
    }
    None =>
      // Should not happen theoretically
      println(
        "Error: Attempt to perform right rotation on a node with empty left subtree",
      )
  }
}

///|
/// Left rotation.
pub fn[V : Compare, D] left_rotate(x : Node[V, D]) -> Unit {
  match x.right {
    Some(y) => {
      let t2 = y.left

      // Perform rotation
      y.left = Some(x)
      x.right = t2

      // Update height and max_high
      update_height_and_max_high(x)
      update_height_and_max_high(y)

      // Additional handling needed: make the parent node point to the new subtree root y
    }
    None =>
      // Should not happen theoretically
      println(
        "Error: Attempt to perform left rotation on a node with empty right subtree",
      )
  }
}
// Interval operations

///|
/// Checks if an interval is valid (low <= high).
pub fn[V : Compare] is_valid_interval(interval : Interval[V]) -> Bool {
  interval.low.compare(interval.high) <= 0
}

///|
/// Checks if two intervals overlap.
pub fn[V : Compare] intervals_overlap(
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed =>
      a.low.compare(b.high) <= 0 && b.low.compare(a.high) <= 0
    IntervalType::Open => a.low.compare(b.high) < 0 && b.low.compare(a.high) < 0
    IntervalType::LeftClosed =>
      a.low.compare(b.high) <= 0 && b.low.compare(a.high) < 0
    IntervalType::RightClosed =>
      a.low.compare(b.high) < 0 && b.low.compare(a.high) <= 0
  }
}

///|
/// Checks if interval a contains interval b.
pub fn[V : Compare] interval_contains(
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed,
) -> Bool {
  match interval_type {
    IntervalType::Closed =>
      a.low.compare(b.low) <= 0 && b.high.compare(a.high) <= 0
    IntervalType::Open => a.low.compare(b.low) < 0 && b.high.compare(a.high) < 0
    IntervalType::LeftClosed =>
      a.low.compare(b.low) <= 0 && b.high.compare(a.high) < 0
    IntervalType::RightClosed =>
      a.low.compare(b.low) < 0 && b.high.compare(a.high) <= 0
  }
}

///|
/// Checks if two endpoints overlap based on interval type.
pub fn[V : Compare] endpoints_overlap(
  a : V,
  b : V,
  interval_type : IntervalType,
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) >= 0
    IntervalType::Open => a.compare(b) > 0
    IntervalType::LeftClosed => a.compare(b) > 0 // Left-closed, right-open, right endpoint not included
    IntervalType::RightClosed => a.compare(b) >= 0 // Left-open, right-closed, right endpoint included
  }
}

///|
/// Checks if endpoint a is less than or equal to endpoint b based on interval type.
pub fn[V : Compare] endpoints_leq(
  a : V,
  b : V,
  interval_type : IntervalType,
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) <= 0
    IntervalType::Open => a.compare(b) < 0
    IntervalType::LeftClosed => a.compare(b) <= 0
    IntervalType::RightClosed => a.compare(b) < 0
  }
}

///|
/// Checks if endpoint a is greater than or equal to endpoint b based on interval type.
pub fn[V : Compare] endpoints_geq(
  a : V,
  b : V,
  interval_type : IntervalType,
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) >= 0
    IntervalType::Open => a.compare(b) > 0
    IntervalType::LeftClosed => a.compare(b) > 0
    IntervalType::RightClosed => a.compare(b) >= 0
  }
}

///|
/// Converts the tree to an array of IntervalMatch objects.
pub fn[V, D] to_array(self : T[V, D]) -> Array[IntervalMatch[V, D]] {
  // Get all intervals and store them in a temporary array
  let intervals_data = []
  self.each(fn(interval, data) { intervals_data.push((interval, data)) })

  // Create result array and fill with data
  let n = intervals_data.length()
  let result = []
  for i in 0..<n {
    let (interval, data) = intervals_data[i]
    result.push({ interval, data })
  }
  result
}

// ///|
// /// Debug tool: prints the tree structure.
// pub fn debug_tree[V : Show, D](self : T[V, D]) -> String {
//   fn build_string(node : Node[V, D]?, indent : String = "") -> String {
//     match node {
//       None => indent + "- <empty>\n"
//       Some(current) => {
//         let mut result = indent + "- [" + current.interval.low.to_string() + 
//                       ", " + current.interval.high.to_string() + 
//                       "] (max=" + current.max_high.to_string() + 
//                       ", h=" + current.height.to_string() + ")\n"

//         result += build_string(current.left, indent + "  ")
//         result += build_string(current.right, indent + "  ")

//         result
//       }
//     }
//   }

//   build_string(self.root)
// }

// Utility functions for the test cases

///|
/// Creates an interval with the given endpoints.
pub fn[T : Compare] make_interval(low : T, high : T) -> Interval[T] {
  if low.compare(high) > 0 {
    println("Warning: Created invalid interval")
  }
  { low, high }
}

///|
pub impl[V, D] Show for T[V, D] with output(self, logger) {
  logger.write_string("IntervalTree(size=" + self.size.to_string() + ")")
}

///|
/// Helper function for traversing the tree in-order
pub fn[V, D, R] in_order_traverse(
  node : Node[V, D]?,
  f : (Node[V, D]) -> R,
  acc : R,
) -> R {
  match node {
    None => acc
    Some(current) => {
      // Visit left subtree first
      ignore(in_order_traverse(current.left, f, acc))

      // Process current node
      let current_result = f(current)

      // Visit right subtree last
      in_order_traverse(current.right, f, current_result)
    }
  }
}

///|
/// Iterates over all intervals in the tree.
pub fn[V, D] each(self : T[V, D], f : (Interval[V], D) -> Unit) -> Unit {
  let node_f = fn(node : Node[V, D]) -> Unit { f(node.interval, node.data) }
  in_order_traverse(self.root, node_f, ())
}

///|
/// Iterates over all intervals in the tree with index.
pub fn[V, D] eachi(self : T[V, D], f : (Int, Interval[V], D) -> Unit) -> Unit {
  let mut index = 0
  let node_f = fn(node : Node[V, D]) -> Unit {
    f(index, node.interval, node.data)
    index += 1
  }
  in_order_traverse(self.root, node_f, ())
}

// Access intervals in the tree by index

///| This is a convenience method that provides index-based access to tree elements

///|
/// Implement index access for interval tree
pub fn[V, D] op_get(self : T[V, D], index : Int) -> IntervalMatch[V, D] {
  let mut result = None
  let mut current_idx = 0
  self.each(fn(interval, data) {
    if current_idx == index {
      result = Some({ interval, data })
    }
    current_idx += 1
  })
  result.unwrap()
}
