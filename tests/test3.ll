; ModuleID = 'xlang compiler'

@a = common global [100 x i32] zeroinitializer
@0 = private unnamed_addr constant [3 x i8] c"%d\00"

define i32 @main() {
entry:
  %d = alloca i32
  %i = alloca i32
  store i32 1, i32* %i
  %0 = load i32, i32* %i
  %a_Index = getelementptr [100 x i32], [100 x i32]* @a, i32 0, i32 %0
  %1 = load i32, i32* %a_Index
  %a_Index1 = getelementptr [100 x i32], [100 x i32]* @a, i32 0, i32 %1
  store i32 3, i32* %a_Index1
  %2 = load i32, i32* getelementptr inbounds ([100 x i32], [100 x i32]* @a, i32 0, i32 0)
  %3 = call i32 @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i32 %2)
  ret i32 0
}

declare i32 @printf(i8*, i32)
