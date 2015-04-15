#HACK Ruby & Rails Tips
#TODO 1.生成二维数组然后flatten成一维数组
approval_workflow_ranks.where(rank: rank).map { |r| r.all_users.map(&:id) }.flatten

#TODO 2.构建where condition query: terms_ary是search的条件string
#批量赋值，占位符再赋值，适用于单个column
UnitConversion.where(terms_ary.map { |term| "product_description ilike ?" }.join(' AND '), *(terms_ary.map { |t| "%#{t}%" }))
#for example,if we need to match 2 columns or more for same condition that user inputs then we should chain each part with or clause, like the following 2 implements below: generate querylike below:
# "(column1 ilike '%a%' AND column1 ilike '%b%' AND column1 ilike '%c%') OR (column2 ilike '%a%' AND column2 ilike '%b%' AND column2 ilike '%c%')"
UnitConversion.where(%w(column1 column2).map { |column| terms_ary.map { |term| "#{column} ilike '%#{term}%'" }.join(' AND ') }.map { |sub_query| "(#{sub_query})" }.join (" OR "))
UnitConversion.where(%w(column1 column2).map { |column| "("+terms_ary.map { |term| "#{column} ilike '%#{term}%'" }.join(' AND ')+")" }.join (" OR "))
UnitConversion.where(%w(column1 column2).map { |column| "(#{terms_ary.map { |term| "#{column} ilike '%#{term}%'" }.join(' AND ')})" }.join (" OR "))

#TODO 3.inject 使用
# inject(initial, sym) → obj click to toggle source
# inject(sym) → obj
# inject(initial) { |memo, obj| block } → obj
# inject { |memo, obj| block } → obj

#Combines all elements of enum by applying a binary operation, specified by a block or a symbol that names a method or operator.
# If you specify a block, then for each element in enum the block is passed an accumulator value (memo) and the element. If you specify a symbol instead, then each element in the collection will be passed to the named method of memo. In either case, the result becomes the new value for memo. At the end of the iteration, the final value of memo is the return value for the method.
# Sum some numbers
(5..10).reduce(:+) #=> 45
# Same using a block and inject
(5..10).inject { |sum, n| sum + n } #=> 45
# Multiply some numbers
(5..10).reduce(1, :*) #=> 151200
# Same using a block
(5..10).inject(1) { |product, n| product * n } #=> 151200
# find the longest word
longest = %w{ cat sheep bear }.inject do |memo, word|
  memo.length > word.length ? memo : word
end  #longest                                        #=> "sheep"

%w(a b c).each_with_index.inject([]) { |result, (value, index)| result << value + index.to_s } #result => ["a0", "b1", "c2"]

#p+ 计算total value
def recalculate_totals
  self.total_value = (purchase_order_line_items.map(&:line_total).inject { |sum, x| sum + x } || 0) + delivery_charge_ex_tax + delivery_charge_tax
end

def line_item_total_ex_tax
  purchase_order_line_items.map.inject(0) { |sum, l| sum + (l.line_total - l.line_tax) }
end

def attributes
  %w(description unit_price tax_amount ordered_quantity quantity_to_receive).inject({}) { |h, a| h.merge Hash[a.to_sym, self.send(a.to_sym)] }
end

#Hash 新建
Hash["a", 100, "b", 200];   Hash["a" => 100, "b" => 200] #=> {"a"=>100, "b"=>200}
Hash[[["a", 100], ["b", 200]]] #=> {"a"=>100, "b"=>200}，此时不需要flatten亦可以

h = Hash.new("Go Fish")
h["a"] = 100
h["b"] = 200
h["a"] #=> 100
h["c"] #=> "Go Fish"
# The following alters the single default object
h["c"].upcase! #=> "GO FISH"
h["d"] #=> "GO FISH"
h.keys #=> ["a", "b"]

# While this creates a new default object each time
h = Hash.new { |hash, key| hash[key] = "Go Fish: #{key}" }
h["c"] #=> "Go Fish: c"
h["c"].upcase! #=> "GO FISH: C"
h["d"] #=> "Go Fish: d"
h.keys #=> ["c", "d"]

def t(locale, contexts, options={})
  lts = translations_grouped_by_locale(locale, contexts)
  contexts.map do |c|
    unless c.locale == locale.to_s
      ts = lts[locale.to_s] || lts[options[:preferred_default_locale] || 'en'] || []
      #TODO 联合使用，注意*使用
      c.assign_attributes({:locale => locale}.merge Hash[*(ts.select { |s| s.context_type == c.class.name && s.context_id == c.id }.map { |s| [s.descriptor, s.value] }.flatten)])
    end
    c
  end
end

#TODO 4.联合查询
def available_owners organisation_id, user_id
  if Organisation.get_marketboomer.id == organisation_id.to_i
    OrganisationTranslation.verified_organisation
  else
    OrganisationTranslation.by_user_with_groups(user_id) #Attention here map usage
  end.select('organisation_translations.name, organisation_translations.organisation_id').order('organisation_translations.name asc').map { |o| {:id => o.organisation_id, :name => o.name} }.uniq
end

#TODO 5.多参数赋值（*）
def all_for(contexts)
  where (['(context_type = ? and context_id =?)'] * contexts.size).join(' OR '), *(contexts.map { |c| [c.class.name, c.id] }.flatten)
end

#TODO 6. search text
def _search_text
  [_concatenated_brand,
   _concatenated_description,
   _concatenated_sell_unit,
   classic_mbid
  ].compact.map { |w| w.hanize.split(' ') }.flatten.uniq.reject { |w| w.size < 3 || self.class.stop_words.include?(w) }.join(' ')
end

#TODO 7.动态生成 methods
def custom_fields locale
  (1..6).map { |n| CustomField.by_key_and_locale(self.send("custom_field_key#{n}"), locale) unless self.send("custom_field_key#{n}").nil? }.compact!
end

#TODO 8.预载入 association，joins与includes同时使用(Attention!!,应该有更好的实现)
def available_unit_conversions params
  select("good_data_unit_conversions.id as uc_id,source_id,source.concatenated_description as source_description,destination_id,destination.concatenated_description as destination_description,rate")
      .joins("inner join goods_products source on source.id=good_data_unit_conversions.source_id")
      .joins("inner join goods_products destination on destination.id=good_data_unit_conversions.destination_id")
      .includes(:source_product, :destination_product)
      .condition_search(params[:product_description]).order("source_description,destination_description")
end

#TODO 9.只 select需要的字段
def sample
#TODO Permission.select(:id).find_by_name("super users role").id 加快查询速度
  if ppap.permission.id == Permission.select(:id).find_by_name("super users role").id || ppap.permission.id == Permission.select(:id).find_by_name("marketboomer catalogue user role").id
  end
end

#TODO 10.
def organisations_in_groups(o_ids)
  Organisation.joins(:organisation_groups).where(:organisation_groups => {:id => OrganisationGroup.joins(:organisations).where(:organisations => {:id => o_ids})}).distinct.to_a
end

def by_user_with_groups(user_id)
  where(:organisation_id => (Organisation.joins(:organisation_groups => {:organisations => :user_organisations}).where(:user_organisations => {:user_id => user_id}).pluck('organisations.id') +
            UserOrganisation.where(:user_id => user_id).pluck(:organisation_id)).uniq).where(:locale => I18n.locale)
end

#TODO 11.fuzzy search cols(map条件)
Organisation.columns_hash.reject do |k, v|
  ['search_text', 'locale', 'slug'].include?(v.name) || (v.name.split('_').first == 'concatenated') || ![:string, :text].include?(v.type)
end.map { |k, v| k }

def fuzzy_search_cols
  # Returns a hash of column objects for the table associated with this class.
  columns_hash.reject do |k, v|
    ['search_text', 'locale', 'slug'].include?(v.name) || (v.name.split('_').first == 'concatenated') || ![:string, :text].include?(v.type)
  end.map { |k, v| k }
end

def default_targets default_sort
  default_sort.to_s.split(/,/).map do |order_string|
    m = order_string.match(SQL_REGEX)
    m[2] || m[1] if m
  end.compact.reject { |c| attribute_names.include?(c) }
end

# IO.select(read_array
# [, write_array
# [, error_array
# [, timeout]]]) -> array  or  nil
#
# Calls select(2) system call.
# It monitors given arrays of <code>IO</code> objects, waits one or more
# of <code>IO</code> objects ready for reading, are ready for writing,
# and have pending exceptions respectably, and returns an array that
# contains arrays of those IO objects.  It will return <code>nil</code>
# if optional <i>timeout</i> value is given and no <code>IO</code> object
# is ready in <i>timeout</i> seconds.
#
# === Parameters
# read_array:: an array of <code>IO</code> objects that wait until ready for read
# write_array:: an array of <code>IO</code> objects that wait until ready for write
# error_array:: an array of <code>IO</code> objects that wait for exceptions
# timeout:: a numeric value in second
#
# === Example
#
#     rp, wp = IO.pipe
#     mesg = "ping "
#     100.times {
#       rs, ws, = IO.select([rp], [wp])
#       if r = rs[0]
#         ret = r.read(5)
#         print ret
#         case ret
#         when /ping/
#           mesg = "pong\n"
#         when /pong/
#           mesg = "ping "
#         end
#       end
#       if w = ws[0]
#         w.write(mesg)
#       end
#     }
#
# <em>produces:</em>
#
#     ping pong
#     ping pong
#     ping pong
#     (snipped)
#     ping
def select(p1, p2 = v2, p3 = v3, p4 = v4)
  #This is a stub, used for indexing
end

def select_clause(sort, default_sort)
  all_targets = ["#{self.table_name}.*", order_targets(sort)] + default_targets(default_sort)
  select all_targets.reject(&:blank?).join(',')
end

#TODO 12.扩展String,定义hanize方法
class String
  def hanize
    self.split("").map { |c| c.contains_cjk? ? "#{c}^" : c }.join
  end

  def contains_cjk?
    !!(self =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/)
  end
end

#TODO 13.
# Concatenate all text or string values that arent concatenations, put them in search_text and hanize
def concatenate
  cols = self.class.columns_hash.reject do |k, v|
    v.name.in?(['search_text', 'locale', 'slug']) || (v.name.split('_').first == 'concatenated') || !v.type.in?([:string, :text])
  end
  self.search_text = cols.map { |k, v| send(v.name).to_s }.reject(&:blank?).join(' ').hanize
end

#TODO 14.元编程法术手册
#FIXME Argument Array 参数数组，把一组参数读进数组
#  Collapse a list of arguments into an array.
def my_method1(*args)  #array as a arguments
  args.map { |arg| arg.reverse }
end

#my_method1('abc' , 'xyz' , '123' ) # => ["cba", "zyx", "321"]
#FIXME Around Alias 环绕别名
# Call the previous, aliased version of a method from a redefined method.
class String
  alias :old_reverse :reverse #TODO alias here is not method but key word
        #new method  # old method
  def reverse
    "x#{old_reverse}x"
  end
end
# "abc".reverse # => "xcbax" (1.define alias;2.redefine reverse and call aligned m ethod)
#FIXME Blank Slate  白板方法
# Remove methods from an object to turn them into Ghost Methods (73).
class Class1
  def method_missing(name, *args)
    "a Ghost Method"
  end
end
obj = Class1.new
obj.to_s # => "#<C:0x357258>"

class Class1
  instance_methods.each do |m|
    undef_method m unless m.to_s =~ /method_missing|respond_to?|^__/  #keep method_missing respond_to? and keep word __*
  end
end
obj.to_s # => "a Ghost Method"   call method_missing here
#FIXME Class Extension 类扩展
# Define class methods by mixing a module into a class’s eigenclass (a special case of Object Extension (151)).
class Class2;
end
module Moudle1
  def my_method
    'a class method'
  end
end
class << Class2
  include M  #M mehods as Class Method
end
Class2.my_method # => "a class method"
#FIXME Class Extension Mixin 类扩展混入
# Enable a module to extend its includer through a Hook Method (181).
module Moudle2
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def my_method
      'a class method'
    end
  end
end
class Class3
  include Moudle2  #类似 类扩展
end
Class3.my_method # => "a class method"
#FIXME Class Instance Variable 类实例变量
# Store class-level state in an instance variable of the Class object.
class Class3
  @my_class_instance_variable = "some value"

  def self.class_attribute
    @my_class_instance_variable
  end
end
Class3.class_attribute # => "some value"
#FIXME Class Macro 类宏
# Use a class method in a class definition.
class Class4
end
class << Class4
  def my_macro(arg)
    "my_macro(#{arg}) called"
  end
end
class Class4
  my_macro :x # => "my_macro(x) called"
end
#FIXME Clean Room 洁净室
# Use an object as an environment in which to evaluate a block.
class CleanRoom
  def a_useful_method(x)
      x * 2;
  end
end
CleanRoom.new.instance_eval { a_useful_method(3) } # => 6
#FIXME Code Processor 代码处理器
# Process Strings of Code (163) from an external source.
File.readlines("a_file_containing_lines_of_ruby.txt").each do |line|
  puts "#{line.chomp} ==> #{eval(line)}"
end
# >> 1 + 1 ==> 2
# >> 3 * 2 ==> 6
# >> Math.log10(100) ==> 2.0
#FIXME Context Probe 上下文探针
# Execute a block to access information in an object’s context.
class Class5
  def initialize
    @x = "a private instance variable"
  end
end
obj = Class5.new
obj.instance_eval { @x } # => "a private instance variable"
#FIXME Deferred Evaluation 延迟执行
# Store a piece of code and its context in a proc or lambda for evaluation later.
class Class6
  def store(&block)
    @my_code_capsule = block
  end

  def execute
    @my_code_capsule.call
  end
end
obj = Class6.new
obj.store { $X = 1 }
$X = 0
obj.execute
$X # => 1
#FIXME Dynamic Dispatch 动态派发
# Decide which method to call at runtime.
method_to_call = :reverse
obj = "abc"
obj.send(method_to_call) # => "cba" 动态执行
#FIXME Dynamic Method 动态定义方法
# Decide how to define a method at runtime.
class Class6
end
Class6.class_eval do
  define_method :my_method do
    "a dynamic method"
  end
end
obj = Class6.new
obj.my_method # => "a dynamic method"
#FIXME Dynamic Proxy 动态代理
# Forward to another object any messages that don’t match a method.
class MyDynamicProxy
  def initialize(target)
    @target = target
  end

  def method_missing(name, *args, &block)
    "result: #{@target.send(name, *args, &block)}"
  end
end
obj = MyDynamicProxy.new("a string")
obj.reverse # => "result: gnirts a"
#FIXME Flat Scope 扁平化作用域
# Use a closure to share variables between two scopes.
class Class6
  def an_attribute
    @attr
  end
end
obj = Class6.new
a_variable = 100
# flat scope:
obj.instance_eval do
  @attr = a_variable
end
obj.an_attribute # => 100
#FIXME Ghost Method 幽灵方法
# Respond to a message that doesn’t have an associated method.
class Class7
  def method_missing(name, *args)
    name.to_s.reverse
  end
end
obj = Class7.new
obj.my_ghost_method # => "dohtem_tsohg_ym"
#FIXME Hook Method 钩子方法
# Override a method to intercept object model events.
$INHERITORS = []
class Class7
  def self.inherited(subclass)
    $INHERITORS << subclass
  end
end
class Dlass < Class7
end
class Elass < Class7
end
class Flass < Class7
end
$INHERITORS # => [Dlass, Elass, Flass]
#FIXME Kernel Method 内核方法
# Define a method in module Kernel to make the method available to all objects.
module Kernel
  def a_method
    "a kernel method"
  end
end
a_method # => "a kernel method"
#FIXME Lazy Instance Variable
# Wait until the first access to initialize an instance variable.
class Class8
  def attribute
    @attribute = @attribute || "some value"
  end
end
obj = Class8.new
obj.attribute # => "some value"
#FIXME Mimic Method
# Disguise a method as another language construct.
def BaseClass(name)
  name == "string" ? String : Object
end

class Class9 < BaseClass "string" # a method that looks like a class
  attr_accessor :an_attribute # a method that looks like a keyword
end
obj = Class9.new
obj.an_attribute = 1 # a method that looks like an attribute
#FIXME Monkeypatch 猴子补丁
# Change the features of an existing class.
"abc".reverse # => "cba"
class String
  def reverse
    "override"
  end
end
"abc".reverse # => "override"
#FIXME Named Arguments 具名参数
# Collect method arguments into a hash to identify them by name.
def my_method(args)
  args[:arg2]
end

my_method(:arg1 => "A", :arg2 => "B", :arg3 => "C") # => "B"
#FIXME Namespace 命名空间
# Define constants within a module to avoid name clashes.
module MyNamespace
  class Array
    def to_s
      "my class"
    end
  end
end
Array.new # => []
MyNamespace::Array.new # => my class
#FIXME Nil Guard 空值保护
# Override a reference to nil with an “or.”
x = nil
y = x || "a value" # => "a value"
#FIXME Object Extension 对象扩展
# Define Singleton Methods by mixing a module into an object’s eigenclass.
obj = Object.new
module Module
  def my_method
    'a singleton method'
  end
end
class << obj
  include Module
end
obj.my_method # => "a singleton method"
#FIXME Open Class 打开类
# Modify an existing class.
class String
  def my_string_method
    "my method"
  end
end
"abc".my_string_method # => "my method"
#FIXME Pattern Dispatch 匹配派发
# Select which methods to call based on their names.
$x = 0
class Class10
  def my_first_method
    $x += 1
  end

  def my_second_method
    $x += 2
  end
end
obj = Class10.new
obj.methods.each do |m|
  obj.send(m) if m.to_s =~ /^my_/
end
$x # => 3
#FIXME Sandbox 沙盒
# Execute untrusted code in a safe environment.
def sandbox(&code)
  proc {
    $SAFE = 2
    yield
  }.call
end

begin
  sandbox { File.delete 'a_file' }
rescue Exception => ex
  ex # => #<SecurityError: Insecure operation `delete' at level 2>
end
#FIXME Scope Gate 作用域门
# Isolate a scope with the class, module, or def keyword.
a = 1
defined? a # => "local-variable"
module MyModule
  b = 1
  defined? a # => nil
  defined? b # => "local-variable"
end
defined? a # => "local-variable"
defined? b # => nil
#FIXME Self Yield
# Pass self to the current block.
class Person
  attr_accessor :name, :surname

  def initialize
    yield self
  end
end
THE SPELLS 266
joe = Person.new do |p|
  p.name = 'Joe'
  p.surname = 'Smith'
end
#FIXME Shared Scope
# Share variables among multiple contexts in the same Flat Scope (103).
lambda {
  shared = 10
  self.class.class_eval do
    define_method :counter do
      shared
    end
    define_method :down do
      shared -= 1
    end
  end
}.call
counter # => 10
3.times { down }
counter # => 7
#FIXME Singleton Method
# Define a method on a single object.
obj = "abc"
class << obj
  def my_singleton_method
    "x"
  end
end
obj.my_singleton_method # => "x"
#FIXME String of Code
# Evaluate a string of Ruby code.
my_string_of_code = "1 + 1"
eval(my_string_of_code) # => 2
#FIXME Symbol To Proc
# Convert a symbol to a block that calls a single method.
[1, 2, 3, 4].map(&:even?) # => [false, true, false, true]


#TODO Enumberable
# grep(pattern) → array
# rep(pattern) { |obj| block } → array
# Returns an array of every element in enum for which Pattern === element. If the optional block is supplied, each matching element is passed to it, and the block’s result is stored in the output array.
(1..100).grep 38..44 #=> [38, 39, 40, 41, 42, 43, 44]
c = IO.constants
c.grep(/SEEK/) #=> [:SEEK_SET, :SEEK_CUR, :SEEK_END]
res = c.grep(/SEEK/) { |v| IO.const_get(v) }
res #=> [0, 1, 2]
# group_by { |obj| block } → a_hash click to toggle source
# group_by → an_enumerator
# Groups the collection by result of the block. Returns a hash where the keys are the evaluated result from the block and the values are arrays of elements in the collection that correspond to the key.
# If no block is given an enumerator is returned.

(1..6).group_by { |i| i%3 } #=> {0=>[3, 6], 1=>[1, 4], 2=>[2, 5]}

# each_slice(n) { ... } → nil click to toggle source
# each_slice(n) → an_enumerator
# Iterates the given block for each slice of <n> elements. If no block is given, returns an enumerator.

(1..10).each_slice(3) { |a| p a }
# outputs
# [1, 2, 3]
# [4, 5, 6]
# [7, 8, 9]
# [10]

# each_with_index(*args) { |obj, i| block } → enum click to toggle source
# each_with_index(*args) → an_enumerator
# Calls block with two arguments, the item and its index, for each item in enum. Given arguments are passed through to each().
#
# If no block is given, an enumerator is returned instead.

hash = Hash.new
%w(cat dog wombat).each_with_index { |item, index|
  hash[item] = index
}
hash #=> {"cat"=>0, "dog"=>1, "wombat"=>2}

# each_with_object(obj) { |(*args), memo_obj| ... } → obj click to toggle source
# each_with_object(obj) → an_enumerator
# Iterates the given block for each element with an arbitrary object given, and returns the initially given object.
# If no block is given, returns an enumerator.

evens = (1..10).each_with_object([]) { |i, a| a << i*2 }  #=> [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

#TODO JS STRING STRIM
#string.replace(/(^\s*)|(\s*$)/g, "")

#TODO Rails 约定汇总
# 单复数的约定
# Model用单数因为它表示一个对象如User，
# 数据库表用复数因为它存放的是对象的集合，
# Controller用复数因为它是对对象集合的操作
#
# FIXME Routes.rb中定义session一般用resource :session，而不是普通的resources :sessions。因为一般只会操作当前用户的session，不会操作所有session，所以不能定义为复数。
# 即如果一个请求一个资源时不需要指定ID，就在routes中用单数，如/profile显示当前登录用户的信息，这样你可以使用单数的/profile而不是/profile/:id。
# 也可以用match “profile” => “users#show”
#
# 其它
# Controller中可以用变量request，然后可以得到session, request_info, head, method等请求信息
#.与#使用惯例：在阅读书时经常会遇到User.all, users#show这样的表示，其中的点.与井号#使用也是有约定的，点.用于调用类方法，井号#用于调用实例方法。


#TODO Array assoc rassoc
# ary.assoc(obj)   -> new_ary  or  nil
#
# Searches through an array whose elements are also arrays
# comparing _obj_ with the first element of each contained array
# using obj.==.
# Returns the first contained array that matches (that
# is, the first associated array),
# or +nil+ if no match is found.
# See also <code>Array#rassoc</code>.
#
#    s1 = [ "colors", "red", "blue", "green" ]
#    s2 = [ "letters", "a", "b", "c" ]
#    s3 = "foo"
#    a  = [ s1, s2, s3 ]
#    a.assoc("letters")  #=> [ "letters", "a", "b", "c" ] TODO 匹配子数组的第一个元素
#    a.assoc("foo")      #=> nil
def assoc(obj)
  #This is a stub, used for indexing
end
# ary.rassoc(obj) -> new_ary or nil
#
# Searches through the array whose elements are also arrays. Compares
# _obj_ with the second element of each contained array using
# <code>==</code>. Returns the first contained array that matches. See
# also <code>Array#assoc</code>.
#
#    a = [ [ 1, "one"], [2, "two"], [3, "three"], ["ii", "two"] ]
#    a.rassoc("two")    #=> [2, "two"]  TODO 匹配子数组的第二个元素
#    a.rassoc("four")   #=> nil
def rassoc(obj)
  #This is a stub, used for indexing
end

#TODO array -,count
# ary - other_ary    -> new_ary
#
# Array Difference---Returns a new array that is a copy of
# the original array, removing any items that also appear in
# <i>other_ary</i>. (If you need set-like behavior, see the
# library class Set.)
#
#    [ 1, 1, 2, 2, 3, 3, 4, 5 ] - [ 1, 2, 4 ]  #=>  [ 3, 3, 5 ]
def - other_ary
  #This is a stub, used for indexing
end

# ary.count      -> int
# ary.count(obj) -> int
# ary.count { |item| block }  -> int
#
# Returns the number of elements.  If an argument is given, counts
# the number of elements which equals to <i>obj</i>.  If a block is
# given, counts the number of elements yielding a true value.
#
#    ary = [1, 2, 4, 2]
#    ary.count             #=> 4
#    ary.count(2)          #=> 2 TODO
#    ary.count{|x|x%2==0}  #=> 3
def count(*several_variants)
  #This is a stub, used for indexing
end


# ary.cycle(n=nil) {|obj| block }  -> nil
# ary.cycle(n=nil)                 -> an_enumerator
#
# Calls <i>block</i> for each element repeatedly _n_ times or
# forever if none or +nil+ is given.  If a non-positive number is
# given or the array is empty, does nothing.  Returns +nil+ if the
# loop has finished without getting interrupted.
#
# If no block is given, an enumerator is returned instead.
#
#    a = ["a", "b", "c"]
#    a.cycle {|x| puts x }  # print, a, b, c, a, b, c,.. forever.
#    a.cycle(2) {|x| puts x }  # print, a, b, c, a, b, c.
def cycle(*several_variants)
  #This is a stub, used for indexing
end


# ary.product(other_ary, ...)                -> new_ary
# ary.product(other_ary, ...) { |p| block }  -> ary
#
# Returns an array of all combinations of elements from all arrays.
# The length of the returned array is the product of the length
# of +self+ and the argument arrays.
# If given a block, <i>product</i> will yield all combinations
# and return +self+ instead.
#
#    [1,2,3].product([4,5])     #=> [[1,4],[1,5],[2,4],[2,5],[3,4],[3,5]]
#    [1,2].product([1,2])       #=> [[1,1],[1,2],[2,1],[2,2]]
#    [1,2].product([3,4],[5,6]) #=> [[1,3,5],[1,3,6],[1,4,5],[1,4,6],
#                               #     [2,3,5],[2,3,6],[2,4,5],[2,4,6]]
#    [1,2].product()            #=> [[1],[2]]
#    [1,2].product([])          #=> []
def product(*several_variants)
  #This is a stub, used for indexing
end


# ary.take(n)               -> new_ary
#
# Returns first n elements from <i>ary</i>.
#
#    a = [1, 2, 3, 4, 5, 0]
#    a.take(3)             #=> [1, 2, 3]
def take(n)
  #This is a stub, used for indexing
end
# ary.take_while {|arr| block }   -> new_ary
# ary.take_while                  -> an_enumerator
#
# Passes elements to the block until the block returns +nil+ or +false+,
# then stops iterating and returns an array of all prior elements.
#
# If no block is given, an enumerator is returned instead.
#
#    a = [1, 2, 3, 4, 5, 0]
#    a.take_while {|i| i < 3 }   #=> [1, 2]
def take_while(*several_variants)
  #This is a stub, used for indexing
end

# ary.drop(n)               -> new_ary
#
# Drops first n elements from +ary+ and returns the rest of
# the elements in an array.
#
#    a = [1, 2, 3, 4, 5, 0]
#    a.drop(3)             #=> [4, 5, 0]
def drop(n)
  #This is a stub, used for indexing
end
# ary.drop_while {|arr| block }   -> new_ary
# ary.drop_while                  -> an_enumerator
#
# Drops elements up to, but not including, the first element for
# which the block returns +nil+ or +false+ and returns an array
# containing the remaining elements.
#
# If no block is given, an enumerator is returned instead.
#
#    a = [1, 2, 3, 4, 5, 0]
#    a.drop_while {|i| i < 3 }   #=> [3, 4, 5, 0]
def drop_while(*several_variants)
  #This is a stub, used for indexing
end


# ary.hash   -> fixnum
#
# Compute a hash-code for this array. Two arrays with the same content
# will have the same hash code (and will compare using <code>eql?</code>).
def hash()
  #This is a stub, used for indexing
end


# ary.fetch(index)                    -> obj
# ary.fetch(index, default )          -> obj
# ary.fetch(index) {|index| block }   -> obj
#
# Tries to return the element at position <i>index</i>. If the index
# lies outside the array, the first form throws an
# <code>IndexError</code> exception, the second form returns
# <i>default</i>, and the third form returns the value of invoking
# the block, passing in the index. Negative values of <i>index</i>
# count from the end of the array.
#
#    a = [ 11, 22, 33, 44 ]
#    a.fetch(1)               #=> 22
#    a.fetch(-1)              #=> 44
#    a.fetch(4, 'cat')        #=> "cat"
#    a.fetch(4) { |i| i*i }   #=> 16
def fetch(*several_variants)
  #This is a stub, used for indexing
end


# ary.first     ->   obj or nil
# ary.first(n)  ->   new_ary
#
# Returns the first element, or the first +n+ elements, of the array.
# If the array is empty, the first form returns <code>nil</code>, and the
# second form returns an empty array.
#
#    a = [ "q", "r", "s", "t" ]
#    a.first     #=> "q"
#    a.first(2)  #=> ["q", "r"]
def first(*several_variants)
  #This is a stub, used for indexing
end

# ary.insert(index, obj...)  -> ary
#
# Inserts the given values before the element with the given index
# (which may be negative).
#
#    a = %w{ a b c d }
#    a.insert(2, 99)         #=> ["a", "b", 99, "c", "d"]
#    a.insert(-2, 1, 2, 3)   #=> ["a", "b", 99, "c", 1, 2, 3, "d"]
def insert(*args)
  #This is a stub, used for indexing
end

# ary.each_index {|index| block }  -> ary
# ary.each_index                   -> an_enumerator
#
# Same as <code>Array#each</code>, but passes the index of the element
# instead of the element itself.
#
# If no block is given, an enumerator is returned instead.
#
#    a = [ "a", "b", "c" ]
#    a.each_index {|x| print x, " -- " }
#
# produces:
#
#    0 -- 1 -- 2 --
def each_index(*several_variants)
  #This is a stub, used for indexing
end
# ary.reverse_each {|item| block }   -> ary
# ary.reverse_each                   -> an_enumerator
#
# Same as <code>Array#each</code>, but traverses +self+ in reverse
# order.
#
#    a = [ "a", "b", "c" ]
#    a.reverse_each {|x| print x, " " }
#
# produces:
#
#    c b a
def reverse_each(*several_variants)
  #This is a stub, used for indexing
end


# ary.reverse -> new_ary
#
# Returns a new array containing +self+'s elements in reverse order.
#
#    [ "a", "b", "c" ].reverse   #=> ["c", "b", "a"]
#    [ 1 ].reverse               #=> [1] TODO
def reverse()
  #This is a stub, used for indexing
end

# ary.sort                   -> new_ary
# ary.sort {| a,b | block }  -> new_ary
#
# Returns a new array created by sorting +self+. Comparisons for
# the sort will be done using the <code><=></code> operator or using
# an optional code block. The block implements a comparison between
# <i>a</i> and <i>b</i>, returning -1, 0, or +1. See also
# <code>Enumerable#sort_by</code>.
#
#    a = [ "d", "a", "e", "c", "b" ]
#    a.sort                    #=> ["a", "b", "c", "d", "e"]
#    a.sort {|x,y| y <=> x }   #=> ["e", "d", "c", "b", "a"]
def sort(*several_variants)
  #This is a stub, used for indexing
end
# ary.sort!                   -> ary
# ary.sort! {| a,b | block }  -> ary
#
# Sorts +self+. Comparisons for
# the sort will be done using the <code><=></code> operator or using
# an optional code block. The block implements a comparison between
# <i>a</i> and <i>b</i>, returning -1, 0, or +1. See also
# <code>Enumerable#sort_by</code>.
#
#    a = [ "d", "a", "e", "c", "b" ]
#    a.sort!                    #=> ["a", "b", "c", "d", "e"]
#    a.sort! {|x,y| y <=> x }   #=> ["e", "d", "c", "b", "a"]
def sort!(*several_variants)
end
# ary.sort_by! {| obj | block }    -> ary
# ary.sort_by!                     -> an_enumerator
def sort_by!(*several_variants)
end

#TODO array to hash(数组转换为hash)
method1.
a = ['a', 'b']
Hash[a.map {|v| [v,v.upcase]}] ; Hash[a.collect {|v| [v, v.upcase]}]

method2.
%w{a b c}.reduce({}){|a,v| a[v] = v.upcase; a}

method3.
h = Hash.new
['a', 'b'].each {|a| h[a.to_sym] = a.upcase}
# => {:a=>"A", :b=>"B"}

#TODO 文件（夹）操作
Dir.mkdir path unless  File.directory?(path)  #if directory exists
Dir.mkdir path unless File.exist?(path)   #if file exists
Dir.entries(path) #return all files as array under this directory

#TODO Attention
1.三个条件(或条件)
query_str.split(/\s?limit /i).pop.try(:to_i) || ActiveRecord::Base.connection.execute("select count(*) from  #{query_ary.join(' ')}").first.try(:values).try(:first)  || 0

#2.a && a.b  等效 a.try(:b)
#3.a || b
#4.a ||=[]
5.query_str.split(/\s?limit /i).pop.tap{|p| puts p}.try(:to_i)  #debug output

6.
  collection.map do |group|
    group_label_string = eval("group.#{group_label_method}")
    "<optgroup label=\"#{ERB::Util.html_escape(group_label_string)}\">" +
        options_from_collection_for_select(eval("group.#{group_method}"), option_key_method, option_value_method, selected_key) +
      '</optgroup>'
end.join.html_safe   #连接

#TODO not condition
  # .where.not(:organisation_translations => {:organisation_id => organisation_id})  #negative condition

#TODO
translations.detect { |t| t.locale == I18n.locale.to_s }.try(:postal_address_state_province)

#TODO activesupport-4.1.1/lib/active_support/core_ext/*所有的扩展
#TODO apply slice on hash to get needed attributes (activesupport-4.1.1/lib/active_support/core_ext/hash/slice.rb)
#hash扩展，并不在ruby API中
  # Slice a hash to include only the given keys. This is useful for
  # limiting an options hash to valid keys before passing to a method:
  #
  #   def search(criteria = {})
  #     assert_valid_keys(:mass, :velocity, :time)
  #   end
  #
  #   search(options.slice(:mass, :velocity, :time))
  #
  # If you have an array of keys you want to limit to, you should splat them:
  #
  #   valid_keys = [:mass, :velocity, :time]
  #   search(options.slice(*valid_keys))
{"fax" => "fax"}.slice(*Organisation.accessible_attributes) #result=>{"fax" => "fax"}

#TODO hash except is also a extension
  # Return a hash that includes everything but the given keys. This is useful for
  # limiting a set of parameters to everything but a few known toggles:
  #
  #   @person.update_attributes(params[:person].except(:admin))
  #
  # If the receiver responds to +convert_key+, the method is called on each of the
  # arguments. This allows +except+ to play nice with hashes with indifferent access
  # for instance:
  #
  #   {:a => 1}.with_indifferent_access.except(:a)  # => {}
  #   {:a => 1}.with_indifferent_access.except("a") # => {}
  #
{"fax" => "fax", "telephone" => "telephone"}.except("fax") #result=>{"telephone" => "telephone"}}

#TODO also a extension
# Returns a new hash with +self+ and +other_hash+ merged recursively.
  #
  #   h1 = {:x => {:y => [4,5,6]}, :z => [7,8,9]}
  #   h2 = {:x => {:y => [7,8,9]}, :z => "xyz"}
  #
  #   h1.deep_merge(h2) #=> { :x => {:y => [7, 8, 9]}, :z => "xyz" }
  #   h2.deep_merge(h1) #=> { :x => {:y => [4, 5, 6]}, :z => [7, 8, 9] }
#TODO  不同的赋值结果截然不同
a=[1,2,3]  
a[1..1]=[4,5]  #=> a=[1, 4, 5, 3]
a[1] = [4,5]   #=> a=[1,[4,5],3]

#TODO slice是[]的别名
#TODO sort and sort_by

files = files.sort {|x,y| File.size(x) <=> File.size(y)}
files = files.sort_by {|x| Files.size(x)}#代码精简，不用重复执行代码，减少内存消耗
#如果按照多个键排序
list = list.sort_by{|x| [x.age,x.name,x.height]}

#TODO 根据条件选择
detect:返回满足条件的第一个元素
find:是detect的同义词
find_all:返回所有满足元素
select:find_all同义词
reject:与select相反
grep方法调用关系运算符即case相等运算符将每个元素与指定模式匹配，由于是使用关系运算符===，模式不必是正则表达式
a=%w(January March)
a.grep(/ary/)  #["January"]
b=[1,20,13]
b.grep(12..24) #[20,13]

c=%w(ab cd de)
c.min #"ab"
c.max #"de"
c.min {|x,y| x.reverse <=> y.reverse} #"ab"
c.max {|x,y| x.reverse <=> y.reverse} #"de"






