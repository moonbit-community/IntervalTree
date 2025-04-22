# IntervalTree

[English](https://github.com/moonbit-community/IntervalTree/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IntervalTree/blob/master/README_zh_CN.md)


IntervalTree 是一个高效的区间树实现，支持各种区间查询操作，如查找重叠区间和包含区间。区间树是一种特殊的自平衡二叉搜索树，专为快速处理区间查询而设计。

## 🚀 主要特性
• 🔄 多种构造方式 - 支持空树、单区间树和从数组创建区间树  
• ➕ 添加与查询 - 方便地插入区间并检查区间的存在性  
• ❌ 移除 - 从树中移除特定区间  
• 🔍 强大的查询 - 支持查找与特定区间重叠或被包含的所有区间  
• 📐 区间类型 - 支持四种区间类型：闭区间[a,b]、开区间(a,b)、左闭右开[a,b)和左开右闭(a,b]  
• 🧠 泛型支持 - 可以使用任何实现了Compare特性的类型作为区间端点  
• 🔄 迭代功能 - 遍历所有存储的区间及其关联数据  

## 📥 安装
```bash
moon add kesmeey/IntervalTree
```

## 🚀 使用指南

### 🔨 创建区间树
你可以使用`new()`、`singleton()`或`from_array()`方法来创建区间树。

```moonbit
// 创建空的区间树
let tree : T[Int, String] = @IntervalTree.new()

// 使用单个区间创建
let interval = @IntervalTree.make_interval(10, 20)
let single_tree = @IntervalTree.singleton(interval, "data")

// 从区间数组创建
let intervals = [
  (@IntervalTree.make_interval(10, 20), "A"),
  (@IntervalTree.make_interval(15, 25), "B"),
  (@IntervalTree.make_interval(5, 15), "C"),
]
let tree_from_array = @IntervalTree.from_array(intervals)
```

### ➕ 添加区间和数据
使用`insert()`方法向树中添加区间及其关联数据。

```moonbit
  let tree : T[Int, String] = @IntervalTree.new() // 创建空树
  let p1 = tree.insert(@IntervalTree.make_interval(10, 20), "A") // 返回插入结果，true为插入成功
  println(p1) // true
  println(tree.size()) // 1
```

### 🔍 查询区间
区间树支持几种强大的查询操作，使用`find_overlaps()`方法查找与给定区间重叠的所有区间，使用`find_contained()`方法查找被给定区间完全包含的所有区间，使用`contains()`方法检查特定区间是否存在于树中。。

```moonbit
// 创建新的树并添加数据
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))
ignore(tree.insert(@IntervalTree.make_interval(30, 40), "D"))

// 查找与给定区间重叠的所有区间
let query = @IntervalTree.make_interval(12, 18)
let overlaps = tree.find_overlaps(query)
assert_eq!(overlaps.length(), 3)  // 应该找到A, B, C

// 查找完全被给定区间包含的所有区间
let container = @IntervalTree.make_interval(5, 30)
let contained = tree.find_contained(container)
assert_eq!(contained.length(), 3)  // 应该找到A, B, C

// 检查特定区间是否存在
if tree.contains(@IntervalTree.make_interval(10, 20)) {
  // 区间存在
  assert_true!(true)
}
```

### ❌ 移除区间
使用`remove()`方法移除特定区间。

```moonbit
// 创建新的树并添加数据
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

// 移除存在的区间
let removed = tree.remove(@IntervalTree.make_interval(10, 20))
assert_eq!(removed, true)  // 如果区间存在并被成功移除，返回true
assert_eq!(tree.size(), 2)
```

### 🧹 清空树
使用`clear()`方法清空树中的所有区间。

```moonbit
// 创建新的树并添加数据
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

// 清空树
tree.clear()
assert_eq!(tree.size(), 0)
assert_eq!(tree.is_empty(), true)
```

### 📏 大小和容量
使用`size()`和`is_empty()`方法检查树的状态。

```moonbit
// 创建新的树并添加数据
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

// 检查大小
let size = tree.size()  // 获取区间数量
assert_eq!(size, 2)

// 清空后检查是否为空
tree.clear()
let empty = tree.is_empty()  // 检查树是否为空
assert_true!(empty)
```

### 🔄 迭代
使用`each()`和`eachi()`方法遍历树中的所有区间。

```moonbit
// 创建新的树并添加数据
let tree : T[Int, String] = @IntervalTree.new()
ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

// 收集迭代结果
let values = []

// 遍历所有区间和数据
tree.each(fn(interval, value) {
  values.push(value)
})
assert_eq!(values.length(), 3)

// 使用索引遍历
let idx_values = []
tree.eachi(fn(idx, interval, value) {
  idx_values.push((idx, value))
})
assert_eq!(idx_values.length(), 3)
```

### 📋 转换为数组
使用`to_array()`方法将树中的所有区间转换为数组。

```moonbit
 // 创建新的树并添加数据
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))

  // 转换为数组
  let array = tree.to_array()
  // 返回IntervalMatch对象数组，每个对象包含interval和data
  assert_eq!(array.length(), 2)
  println(array)
  //[{interval: {low: 10, high: 20}, data: "A"}, {interval: {low: 15, high: 25}, data: "B"}]
```

### 🎯 索引访问
使用`[]`操作符按索引访问区间。

```moonbit
  // 创建新的树并添加数据
  let tree : T[Int, String] = @IntervalTree.new()
  ignore(tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  ignore(tree.insert(@IntervalTree.make_interval(15, 25), "B"))
  ignore(tree.insert(@IntervalTree.make_interval(5, 15), "C"))

  // 通过索引访问
  let match0 = tree[0]
  // 获取第一个区间的IntervalMatch 
  println(match0) //  {interval: {low: 5, high: 15}, data: "C"}
  let match1 = tree[1]
  // 获取第二个区间的IntervalMatch
  println(match1) // {interval: {low: 10, high: 20}, data: "A"}
```

### 📐 区间类型
支持不同类型的区间，通过`new_with_options()`方法指定。

```moonbit
  // 创建使用开区间的树
  let open_option = IntervalOptions::{
    interval_type: IntervalType::Open,
    allow_duplicates: false,
  }

  let open_tree = @IntervalTree.new_with_options(open_option)
  ignore(open_tree.insert(@IntervalTree.make_interval(10, 20), "A"))
  // 创建使用闭区间的树
  let closed_option = IntervalOptions::{
    interval_type: IntervalType::Closed,
    allow_duplicates: false,
  }

  let closed_tree = @IntervalTree.new_with_options(closed_option)
  ignore(closed_tree.insert(@IntervalTree.make_interval(10, 20), "B"))
```

### 🧠 泛型支持
区间树支持任何实现了Compare特性的类型作为区间端点，例如Float类型，String类型等。

```moonbit
  // 使用Float类型的区间
  let float_tree : T[Float, String] = @IntervalTree.new()
  let p1 = float_tree.insert(@IntervalTree.make_interval(10.5, 20.5), "A")
  assert_eq!(p1, true) //插入成功

  // 使用String类型的区间
  let string_tree : T[String, Int] = @IntervalTree.new()
  let p2 = string_tree.insert(@IntervalTree.make_interval("a", "z"), 1)
  assert_eq!(p2, true) //插入成功
```

## 📜 许可证
本项目采用Apache-2.0许可证。详情请参见LICENSE文件。

## 📢 联系与支持
• Moonbit社区：moonbit-community  
• GitHub问题：[Report an Issue](https://github.com/moonbit-community/IntervalTree/issues)

👋 如果您喜欢这个项目，请给它一个⭐！祝编码愉快！🚀