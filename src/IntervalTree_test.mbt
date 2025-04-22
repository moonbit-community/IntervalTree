///|
test "new_empty_tree" {
  let tree : T[Int, String] = @IntervalTree.new()
  assert_eq!(tree.size(), 0)
  assert_eq!(tree.is_empty(), true)
}

///|
test "insert_and_find" {
  let tree : T[Int, String] = @IntervalTree.new()
  let p1 = tree.insert(@IntervalTree.make_interval(10, 20), "A")
  assert_eq!(p1, true)
  assert_eq!(tree.size(), 1)
  let p2 = tree.insert(@IntervalTree.make_interval(15, 25), "B")
  assert_eq!(p2, true)
  assert_eq!(tree.size(), 2)
  let p3 = tree.insert(@IntervalTree.make_interval(5, 15), "C")
  assert_eq!(p3, true)
  assert_eq!(tree.size(), 3)
}

///|
test "find_overlaps" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  ignore(tree.insert(@IntervalTree.make_interval(30, 40), "D"))
  let query = @IntervalTree.make_interval(12, 18)
  let overlaps = tree.find_overlaps(query)
  assert_eq!(overlaps.length(), 3)
  let no_overlap_query = @IntervalTree.make_interval(26, 29)
  let no_results = tree.find_overlaps(no_overlap_query)
  assert_eq!(no_results.length(), 0)
}

///|
test "find_contained" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(12, 18), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 30), "C"))
  let query = @IntervalTree.make_interval(5, 30)
  let contained = tree.find_contained(query)
  assert_eq!(contained.length(), 3)
  let query2 = @IntervalTree.make_interval(9, 21)
  let contained2 = tree.find_contained(query2)
  assert_eq!(contained2.length(), 2)
}

///|
test "remove_intervals" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Add intervals - modified to use ignore
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  assert_eq!(tree.size(), 3)

  // Remove existing interval
  let removed = tree.remove(@IntervalTree.make_interval(10, 20))
  assert_eq!(removed, true)
  assert_eq!(tree.size(), 2)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), false)

  // Try to remove non-existing interval
  let not_removed = tree.remove(@IntervalTree.make_interval(10, 20))
  assert_eq!(not_removed, false)
  assert_eq!(tree.size(), 2)
}

///|
test "clear_tree" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Add intervals - modified to use ignore
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  assert_eq!(tree.size(), 2)

  // Clear the tree
  tree.clear()
  assert_eq!(tree.size(), 0)
  assert_eq!(tree.is_empty(), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), false)
}

///|
test "each_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let intervals = []
  let data = []
  tree.each(fn(interval, value) {
    intervals.push((interval.low, interval.high))
    data.push(value)
  })
  assert_eq!(intervals.length(), 3)
  assert_eq!(data.length(), 3)
  assert_eq!(data.contains("A"), true)
  assert_eq!(data.contains("B"), true)
  assert_eq!(data.contains("C"), true)
}

///|
test "eachi_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let indices = []
  let intervals = []
  let data = []
  tree.eachi(fn(idx, interval, value) {
    indices.push(idx)
    intervals.push((interval.low, interval.high))
    data.push(value)
  })
  assert_eq!(indices, [0, 1, 2])
  assert_eq!(data.length(), 3)
}

///|
test "to_array_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  let array = tree.to_array()
  assert_eq!(array.length(), 2)
  assert_eq!(array[0].data == "A" || array[1].data == "A", true)
  assert_eq!(array[0].data == "B" || array[1].data == "B", true)
}

///|
test "singleton_constructor" {
  let interval = @IntervalTree.make_interval(10, 20)
  let tree = @IntervalTree.singleton(interval, "data")
  assert_eq!(tree.size(), 1)
  assert_eq!(tree.contains(interval), true)
}

///|
test "from_array_constructor" {
  let intervals = [
    (@IntervalTree.make_interval(10, 20), "A"),
    (@IntervalTree.make_interval(15, 25), "B"),
    (@IntervalTree.make_interval(5, 15), "C"),
  ]
  let tree = @IntervalTree.from_array(intervals)
  assert_eq!(tree.size(), 3)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(15, 25)), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(5, 15)), true)
}

