#encoding : utf-8
/--By Jason Zhang(张艳军)--/
class RubyAlgorithm

  #TODO 二分查找（又称折半查找）是在一个有序表里查找元素的复杂度为O(log(n))的算法。先从中间位置开始比较，相等则返回，如小于中间值，则将接下来的查找范围设定为前一子表，大于则为后一子表，以下如此类推。
  # 维基百科参考：http://en.wikipedia.org/wiki/Binary_search_algorithm
  class Array
    #TODO 迭代版本(循环
    def binary_search_in_iterative num, insert = true
      min, max = 0, self.size - 1
      while min <= max
        mid = (min + max) / 2
        return mid if num == self[mid]
        num < self[mid] ? (max = mid - 1) : (min = mid + 1)
      end

      insert_item num, min, mid if insert
      nil if min > max
    end

    #TODO 递归版本（递归调用method实现）
    def binary_search_in_recursive num, insert = true, min = nil, max = nil
      min ||= 0
      max ||= self.size - 1
      mid = (min + max) / 2

      if min > max
        insert_item num, min, mid if insert
        return nil
      end

      return mid if num > self[mid]
      num > self[mid] ? (min =mid + 1) : (max = mid - 1)
      binary_search_in_recursive num, insert, min, max
    end

    def insert_item num, min, mid
      min = mid if self[min].nil?
      self[min..min] = (self[min] < num) ? [self[min], num] : [num, self[min]] #最小值处插入数组
    end
  end


  require 'benchmark'

  array = (0..6**7).to_a

  puts "数组是从0到#{array[-1]}的之间的所有整数"
  [-1, -6**3, 0, 4**5, 6**6].each do |num|
    puts "匹配#{num}"
    Benchmark.bm do |x|
      x.report("index    ") { array.index num }
      x.report("iterative") { array.binary_search_in_iterative num, false }
      x.report("recursive") { array.binary_search_in_recursive num, false }
    end
    puts
  end

#TODO most accurate binary_search
  def bin_search1(ary, start, ed, target)
    while start<=ed do
      mid = start +((ed-start)>>1) #avoid overstack,  (start&end)|((start^end)>>1) is also average value
      return mid if target == ary[mid]
      traget > ary[mid] ? (start=mid+1) : (ed=mid-1)
    end
    -1
  end


#TODO find first time that target occurs
  def bin_search2(ary, start, ed, target)
    while start < ed do
      mid = start +((ed-start)>>1) #avoid overflow,   (start&ed)|((start^ed)>>1) is also average value
      traget > ary[mid] ? (start=mid+1) : (ed=mid)
    end
    a[start]== target ? start : -1
  end


#TODO find last time that target occurs
  def bin_search3(ary, start, ed, target)
    while start<ed do
      mid = start +((ed-start+1)>>1) #avoid overflow,   (start&ed)|((start^ed)>>1) is also average value
      traget >= ary[mid] ? (start=mid) : (ed=mid-1)
    end
    ary[start]==target ? start : -1
  end


#TODO 二分查找法(已排序)
  def bin_search4(arr, value)
    low, high = 0, arr.size - 1
    while low <= high
      mid = (low + high)/2 #low +((high-low)>>1)   <===== avoid overflow
      return mid if arr[mid] == value
      arr[mid] < value ? (low = mid + 1) : (high = mid - 1)
    end
  end

#TODO 二分查找法(已排序)
  def bin_search5
    #test array and value
    a = [10, 57, 68, 70, 78, 90, 122]
    search = 78
    index, start_index, end_index = 0, 0, a.length
    while true
      index = (start_index + end_index) / 2 #same as follow: (start_index + end_index)/2
      break if a[index] == search
      a[index] < search ? (start_index = index) : (end_index = index)
    end
    puts "find by #{index}"
  end


#TODO 冒泡排序
#百科:http://baike.baidu.com/view/254413.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F
  # 冒泡排序算法的运作如下：（从后往前）
  # 比较相邻的元素。如果第一个比第二个大，就交换他们两个。
  # 对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。在这一点，最后的元素应该会是最大的数。
  # 针对所有的元素重复以上的步骤，除了最后一个。
  # 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。[1]
  def bubble_sort(arr)   #FIXME awesome one
    #最大的数最先排出来，放到最后，直到最小的元素得出
    1.upto(arr.length-1) { |i| (arr.length-i).times { |j| arr[j], arr[j+1] = arr[j+1], arr[j] if arr[j] > arr[j+1] } }
    arr
  end


