// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Constructors and core operations

///|
/// Creates a new empty interval tree.
///|
/// Creates a new empty interval tree.
/// 
/// 
/// 
/// 
/// 
/// 

// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This module implements the interval tree data structure.
// The interval endpoints need to implement the Compare trait.
// All operations support dynamic updates with balanced tree structure.

///|
/// Represents an interval with low and high endpoints
pub fn new[V : Compare, D]() -> T[V, D] {
  { root: None, size: 0, options: default_options() }
}

///|
/// Creates a new interval tree with options.
pub fn new_with_options[V : Compare, D](options : IntervalOptions) -> T[V, D] {
  { root: None, size: 0, options }
}

///|
/// Creates a new interval tree with a single interval.
pub fn singleton[V : Compare, D](
  interval : Interval[V],
  data : D,
  options~ : IntervalOptions = default_options()
) -> T[V, D] {
  let tree = new_with_options(options)
  ignore(tree.insert(interval, data))
  tree
}

///|
/// Creates a new interval tree from an array of intervals and data.
pub fn from_array[V : Compare, D](
  intervals : Array[(Interval[V], D)],
  options~ : IntervalOptions = default_options()
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

///|
/// Inserts an interval with associated data into the tree.
/// Returns true if the interval was inserted, false if it was rejected or updated.
pub fn insert[V : Compare, D](
  self : T[V, D],
  interval : Interval[V],
  data : D
) -> Bool {
  // 验证区间有效性
  if is_valid_interval(interval) == false {
    println("无效区间: low > high")
    return false
  }

  // 如果不允许重复且已存在相同区间，则更新数据
  if self.options.allow_duplicates == false {
    match self.find_exact(interval) {
      Some(node) => {
        // 更新已存在节点的数据
        node.data = data
        return false
      }
      None => ...
    } // 继续执行插入操作
  }
  let new_node = {
    interval,
    data,
    max_high: interval.high,
    left: None,
    right: None,
    height: 1,
  }

  // 插入新节点

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
pub fn remove[V : Compare, D](self : T[V, D], interval : Interval[V]) -> Bool {
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
pub fn find_overlaps[V : Compare, D](
  self : T[V, D],
  query : Interval[V]
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
pub fn find_overlaps_helper[V : Compare, D](
  node : Node[V, D],
  query : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType
) -> Unit {
  // 检查当前节点的区间是否与查询区间重叠
  if intervals_overlap(node.interval, query, interval_type~) {
    // 将当前节点添加到结果列表中
    results.push({ interval: node.interval, data: node.data })
  }

  // 检查左子树
  // 如果左子树存在且其最大右端点 >= 查询区间的左端点，则可能有重叠
  match node.left {
    Some(left_node) =>
      if endpoints_overlap(left_node.max_high, query.low, interval_type) {
        find_overlaps_helper(left_node, query, results, interval_type)
      }
    None => ...
  }

  // 检查右子树
  // 如果查询区间的右端点 >= 当前节点的左端点，则右子树可能有重叠
  match node.right {
    Some(right_node) =>
      if endpoints_overlap(query.high, node.interval.low, interval_type) {
        find_overlaps_helper(right_node, query, results, interval_type)
      }
    None => ...
  }
}

///|
/// Finds all intervals that are completely contained within the query interval.
pub fn find_contained[V : Compare, D](
  self : T[V, D],
  query : Interval[V]
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
pub fn find_exact[V : Compare, D](
  self : T[V, D],
  query : Interval[V]
) -> Node[V, D]? {
  match self.root {
    None => None
    Some(root) => find_exact_helper(root, query)
  }
}

///|
/// Returns true if the tree contains an interval that exactly matches the query.
pub fn contains[V : Compare, D](self : T[V, D], query : Interval[V]) -> Bool {
  match self.find_exact(query) {
    Some(_) => true
    None => false
  }
}

///|
/// Clears all intervals from the tree.
pub fn clear[V, D](self : T[V, D]) -> Unit {
  self.root = None
  self.size = 0
}

///|
/// Returns the number of intervals in the tree.
pub fn size[V, D](self : T[V, D]) -> Int {
  self.size
}

///|
/// Returns true if the tree is empty.
pub fn is_empty[V, D](self : T[V, D]) -> Bool {
  self.size == 0
}

// Helper functions for tree operations

///|
/// Inserts a node into the tree.
///|
/// Inserts a node into the tree.
pub fn insert_node[V : Compare, D](
  node : Node[V, D],
  new_node : Node[V, D]
) -> Bool {
  // 使用区间的低端点作为BST的排序键
  let comp = new_node.interval.low.compare(node.interval.low)

  // 插入到左子树
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
    // 更新数据
    node.data = new_node.data
    return false
    // 根据高端点决定插入位置
  } else if new_node.interval.high.compare(node.interval.high) < 0 {
    // 将 if node.left.is_none() 改为 match
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
    // 将 if node.right.is_none() 改为 match
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
pub fn remove_node[V : Compare, D](
  node : Node[V, D]?,
  interval : Interval[V]
) -> RemoveResult[V, D] {
  match node {
    None => { node: None, removed: false }
    Some(current) => {
      let comp = interval.low.compare(current.interval.low)

      // 在左子树中查找
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
        // 在右子树中查找
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
        // 找到了相同低端点的节点，检查高端点
      } else if current.interval.high != interval.high {
        // 低端点相同但高端点不同，可能在子树中
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
        // 找到了要删除的节点
        match (current.left, current.right) {
          // 情况1: 叶节点
          (None, None) => { node: None, removed: true }
          // 情况2a: 只有右子节点
          (None, Some(_)) => { node: current.right, removed: true }
          // 情况2b: 只有左子节点
          (Some(_), None) => { node: current.left, removed: true }
          // 情况3: 有两个子节点
          (Some(_), Some(_)) => {
            // 查找右子树中的最小节点
            let successor = find_min(current.right.unwrap())

            // 复制后继节点的值到当前节点
            current.interval = successor.interval
            current.data = successor.data

            // 删除后继节点
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
pub fn find_min[V, D](node : Node[V, D]) -> Node[V, D] {
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
pub fn find_exact_helper[V : Compare, D](
  node : Node[V, D],
  query : Interval[V]
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
pub fn find_contained_helper[V : Compare, D](
  node : Node[V, D],
  query : Interval[V],
  results : Array[IntervalMatch[V, D]],
  interval_type : IntervalType
) -> Unit {
  // 检查当前节点的区间是否完全包含在查询区间内
  // 检查当前节点的区间是否完全包含在查询区间内
  if interval_contains(query, node.interval, interval_type~) {
    // 先创建对象，再推入数组
    let match_obj = { interval: node.interval, data: node.data }
    results.push(match_obj)
  }

  // 使用match检查左子树
  match node.left {
    Some(left_node) =>
      if endpoints_leq(query.low, node.interval.low, interval_type) {
        find_contained_helper(left_node, query, results, interval_type)
      }
    None => ...
  }

  // 使用match检查右子树
  match node.right {
    Some(right_node) =>
      if endpoints_geq(query.high, node.interval.high, interval_type) {
        find_contained_helper(right_node, query, results, interval_type)
      }
    None => ...
  }
}

// This duplicate definition has been removed

// AVL Tree balancing functions

///|
/// Updates height and max_high values of a node.
///|
/// Updates height and max_high values of a node.
pub fn update_height_and_max_high[V : Compare, D](node : Node[V, D]) -> Unit {
  // 更新高度
  node.height = 1 +
    @math.maximum(
      match node.left {
        Some(left) => left.height
        None => 0
      },
      match node.right {
        Some(right) => right.height
        None => 0
      },
    )

  // 更新最大右端点
  node.max_high = node.interval.high
  match node.left {
    Some(left) =>
      if left.max_high.compare(node.max_high) > 0 {
        node.max_high = left.max_high
      }
    None => ...
  }
  match node.right {
    Some(right) =>
      if right.max_high.compare(node.max_high) > 0 {
        node.max_high = right.max_high
      }
    None => ...
  }
}

///|
/// Gets the balance factor of a node.
pub fn get_balance_factor[V, D](node : Node[V, D]) -> Int {
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
pub fn balance[V : Compare, D](node : Node[V, D]) -> Unit {
  let balance = get_balance_factor(node)

  // 左子树偏重
  if balance > 1 {
    let left = node.left.unwrap()

    // 左-左情况或左-右情况
    if get_balance_factor(left) >= 0 {
      right_rotate(node)
    } else {
      left_rotate(left)
      right_rotate(node)
    }
    // 右子树偏重
  } else if balance < -1 {
    let right = node.right.unwrap()

    // 右-右情况或右-左情况
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
pub fn right_rotate[V : Compare, D](y : Node[V, D]) -> Unit {
  match y.left {
    Some(x) => {
      let t2 = x.right

      // 执行旋转
      x.right = Some(y)
      y.left = t2

      // 更新高度和最大右端点
      update_height_and_max_high(y)
      update_height_and_max_high(x)

      // 需要额外处理：让父节点指向新的子树根x
    }
    None =>
      // 理论上不应该发生
      println("错误：尝试在左子树为空的节点上执行右旋转")
  }
}

///|
/// Left rotation.
pub fn left_rotate[V : Compare, D](x : Node[V, D]) -> Unit {
  match x.right {
    Some(y) => {
      let t2 = y.left

      // 执行旋转
      y.left = Some(x)
      x.right = t2

      // 更新高度和最大右端点
      update_height_and_max_high(x)
      update_height_and_max_high(y)

      // 需要额外处理：让父节点指向新的子树根y
    }
    None =>
      // 理论上不应该发生
      println("错误：尝试在右子树为空的节点上执行左旋转")
  }
}
// Interval operations

///|
/// Checks if an interval is valid (low <= high).
pub fn is_valid_interval[V : Compare](interval : Interval[V]) -> Bool {
  interval.low.compare(interval.high) <= 0
}

///|
/// Checks if two intervals overlap.
pub fn intervals_overlap[V : Compare](
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed
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
pub fn interval_contains[V : Compare](
  a : Interval[V],
  b : Interval[V],
  interval_type~ : IntervalType = IntervalType::Closed
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
pub fn endpoints_overlap[V : Compare](
  a : V,
  b : V,
  interval_type : IntervalType
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) >= 0
    IntervalType::Open => a.compare(b) > 0
    IntervalType::LeftClosed => a.compare(b) > 0 // 左闭右开，右端点不包含
    IntervalType::RightClosed => a.compare(b) >= 0 // 左开右闭，右端点包含
  }
}

///|
/// Checks if endpoint a is less than or equal to endpoint b based on interval type.
pub fn endpoints_leq[V : Compare](
  a : V,
  b : V,
  interval_type : IntervalType
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
pub fn endpoints_geq[V : Compare](
  a : V,
  b : V,
  interval_type : IntervalType
) -> Bool {
  match interval_type {
    IntervalType::Closed => a.compare(b) >= 0
    IntervalType::Open => a.compare(b) > 0
    IntervalType::LeftClosed => a.compare(b) > 0
    IntervalType::RightClosed => a.compare(b) >= 0
  }
}

///|

///|

///|
/// Converts the tree to an array of IntervalMatch objects.
pub fn to_array[V, D](self : T[V, D]) -> Array[IntervalMatch[V, D]] {
  // 获取所有区间，存入一个临时数组
  let intervals_data = []
  self.each(fn(interval, data) { intervals_data.push((interval, data)) })

  // 创建结果数组并填充数据
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
pub fn make_interval[T : Compare](low : T, high : T) -> Interval[T] {
  if low.compare(high) > 0 {
    println("警告: 创建了无效区间 ")
  }
  { low, high }
}

// Implementation of Show for better debugging

///|
pub impl[V : Show, D : Show] Show for IntervalMatch[V, D] with output(
  self,
  logger
) {
  logger.write_string(
    "[" +
    self.interval.low.to_string() +
    ", " +
    self.interval.high.to_string() +
    "]: " +
    self.data.to_string(),
  )
}

///|
pub impl[V : Show, D] Show for T[V, D] with output(self, logger) {
  logger.write_string("IntervalTree(size=" + self.size.to_string() + ")")
}

///|
/// Helper function for traversing the tree in-order
pub fn in_order_traverse[V, D, R](
  node : Node[V, D]?,
  f : (Node[V, D]) -> R,
  acc : R
) -> R {
  match node {
    None => acc
    Some(current) => {
      // 先访问左子树
      let left_result = in_order_traverse(current.left, f, acc)

      // 处理当前节点
      let current_result = f(current)

      // 最后访问右子树
      in_order_traverse(current.right, f, current_result)
    }
  }
}

///|
/// Iterates over all intervals in the tree.
pub fn each[V, D](self : T[V, D], f : (Interval[V], D) -> Unit) -> Unit {
  let node_f = fn(node : Node[V, D]) -> Unit { f(node.interval, node.data) }
  in_order_traverse(self.root, node_f, ())
}

///|
/// Iterates over all intervals in the tree with index.
pub fn eachi[V, D](self : T[V, D], f : (Int, Interval[V], D) -> Unit) -> Unit {
  let mut index = 0
  let node_f = fn(node : Node[V, D]) -> Unit {
    f(index, node.interval, node.data)
    index += 1
  }
  in_order_traverse(self.root, node_f, ())
}