///|
test "op_get_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let match0 = tree[0]
  let match1 = tree[1]
  let match2 = tree[2]
  assert_eq!(
    match0.data == "A" || match0.data == "B" || match0.data == "C",
    true,
  )
  assert_eq!(
    match1.data == "A" || match1.data == "B" || match1.data == "C",
    true,
  )
  assert_eq!(
    match2.data == "A" || match2.data == "B" || match2.data == "C",
    true,
  )

  // Test that the indices are unique
  assert_eq!(
    match0.data != match1.data &&
    match1.data != match2.data &&
    match0.data != match2.data,
    true,
  )
}

///|
test "different_value_types" {
  // Test with Float values
  let float_tree : T[Float, String] = @IntervalTree.new()
  ignore(float_tree.insert(@IntervalTree.make_interval(10.5, 20.5), "A"))
  assert_eq!(float_tree.size(), 1)

  // Test with String values
  let string_tree : T[String, Int] = @IntervalTree.new()
  ignore(string_tree.insert(@IntervalTree.make_interval("a", "z"), 1))
  assert_eq!(string_tree.size(), 1)
  assert_eq!(string_tree.contains(@IntervalTree.make_interval("a", "z")), true)
}

///|
test "new_empty_tree" {
  let tree : T[Int, String] = @IntervalTree.new()
  assert_eq!(tree.size(), 0)
  assert_eq!(tree.is_empty(), true)
}

///|
test "insert_and_find" {
  let tree : T[Int, String] = @IntervalTree.new()
  let p1 = tree.insert(@IntervalTree.make_interval(10, 20), "A")
  assert_eq!(p1, true)
  assert_eq!(tree.size(), 1)
  let p2 = tree.insert(@IntervalTree.make_interval(15, 25), "B")
  assert_eq!(p2, true)
  assert_eq!(tree.size(), 2)
  let p3 = tree.insert(@IntervalTree.make_interval(5, 15), "C")
  assert_eq!(p3, true)
  assert_eq!(tree.size(), 3)
}

///|
test "find_overlaps" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Add several intervals
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  ignore(tree.insert(@IntervalTree.make_interval(30, 40), "D"))

  // Test overlap query
  let query = @IntervalTree.make_interval(12, 18)
  let overlaps = tree.find_overlaps(query)
  assert_eq!(overlaps.length(), 3) // Should find A, B, C

  // Test query with no overlaps
  let no_overlap_query = @IntervalTree.make_interval(26, 29)
  let no_results = tree.find_overlaps(no_overlap_query)
  assert_eq!(no_results.length(), 0)
}

///|
test "find_contained" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Modified to use ignore
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(12, 18), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 30), "C"))

  // Test containment query
  let query = @IntervalTree.make_interval(5, 30)
  let contained = tree.find_contained(query)
  assert_eq!(contained.length(), 3) // Should find all intervals
  let query2 = @IntervalTree.make_interval(9, 21)
  let contained2 = tree.find_contained(query2)
  assert_eq!(contained2.length(), 2) // Should find A and B
}

///|
test "remove_intervals" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Add intervals - modified to use ignore
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  assert_eq!(tree.size(), 3)

  // Remove existing interval
  let removed = tree.remove(@IntervalTree.make_interval(10, 20))
  assert_eq!(removed, true)
  assert_eq!(tree.size(), 2)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), false)

  // Try to remove non-existing interval
  let not_removed = tree.remove(@IntervalTree.make_interval(10, 20))
  assert_eq!(not_removed, false)
  assert_eq!(tree.size(), 2)
}

///|
test "clear_tree" {
  let tree : T[Int, String] = @IntervalTree.new()

  // Add intervals - modified to use ignore
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  assert_eq!(tree.size(), 2)

  // Clear the tree
  tree.clear()
  assert_eq!(tree.size(), 0)
  assert_eq!(tree.is_empty(), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), false)
}