# 冒泡排序
  def bubble_sort!
    f = 1
    while f < self.length
      (0...(self.length-f)).to_a.each do |i|  #equal: (0...(self.length-f)).to_a.each == (self.length-f).times
        self[i], self[i+1] = self[i+1], self[i] if self[i] > self[i+1]
      end
      f += 1
    end
    self
  end


#TODO 汉诺塔
#百科:http://baike.baidu.com/view/191666.html?wtp=tt
#Wiki: http://zh.wikipedia.org/zh-tw/%E6%B1%89%E8%AF%BA%E5%A1%94
  def hanoi(n, first, second, third)
    if n==1
      puts "#{first} move to #{third}"
    else
      hanoi(n-1, first, third, second)
      puts "#{first} move to #{third}"
      hanoi(n-1, second, first, third)
    end
  end


#TODO 插入排序
#百科:http://baike.baidu.com/view/396887.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E6%8F%92%E5%85%A5%E6%8E%92%E5%BA%8F
  # 步骤
  # ⒈从有序数列和无序数列{a2,a3，…，an}开始进行排序；
  # ⒉处理第i个元素时（i=2,3，…，n），数列{a1,a2，…，ai-1}是已有序的，而数列{ai,ai+1，…，an}是无序的。用ai与ai-1，a i-2，…，a1进行比较，找出合适的位置将ai插入；
  # ⒊重复第二步，共进行n-i次插入处理，数列全部有序。
  # 思路
  # 假定这个数组的序是排好的，然后从头往后，如果有数比当前外层元素的值大，则将这个数的位置往后挪，直到当前外层元素的值大于或等于它前面的位置为止.这具算法在排完前k个数之后，可以保证a[1…k]是局部有序的，保证了插入过程的正确性.

  # 一般来说，插入排序都采用in-place在数组上实现。具体算法描述如下：
  # ⒈ 从第一个元素开始，该元素可以认为已经被排序
  # ⒉ 取出下一个元素，在已经排序的元素序列中从后向前扫描
  # ⒊ 如果该元素（已排序）大于新元素，将该元素移到下一位置
  # ⒋ 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置
  # ⒌ 将新元素插入到下一位置中
  # ⒍ 重复步骤2~5
  # 如果比较操作的代价比交换操作大的话，可以采用二分查找法来减少比较操作的数目。该算法可以认为是插入排序的一个变种，称为二分查找排序。
  def insertion_sort(array)   #FIXME awesome one已提交百度词条
    array.each_with_index do |element, index|
      next if index == 0 #第一个元素默认已排序
      j = index - 1
      while j >= 0 && array[j] > element #查找扫描已排序的ary前j个元素，逆序直到第一个元素
        array[j + 1] = array[j] #否则把大于自己的前一个元素值赋值给后一个元素，依次后移元素直到找到元素需要插入的位置
        j -= 1
      end
      array[j + 1] = element   #根据上面循环break跳出的时候的j值，找到最后即将插入值的位置就是这个元素后的位置，赋值
    end
    array
  end

# 插入排序
  def insert_sort!
    (0...self.length).to_a.each do |j|
      key = self[j]
      i = j - 1
      while i >= 0 and self[i] > key
        self[i+1] = self[i]
        i = i-1
      end
      self[i+1] = key
    end
    self
  end


#TODO 选择排序
#百科:http://baike.baidu.com/view/547263.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E9%80%89%E6%8B%A9%E6%8E%92%E5%BA%8F
  # 选择排序（Selection sort）是一种简单直观的排序算法。它的工作原理是每一次从待排序的数据元素中选出最小（或最大）的一个元素，存放在序列的起始位置，直到全部待排序的数据元素排完。 选择排序是不稳定的排序方法（比如序列[5， 5， 3]第一次就将第一个[5]与[3]交换，导致第一个5挪动到第二个5后面）。
  def selection_sort(array)
    result = []
    array.size.times { result << array.delete_at(array.index(array.min)) } #delete_at of Array return that element deleted
    result
  end


