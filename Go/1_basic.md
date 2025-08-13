# Basic

```go
// 包层级的所有语句必须以 `var/func` 开头
var c, python, java = true, false, "no!"
func define() {
    num := 0
}

// for, while
for sum < 100 { // for i := 0; i < 100; i++ {
    sum += 1
}

// if
if v := math.Pow(x, n); v < lim {
    return v
}

// defer 推迟：将函数的执行推迟到外层函数返回之后。推迟调用的函数调用会被压入一个栈中。 当外层函数返回时，被推迟的调用会按照后进先出的顺序调用。
func do() {
    defer dolater()
    return
}
```

---

1. 定义返回值
```go
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}
```

2. 指针
```go
var (
	v1 = Vertex{1, 2}  // 创建一个 Vertex 类型的结构体
	v2 = Vertex{X: 1}  // Y:0 被隐式地赋予零值
	v3 = Vertex{}      // X:0 Y:0
	p  = &Vertex{1, 2} // 创建一个 *Vertex 类型的结构体（指针）
)
```

3. 切片  
切片就像数组的引用 切片并不存储任何数据，它只是描述了底层数组中的一段。
更改切片的元素会修改其底层数组中对应的元素。
```go
var nums [10]int
slice := nums[0:5]

// 动态数组
nums := make([]int, 0, 5) // len(b)=0, cap(b)=5

// 遍历
for i, v := range slice {
    fmt.Println(i, v)
}
```

4. `map` 映射
```go
type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex

func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m["Bell Labs"])
}

// or
var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}
// or simplify
var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}

// 检测某个键是否存在
elem, ok := m["Bell Labs"]
```

5. 闭包
```go
func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}
```

6. `OOP`: 方法
```go
// 方法只是带有 **接收者** 的函数
type Vertex struct {
	X, Y float64
}

// instead of `func Abs(v Vertex) float64 {
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs()) // fmt.Println(Abs(v))
}
```

6.1. 指针接收者  
指针接收者的方法可以修改接收者指向的值（如这里的 Scale 所示）。 由于方法经常需要修改它的接收者，指针接收者比值接收者更常用
```go
func (v *Vertex) Scale(f float64) {
	v.X *= f
	v.Y *= f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(2)
	fmt.Println(v.Abs())    // 不需要(&v).Abs()，而普通函数则不会自动取地址
}
```

7. `interface`： 接口  
    1. 在 Go 里并没有类的继承链，而是采用「隐式实现（structural typing）」的方式：一个结构体只要实现了接口里声明的全部方法，它就自动被视为实现了该接口——不需要、也没有关键字去显式声明“我实现了这个接口”。  
    2. 接口也是值。它们可以像其它值一样传递。
```go
// 定义一个接口
type Abser interface {
	Abs() float64
}

// 在MyFloat类型上实现Abs方法
type MyFloat float64
// 自动 implement Abser
func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}
```

8. 空接口  
    可保存任何类型的值。（因为每个类型都至少实现了零个方法。）空接口被用来处理未知类型的值。例如，fmt.Print 可接受类型为 interface{} 的任意数量的参数。 

9. 类型断言: 提供对接口类型的动态类型检查  
“类型断言”做的事是：把一个接口值（interface{} 或其他接口类型）还原成某个具体类型，并在运行时检查它是否真的是那个类型。
```go
var x interface{} = "hello"
s, ok := x.(string) // ok
s, ok := x.(float64) // nil
```

9. 类型选择
```go
var v interface{} = "hello"
switch v := x.(type) {
case string:
	fmt.Println("string:", v)
case int:
	fmt.Println("int:", v)
default:
	fmt.Println("unknown type")
}
```

10. `Stringer` 接口： 类似 `Java` 中的 `toString()` 方法
```go
type Person struct {
	Name string
	Age  int
}

func (p Person) String() string {
	return fmt.Sprintf("Name: %s, Age: %d", p.Name, p.Age)
}

func main() {
	p := Person{"Alice", 30}
	fmt.Println(p) // 自动调用 String() 方法
}
```

11. `Error`  
Go 中使用 Error 接口来表示错误。Error 接口只有一个方法：Error() string。任何实现了这个方法的类型都可以被视为一个错误。

## Chapter
1. 类型参数  
此声明意味着 s 是满足内置约束 comparable 的任何类型 T 的切片。 x 也是相同类型的值。
```go
// Index 返回 x 在 s 中的下标，未找到则返回 -1。
func Index[T comparable](s []T, x T) int {
	for i, v := range s {
		// v 和 x 的类型为 T，它拥有 comparable 可比较的约束，
		// 因此我们可以使用 ==。
		if v == x {
			return i
		}
	}
	return -1
}
```

2. 泛型
```go
// List 表示一个可以保存任何类型的值的单链表。
type List[T any] struct {
	next *List[T]
	val  T
}
```

## `goroutine`
goroutine 是由 Go 运行时管理的轻量级线程。

```go
func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
```

1. 通道（Channel）
默认情况下，发送和接收操作在另一端准备好之前都会阻塞。这使得 Go 程可以在没有显式的锁或竞态变量的情况下进行同步。
```go
func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // 发送 sum 到 c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // 从 c 接收

	fmt.Println(x, y, x+y)
}
```


信道可以是 带缓冲的。将缓冲长度作为第二个参数提供给 make 来初始化一个带缓冲的信道。  
信道填满后，发送操作会阻塞，直到有接收方接收数据。

```go
c := make(chan int, 2)
c <- 1
c <- 2
fmt.Println(<-c)
fmt.Println(<-c)
```

2. 发送者可通过 close 关闭一个信道来表示没有需要发送的值了。
```go
c := make(chan int, 2)
close(c)
```

3. 接收者可以通过为接收表达式分配第二个参数来测试信道是否被关闭
```go
v, ok := <-c
```

4. 循环 for i := range c 会不断从信道接收值，直到它被关闭。
```go
for i := range c {
	fmt.Println(i)
}
```

5. select 语句使一个 Go 程可以等待多个通信操作。

select 会阻塞到某个分支可以继续执行为止，这时就会执行该分支。当多个分支都准备好时会随机选择一个执行。

当 select 中的其它分支都没有准备好时，default 分支就会执行。
```go
func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
```

6. 互斥锁（Mutex）  
Go 标准库中提供了 sync.Mutex 互斥锁类型及其两个方法：
- Lock
- Unlock  
我们可以通过在代码前调用 Lock 方法，在代码后调用 Unlock 方法来保证一段代码的互斥执行。
```go
// SafeCounter 是并发安全的
type SafeCounter struct {
	mu sync.Mutex
	v  map[string]int
}

// Inc 对给定键的计数加一
func (c *SafeCounter) Inc(key string) {
	c.mu.Lock()
	// 锁定使得一次只有一个 Go 协程可以访问映射 c.v。
	c.v[key]++
	c.mu.Unlock()
}
```