///|
test "each_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let intervals = []
  let data = []
  tree.each(fn(interval, value) {
    intervals.push((interval.low, interval.high))
    data.push(value)
  })
  assert_eq!(intervals.length(), 3)
  assert_eq!(data.length(), 3)
  assert_eq!(data.contains("A"), true)
  assert_eq!(data.contains("B"), true)
  assert_eq!(data.contains("C"), true)
}

///|
test "eachi_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let indices = []
  let intervals = []
  let data = []
  tree.eachi(fn(idx, interval, value) {
    indices.push(idx)
    intervals.push((interval.low, interval.high))
    data.push(value)
  })
  assert_eq!(indices, [0, 1, 2])
  assert_eq!(data.length(), 3)
}

///|
test "to_array_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  let array = tree.to_array()
  assert_eq!(array.length(), 2)
  assert_eq!(array[0].data == "A" || array[1].data == "A", true)
  assert_eq!(array[0].data == "B" || array[1].data == "B", true)
}

///|
test "singleton_constructor" {
  let interval = @IntervalTree.make_interval(10, 20)
  let tree = @IntervalTree.singleton(interval, "data")
  assert_eq!(tree.size(), 1)
  assert_eq!(tree.contains(interval), true)
}

///|
test "from_array_constructor" {
  let intervals = [
    (@IntervalTree.make_interval(10, 20), "A"),
    (@IntervalTree.make_interval(15, 25), "B"),
    (@IntervalTree.make_interval(5, 15), "C"),
  ]
  let tree = @IntervalTree.from_array(intervals)
  assert_eq!(tree.size(), 3)
  assert_eq!(tree.contains(@IntervalTree.make_interval(10, 20)), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(15, 25)), true)
  assert_eq!(tree.contains(@IntervalTree.make_interval(5, 15)), true)
}

///|
test "op_get_method" {
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
  let match0 = tree[0]
  let match1 = tree[1]
  let match2 = tree[2]
  assert_eq!(
    match0.data == "A" || match0.data == "B" || match0.data == "C",
    true,
  )
  assert_eq!(
    match1.data == "A" || match1.data == "B" || match1.data == "C",
    true,
  )
  assert_eq!(
    match2.data == "A" || match2.data == "B" || match2.data == "C",
    true,
  )

  // Test that the indices are unique
  assert_eq!(
    match0.data != match1.data &&
    match1.data != match2.data &&
    match0.data != match2.data,
    true,
  )
}

///|
test "different_value_types" {
  // Test with Float values
  let float_tree : T[Float, String] = @IntervalTree.new()
  ignore(float_tree.insert(@IntervalTree.make_interval(10.5, 20.5), "A"))
  assert_eq!(float_tree.size(), 1)

  // Test with String values
  let string_tree : T[String, Int] = @IntervalTree.new()
  ignore(string_tree.insert(@IntervalTree.make_interval("a", "z"), 1))
  assert_eq!(string_tree.size(), 1)
  assert_eq!(string_tree.contains(@IntervalTree.make_interval("a", "z")), true)
}

///|
test "test_different_interval_types" {
  // Test open intervals
  let open_option = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }
  let open_tree : T[Int, String] = @IntervalTree.new_with_options(open_option)
  ignore(open_tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  let open_query = @IntervalTree.make_interval(20, 30)
  let open_results = open_tree.find_overlaps(open_query)
  assert_eq!(open_results.length(), 0) // In open interval type, (10,20) doesn't overlap with (20,30)

  // Test closed intervals
  let closed_option = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }
  let closed_tree : T[Int, String] = @IntervalTree.new_with_options(
    closed_option,
  )
  ignore(closed_tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  let closed_query = @IntervalTree.make_interval(20, 30)
  let closed_results = closed_tree.find_overlaps(closed_query)
  assert_eq!(closed_results.length(), 1) // In closed interval type, [10,20] overlaps with [20,30]
}