#TODO Shell排序
#百科:http://baike.baidu.com/view/549624.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%B8%8C%E5%B0%94%E6%8E%92%E5%BA%8F
  # 希尔排序(Shell Sort)是插入排序的一种。也称缩小增量排序，是直接插入排序算法的一种更高效的改进版本。希尔排序是非稳定排序算法。该方法因DL．Shell于1959年提出而得名。
  # 希尔排序是把记录按下标的一定增量分组，对每组使用直接插入排序算法排序；随着增量逐渐减少，每组包含的关键词越来越多，当增量减至1时，整个文件恰被分成一组，算法便终止。[1]
  # 先取一个小于n的整数d1作为第一个增量，把文件的全部记录分组。所有距离为d1的倍数的记录放在同一个组中。先在各组内进行直接插入排序；然后，取第二个增量d2<d1重复上述的分组和排序，直至所取的增量 =1( < …<d2<d1)，即所有记录放在同一组中进行直接插入排序为止。
  # 该方法实质上是一种分组插入方法
  # 比较相隔较远距离（称为增量）的数，使得数移动时能跨过多个元素，则进行一次比[2] 较就可能消除多个元素交换。D.L.shell于1959年在以他名字命名的排序算法中实现了这一思想。算法先将要排序的一组数按某个增量d分成若干组，每组中记录的下标相差d.对每组中全部元素进行排序，然后再用一个较小的增量对它进行，在每组中再进行排序。当增量减到1时，整个要排序的数被分成一组，排序完成。
  # 一般的初次取序列的一半为增量，以后每次减半，直到增量为1。
  def shell_sort(array)
    gap = array.size
    while gap > 1
      gap = gap / 2  #分组对应比较，如果前面一组的对应元素大于或等于后一组的元素，则交换彼此的值
      (gap..array.size-1).each do |i|
        j = i
        while j > 0
          array[j], array[j-gap] = array[j-gap], array[j] if array[j] <= array[j-gap]
          j = j - gap
        end
      end
    end
    array
  end


#TODO 合并排序
#百科:http://baike.baidu.com/view/3668564.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%90%88%E4%BD%B5%E6%8E%92%E5%BA%8F
  # 合并排序是建立在归并操作上的一种有效的排序算法。该算法是采用分治法（Divide and Conquer）的一个非常典型的应用。
  # 合并排序法是将两个（或两个以上）有序表合并成一个新的有序表，即把待排序序列分为若干个子序列，每个子序列是有序的。然后再把有序子序列合并为整体有序序列。
  # 将已有序的子序列合并，得到完全有序的序列；即先使每个子序列有序，再使子序列段间有序。若将两个有序表合并成一个有序表，称为2-路归并。合并排序也叫归并排序。
# def merge(l, r)
#   result = []
#   while l.size > 0 and r.size > 0 do
#     result << (l.first < r.first ? l.shift : r.shift)
#   end
#   result += l if l.size > 0
#   result += r if r.size > 0
#   result
# end

  def merge_sort(array)
    return array if array.size <= 1
    middle = array.size / 2
    left = merge_sort(array[0, middle])
    right = merge_sort(array[middle, array.size - middle])
    result = []
    #merge left and right portion
    while left.size > 0 && right.size > 0 do
      result << (left.first < right.first ? left.shift : right.shift)
    end
    result += left if left.size > 0
    result += right if right.size > 0
    result
  end

# 合并排序
  def merge_sort!
    return self if self.size <= 1
    left = self[0, self.size/2]
    right = self[self.size/2, self.size - self.size/2]
    Array.merge(left.merge_sort, right.merge_sort)
  end

  def self.merge(left, right)
    sorted = []
    until left.empty? or right.empty?
      sorted << (left.first <= right.first ? left.shift : right.shift)
    end
    sorted + left + right
  end


