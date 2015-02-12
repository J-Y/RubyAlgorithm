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
  def bubble_sort(arr)   #FIXME awesome one
    1.upto(arr.length-1) { |i| (arr.length-i).times { |j| arr[j], arr[j+1] = arr[j+1], arr[j] if arr[j] > arr[j+1] } }
    arr
  end


# 冒泡排序
  def bubble_sort!
    f = 1
    while f < self.length
      (0...(self.length-f)).to_a.each do |i|
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
  def insertion_sort(array)   #FIXME awesome one
    array.each_with_index do |element, index|
      j = index - 1
      while j >= 0
        break if array[j] <= element
        array[j + 1] = array[j]
        j -= 1
      end
      array[j + 1] = element
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
  def selection_sort(array)
    result = []
    array.size.times do
      result << array.delete_at(array.index(array.min)) #delete_at of Array return that element deleted
    end
    result
  end


#TODO Shell排序
#百科:http://baike.baidu.com/view/549624.html?wtp=tt
#Wiki:http://zh.wikipedia.org/zh-tw/%E5%B8%8C%E5%B0%94%E6%8E%92%E5%BA%8F
  def shell_sort(array)
    gap = array.size
    while gap > 1
      gap = gap / 2
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
  def quick_sort(a)
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

#TODO ruby quiz issues
