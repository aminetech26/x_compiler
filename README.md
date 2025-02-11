# 🛠️ X Compiler  

X Compiler is a custom compiler for the **X programming language**, designed to be **simple, structured, and efficient**.  
It utilizes **Flex** for lexical analysis, **Bison** for syntactic and semantic analysis, and **quadruplets** for intermediate code generation.

## 📜 Features  
- **Structured language design**:  
  - Program structure (`program`, `start` → `finish`)  
  - Variable and struct definitions (`var`, `struct`)  
- **Rich type system**:  
  - Primitive types (`int`, `flt`, `bool`, `str`)  
  - Complex structures (arrays, user-defined structs)  
- **Control flow**:  
  - Conditional statements (`check`, `else`)  
  - Loops (`cycle`, `while`)  
- **Operators**:  
  - Arithmetic, logical, and comparison  
- **Symbol Table Management**:  
  - Tracks variables, arrays, scopes, and struct types  
- **Intermediate Code Generation**:  
  - Uses quadruplets for efficient instruction translation  

---

## ⚙️ Installation & Setup  
Ensure you have **Flex**, **Bison**, and **GCC** installed.  

### **1️⃣ Clone the Repository**  
git clone https://github.com/your-username/x-compiler.git
cd x-compiler
### **2️⃣ Build the Compiler**
bison -d x_parser.y  
flex x_lexer.l  
gcc -o x_compiler x_parser.tab.c lex.yy.c symbol_table.c quadruplets.c -lfl
### **3️⃣ Run the Compiler**
./x_compiler test_program.x