#TODO 堆排序
#百科:http://baike.baidu.com/view/157305.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%A0%86%E6%8E%92%E5%BA%8F
  # 堆排序(Heapsort)是指利用堆积树（堆）这种数据结构所设计的一种排序算法，它是选择排序的一种。可以利用数组的特点快速定位指定索引的元素。堆分为大根堆和小根堆，是完全二叉树。大根堆的要求是每个节点的值都不大于其父节点的值，即A[PARENT[i]] >= A[i]。在数组的非降序排序中，需要使用的就是大根堆，因为根据大根堆的要求可知，最大的值一定在堆顶。
  def heapify(a, idx, size)
    left_idx = 2 * idx + 1
    right_idx = 2 * idx + 2
    bigger_idx = idx
    bigger_idx = left_idx if left_idx < size && a[left_idx] > a[idx]
    bigger_idx = right_idx if right_idx < size && a[right_idx] > a[bigger_idx]
    if bigger_idx != idx
      a[idx], a[bigger_idx] = a[bigger_idx], a[idx]
      heapify(a, bigger_idx, size)
    end
  end

  def build_heap(a)
    last_parent_idx = a.length / 2 - 1
    i = last_parent_idx
    while i >= 0
      heapify(a, i, a.size)
      i = i - 1
    end
  end

  def heap_sort(a)
    return a if a.size <= 1
    size = a.size
    build_heap(a)
    while size > 0
      a[0], a[size-1] = a[size-1], a[0]
      size = size - 1
      heapify(a, 0, size)
    end
    a
  end

# heap排序
  def heap_sort!
    # in pseudo-code, heapify only called once, so inline it here
    ((length - 2) / 2).downto(0) {|start| siftdown(start, length - 1)}

    # "end" is a ruby keyword
    (length - 1).downto(1) do |end_|
      self[end_], self[0] = self[0], self[end_]
      siftdown(0, end_ - 1)
    end
    self
  end

  def siftdown(start, end_)
    root = start
    loop do
      child = root * 2 + 1
      break if child > end_
      if child + 1 <= end_ and self[child] < self[child + 1]
        child += 1
      end
      if self[root] < self[child]
        self[root], self[child] = self[child], self[root]
        root = child
      else
        break
      end
    end
  end


#TODO 快速排序
#百科:http://baike.baidu.com/view/115472.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%BF%AB%E9%80%9F%E6%8E%92%E5%BA%8F
  # 通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，整个排序过程可以递归进行，以此达到整个数据变成有序序列。
  def quick_sort(a) #已加入百度磁条
    (x=a.pop) ? quick_sort(a.select { |i| i <= x }) + [x] + quick_sort(a.select { |i| i > x }) : []
  end

  def quick_sort!
    return [] if self.empty?
    x, *a = self  #self is array, 并行赋值：x位数组的第一个元素；a为除去第一个元素之外为剩余的array
    left, right = a.partition{|t| t < x} #剩余的数组分区，与第一个元素比较，小于的分为一组大于等于为另外一组array
    left.quick_sort! + [x] + right.quick_sort!  #递归调用直至最终排序完成
  end

# Simple/dumb QuickSort in RubyLanguage, choosing the first element as pivot.
  def qsort(list)
    return [] if list.size == 0
    x, *xs = *list
    less, more = xs.partition { |y| y < x }
    qsort(less) + [x] + qsort(more)
  end
# Slightly less readable but hey, we save a line :P
def qs(l)
  return [] if (x,*xs=l).empty?
  less, more = xs.partition{|y| y < x}
  qs(less) + [x] + qs(more)
end

# Slightly more readable, and hey, we save two lines.
  def quicksort a
    (pivot = a.pop) ? quicksort(a.select { |i| i <= pivot }) + [pivot] + quicksort(a.select { |i| i > pivot }) : []
  end
# But that, of course, is much too inefficient because it doesn't use partition.



#TODO 计数排序
#百科:http://baike.baidu.com/view/1209480.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E8%AE%A1%E6%95%B0%E6%8E%92%E5%BA%8F
  # 计数排序对输入的数据有附加的限制条件：
  # 1、输入的线性表的元素属于有限偏序集S；
  # 2、设输入的线性表的长度为n，|S|=k（表示集合S中元素的总数目为k），则k=O(n)。
  # 在这两个条件下，计数排序的复杂性为O(n)。
  # 计数排序的基本思想是对于给定的输入序列中的每一个元素x，确定该序列中值小于x的元素的个数。一旦有了这个信息，就可以将x直接存放到最终的输出序列的正确位置上。例如，如果输入序列中只有17个元素的值小于x的值，则x可以直接存放在输出序列的第18个位置上。当然，如果有多个元素具有相同的值时，我们不能将这些元素放在输出序列的同一个位置上，因此，上述方案还要作适当的修改。
  # 假设输入的线性表L的长度为n，L=L1,L2,..,Ln；线性表的元素属于有限偏序集S，|S|=k且k=O(n)，S={S1,S2,..Sk}；则计数排序可以描述如下：
  # 1、扫描整个集合S，对每一个Si∈S，找到在线性表L中小于等于Si的元素的个数T(Si)；
  # 2、扫描整个线性表L，对L中的每一个元素Li，将Li放在输出线性表的第T(Li)个位置上，并将T(Li)减1。
  def counting_sort(array)
    min, max = array.min, array.max
    counts = Array.new(max-min+1, 0)
    array.each do |n|
      counts[n-min] += 1
    end
    (0...counts.size).map { |i| [i+min]*counts[i] }.flatten
  end


