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

## `Error`  
Go 中使用 Error 接口来表示错误。Error 接口只有一个方法：Error() string。任何实现了这个方法的类型都可以被视为一个错误。