#TODO 基數排序
#百科:http://baike.baidu.com/view/1170573.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%9F%BA%E6%95%B0%E6%8E%92%E5%BA%8F
  # 基数排序法又称“桶子法”（bucket sort）或bin sort，顾名思义，它是透过键值的部份资讯，将要排序的元素分配至某些“桶”中，藉以达到排序的作用，基数排序法是属于稳定性的排序，其时间复杂度为O (nlog(r)m)，其中r为所采取的基数，而m为堆数，在某些时候，基数排序法的效率高于其它的稳定性排序法。
  def kth_digit(n, i)
    while i > 1
      n = n / 10
      i = i - 1
    end
    n % 10
  end

  def radix_sort(array)
    max = array.max
    d = Math.log10(max).floor + 1
    (1..d).each do |i|
      tmp = []
      (0..9).each do |j|
        tmp[j] = []
      end
      array.each do |n|
        kth = kth_digit(n, i)
        tmp[kth] << n
      end
      array = tmp.flatten
    end
    array
  end


#TODO 桶排序
#百科:http://baike.baidu.com/view/1784217.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E6%A1%B6%E6%8E%92%E5%BA%8F
  # 桶排序 (Bucket sort)或所谓的箱排序，是一个排序算法，工作的原理是将数组分到有限数量的桶子里。每个桶子再个别排序（有可能再使用别的排序算法或是以递归方式继续使用桶排序进行排序）。桶排序是鸽巢排序的一种归纳结果。当要被排序的数组内的数值是均匀分配的时候，桶排序使用线性时间（Θ（n））。但桶排序并不是 比较排序，他不受到 O(n log n) 下限的影响。
  def quick_sort1(a)
    (x=a.pop) ? quick_sort1(a.select { |i| i <= x }) + [x] + quick_sort1(a.select { |i| i > x }) : []
  end

  def bucket_sort(a)
    tmp = []
    (0..9).each do |j|
      tmp[j] = []
    end
    a.each do |n|
      k = (n * 10).to_i
      tmp[k] << n
    end
    (0..9).each do |j|
      tmp[j] = quick_sort1(tmp[j])
    end
    tmp.flatten
  end
end

#TODO 鸡尾酒排序(>_<)
#wikipedia 详解: http://en.wikipedia.org/wiki/Cocktail_sort
# 使用鸡尾酒排序为一列数字进行排序的过程可以通过右图形象的展示出来：
# 数组中的数字本是无规律的排放，先找到最小的数字，把他放到第一位，然后找到最大的数字放到最后一位。然后再找到第二小的数字放到第二位，再找到第二大的数字放到倒数第二位。以此类推，直到完成排序。
def cocktail_sort!
  f  = 0
  while f < self.length/2
    i = 0
    while i < self.length - 1
      self[i], self[i+1] = self[i+1], self[i] if self[i] > self[i+1]
      i += 1;
    end
    t = self.length - 1
    while t > 0
      self[t], self[t-1] = self[t-1], self[t] if self[t] < self[t-1]
      t -= 1
    end
    f += 1
  end
  self
end



%w(insert quick bubble cocktail merge heap).each do |metd|
  define_method("#{metd}_sort") do  #定义method
    self.dup.send("#{metd.to_s}_sort!")  #excute method
  end
end


#TODO 2048 算法
#FIXME 实现1
require 'optparse'
module Help
  HELP_TEXT =<<HELP
press buttons for move
  l => move to left
  r => move to right
  t => move to top
  b => move to bottom
press e button to exit game
you can see this help text if your input ruby ruby_2048.rb --help
HELP

  def set_helps
    OptionParser.new do |opts|
      opts.on_tail("-h", "--help", 'This help text.') do
        puts HELP_TEXT
        exit!
      end
    end.parse!
  end
end
class Object
  def invoke(need, method)
    if need
      self.send(method)
    else
      self
    end
  end
end
class R2048
  extend Help
  attr_reader :chessboard
  LEFT = "l"
  RIGHT = "r"
  TOP = "t"
  BOTTOM = "b"
  EXIT = "e"

  def initialize
    R2048.set_helps
    @chessboard = Array.new(4) { |x| Array.new(4) { |y| 0 } }
    @init_moved = false
    1.upto(2) { |i| generate_init_num }
  end

  def generate_init_num
    return false unless @chessboard.flatten.uniq.select { |chess| chess == 0 }.count > 0
    rand_position = rand(16)
    x, y = rand_position/4, rand_position % 4
    until @chessboard[x][y] == 0
      rand_position = rand(16)
      x, y = rand_position/4, rand_position % 4
    end
    @chessboard[x][y] = [2, 4][rand(2)]
  end

  def check_and_merge(transpose, reverse)
    moved = false
    temp_chessboard = @chessboard.invoke(transpose, :transpose).map do |row|
      reversed_row = set_jump_step(row.invoke(reverse, :reverse)).invoke(reverse, :reverse)
      moved = true if reversed_row != row.invoke(reverse, :reverse)
      reversed_row
    end.invoke(transpose, :transpose)
    if moved
      @chessboard = temp_chessboard
      true
    else
      if !@init_moved
        @init_moved = true
        true
      else
        false
      end
    end
  end

  def generate_new_num(transpose, pos)
    ungenerated = true
    right_positions = []
    @chessboard.invoke(transpose, :transpose).each_with_index { |row, i| right_positions << i if row[pos] == 0 }
    right_position = right_positions[rand(right_positions.count)]
    row_index = 0
    @chessboard = @chessboard.invoke(transpose, :transpose).map do |row|
      if ungenerated && row_index == right_position
        ungenerated = false
        row[pos] = [2, 4][rand(2)]
      end
      row_index += 1
      row
    end.invoke(transpose, :transpose)
    !ungenerated
  end

  def set_jump_step(row)
    pured = row.select { |chess| chess != 0 }.inject([]) do |sum, chess|
      if sum.last == chess
        sum.pop
        sum << chess * 2
      else
        sum << chess
      end
    end
    pured.concat Array.new(4 - pured.count, 0)
  end

  def display
    puts "==============================="
    @chessboard.each_with_index do |c, row|
      puts "#{c[0]}  #{c[1]}  #{c[2]}  #{c[3]}"
      puts
    end
  end

  def failure_display
    puts "you have failed!!!"
  end

  def run
    display
    key = nil
    until key.gsub!(/\n|\r/, "") == "e"  #should remove \n \r
      key = gets
      key.gsub!(/\n|\r/, "")
      return if key == EXIT
      unless %w(LEFT, RIGHT, TOP, BOTTOM).include? key
        puts "input invalid characters"
        next
      end
      generate = case key
                   when LEFT
                     if check_and_merge(false, false)
                       generate_new_num(false, 3)
                     else
                       nil
                     end
                   when RIGHT
                     if check_and_merge(false, true)
                       generate_new_num(false, 0)
                     else
                       nil
                     end
                   when TOP
                     if check_and_merge(true, false)
                       generate_new_num(true, 3)
                     else
                       nil
                     end
                   when BOTTOM
                     if check_and_merge(true, true)
                       generate_new_num(true, 0)
                     else
                       nil
                     end
                   else
                     nil
                 end
      if generate == nil || generate
        display
      else
        failure_display
        return
      end
    end
  end
end
R2048.new.run

#FIXME 实现2

$score = 0
$changed = false

lines  = []; 4.times { lines << [nil, nil, nil, nil] }

helper        = -> {
  puts "┌───────────────┐"
  puts "│ Use your keyborad.           │"
  puts "│ W: Up A:Left S:Down D:Right  │"
  puts "│ Return: Next step            │"
  puts "└───────────────┘"
}

score         = -> {
  puts "┌───────────────┐"
  puts "│Score:        #{"%016d" % $score}│"
  puts "└───────────────┘"
}

header        = -> { puts "┌───┬───┬───┬───┐" }
block         = -> n { "_#{"_" * (4 - n.to_s.length)}#{n}_│" }
liner         = -> a { s = "│" ; a.each {|i| s += block.call i }; puts s}
footer        = -> { puts "└───┴───┴───┴───┘" }

new_num = -> {
  loop do
    x, y = rand(4), rand(4)
    if lines[x][y].nil?
      lines[x][y] = rand < 0.8 ? 2 : 4
      break
    end
  end
}

start = -> { 2.times { new_num.call } }

restart = -> {
  loop do
    puts "Play again? (Y/N)"
    str = gets
    case str.rstrip.to_sym
      when :Y, :y
        lines.clear; 4.times { lines << [nil, nil, nil, nil] }
        $score = 0; new_num.call
        break
      when :N, :n; exit; end
  end
}

game_over     = -> {
  puts "┌───────────────┐"
  puts "│          Game Over!          │"
  puts "└───────────────┘"
  restart.call
}

congratulations = -> {
  puts "┌───────────────┐"
  puts "│Congrulations!You've got 2048!│"
  puts "└───────────────┘"
  restart.call
}

refresh = -> { score.call; header.call; lines.each {|l| liner.call l }; footer.call}

complement = -> l { (4 - l.size).times { l << nil } if l.size < 4 }

arrange = -> line {#, size {
  case line.size
    # when 0, 1
    when 2
      if line[0] == line[1]
        line[0] += line[1]; line[1] = nil; $score += line[0]
      end
    when 3
      if line[0] == line[1]
        line[0] += line[1]; line[1], line[2] = line[2], nil; $score += line[0]
      elsif line[1] == line[2]
        line[1] += line[2]; line[2] = nil; $score += line[1]
      end
    when 4
      if line[0] == line[1]
        line[0] += line[1]; line[1], line[2], line[3] = line[2], line[3], nil; $score += line[0]
      end
      if line[1] == line[2]
        line[1] += line[2]; line[2], line[3] = line[3], nil; $score += line[1]
      end
      if !line[2].nil? && line[2] == line[3]
        line[2] += line[3]; line[3] = nil; $score += line[2]
      end
  end
}

process = -> args {
  rows = []
  if args[0]
    rows = lines
  else
    4.times { |i| rows << [ lines[3][i], lines[2][i], lines[1][i], lines[0][i] ] }
  end
  rows.each do |row|
    row.reverse! if args[1]
    row.compact!
    arrange.call row
    complement.call row
    row.reverse! if args[1]
    4.times { |i| lines[3][i], lines[2][i], lines[1][i], lines[0][i] = rows[i] } unless args[0]
  end
}

left  = -> { process.call [ true, false] }
down  = -> { process.call [false, false] }
right = -> { process.call [ true,  true] }
up    = -> { process.call [false,  true] }

check = -> {
  lines.each { |l| l.each { |b| congratulations.call if b == 2048 } }
  size = 0; lines.each { |line| size += line.compact.size }
  game_over.call if size == 16
}

game = -> {
  helper.call
  start.call
  loop do
    $nums  = 0
    image = []; lines.each { |l| image << l.clone }
    refresh.call
    str = gets
    case str.rstrip.to_sym
      when :a; left.call
      when :s; down.call
      when :d; right.call
      when :w; up.call;
      else next; end
    check.call
    new_num.call if image != lines
  end
}

game.call

#FIXME 实现3 （precise but lack of some judgements）
class Game2048
  def initialize
    @array = 4.times.map { [ nil ] * 4 }  #new 4-d array
    2.times { fill } #随机填充两个数字，不同行不同列
  end

  def fill
    i, j = rand(4), rand(4)
    return fill if @array[i][j]
    @array[i][j] = [2, 2, 2, 2, 4].shuffle.first #随机洗牌数组然后选择第一个元素
  end

  def move(direction)
    p "orginal array is : #{@array}"
    @array = @array.transpose if %w[up down].include?(direction) #只有向上向下移动的时候要转置为行来处理每个cell的值相加等等
    p "transpose array is : #{@array}"
    @array.each(&:reverse!) if %w[right down].include?(direction) #向右移动或者向下移动的时候转置过后顺序是颠倒的所以需要reverse一下
    p "reverse array is : #{@array}"
    #FIXME 计算顺序默认为向左移动的时候情况
    4.times do |i|
      a = @array[i].compact
      4.times { |x| a[x], a[x + 1] = a[x] * 2, nil if a[x].to_i == a[x + 1] } unless a.empty? #去空然后判断相邻元素如果相等则对应元素*2，后一个元素置空
      @array[i] = a.compact.concat([ nil ] * 4)[0..3] #补全为4个元素
    end
    p "after cycle array is : #{@array}"
    @array.each(&:reverse!) if %w[right down].include?(direction)
    p "reverse! array is : #{@array}"
    @array = @array.transpose if %w[up down].include?(direction)
    p "transpose array is : #{@array}"
  end

  def play
    puts @array.map { |line| "[%5s] " * 4 % line }  #FIXME 生成四行四列矩阵
    move({ a: 'left', s: 'down', d: 'right', w: 'up' }[gets.strip.to_sym])
    fill && play if @array.flatten.include?(nil)
  end
end

Game2048.new.play


#TODO 生肖计算器
# 记得自己出生的年份是什么生肖，然后12年以内的就按十二生肖排序来算。12年以外的就加上12的倍数。比如1985年是属牛，那2015年就是（2015-1985）/12=2余数6。2015年就是牛年后面第六个生肖。（鼠牛虎兔龙蛇马羊猴鸡狗猪）属羊。为什么选择2008呢，因为08年是鼠年，正好是数组的第一个元素，选择2020也是可以的哦，大于2008年则正向数，反之则倒着数. . 很简单吧，来看看代码吧：

#encoding: utf-8
require "rubygems"
def zodiac year
  zodiacs = %w(鼠, 牛, 虎, 兔, 龙, 蛇, 马, 羊, 猴, 鸡, 狗, 猪)
               #MCTRDS HSMCDP
  if year > 2008
    zodiacs[(year - 2008) % 12];
  else
    zodiacs[(12-(2008 - year))%12];
  end
end
puts zodiac(2008) # 鼠
puts zodiac(1987) # 兔
puts zodiac(1982) # 狗

# 下面来揭晓改进后的代码：
#encoding: utf-8
require "rubygems"
def nzodiac year
  zodiacs = %w(鼠, 牛, 虎, 兔, 龙, 蛇, 马, 羊, 猴, 鸡, 狗, 猪)
  zodiacs[(year - 2008) % 12]
end
# 只有一句话就搞定了？ it's amazing！其实最大的问题再于求余计算上
# 在java种 -1 % 12的余数是－1
# 而在ruby和 python种 -1 % 12 的余数为11
# 这个特性用在数组元算的选择上就显得非常巧妙


# 有一个数组,包含16个数字。仅用each方法打印数组中的内容,一次打印4个数字。然后, 用可枚举模块的each_slice方法重做一遍
# 我想问如何仅用each实现each_slice的功能
# 1.
    (1..16).to_a.each_with_index{|n,i|print"#{n}#{(i+1)%4==0?"\n":","}"}
#Only use each here:
# 2.
    (array=(1..16).to_a).each{|n|print"#{n}#{(array.index(n)+1)%4==0?"\n":","}"}

# 3.
    module Enumerable
def i_each_slice(n, &block)
  raise "invalid slice size" if n <= 0

  i, ary = 0, []

  each do |a|
    ary << a
    i += 1
    if i >= n
      yield ary
      i, ary = 0, []
    end
  end

  yield ary if i > 0
end
end

(1..10).i_each_slice(3) { |a| p a }

# 输出
# [1, 2, 3]
# [4, 5, 6]
# [7, 8, 9]
# [10]

# 4
module Enumerable
  def i_each_slice(n)
    raise "invalid slice size" if n <= 0

    result, i = [], 1

    self.each do |ele|
      index = (i / n.to_f).ceil
      result[index].nil? ? result[index] = [ele] : result[index] << ele
      i += 1
    end

    result[1..-1].each { |ele| yield ele }
  end
end

['a', 'b', 'c', 'd', 'e', 1, 2, 3, 4, 5].i_each_slice(3) { |i| p i }
# =>
# ["a", "b", "c"]
# ["d", "e", 1]
# [2, 3, 4]
# [5]


#TODO array powerset集合的幂集，是集合的所有可能子集，包括空集和集合本身，存在2^n个子集
class Array
  def powerset
    num = 2**size  #幂集的大小
    ps = Array.new(num,[])
    self.each_index do |i|
      a=2**i
      b=2**(i+1)-1
      j=0
      while j< num-1
        for j in j+a..j+b
          ps[j]+=[self[i]]
        end
        j+=1
      end
    end
    ps
  end
end

#TODO Aha algorithm

#TODO ruby quiz issues
