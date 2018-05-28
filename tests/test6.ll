; ModuleID = 'xlang compiler'

@arr = common global [100 x i32] zeroinitializer
@0 = private unnamed_addr constant [3 x i8] c"%d\00"
@1 = private unnamed_addr constant [3 x i8] c"%d\00"
@2 = private unnamed_addr constant [3 x i8] c"%d\00"
@3 = private unnamed_addr constant [2 x i8] c" \00"

define i32 @main() {
entry:
  %temp = alloca i32
  %j = alloca i32
  %i = alloca i32
  %n = alloca i32
  %0 = call i32 @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i32* %n)
  %1 = load i32, i32* %n
  store i32 0, i32* %i
  %condition = icmp ult i32 0, %1
  br i1 %condition, label %loop, label %afterLoop

loop:                                             ; preds = %loop, %entry
  %2 = load i32, i32* %i
  %arr_Index = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %2
  %3 = call i32 @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @1, i32 0, i32 0), i32* %arr_Index)
  %4 = load i32, i32* %i
  %next = add i32 %4, 1
  store i32 %next, i32* %i
  %loopCondition = icmp ult i32 %next, %1
  br i1 %loopCondition, label %loop, label %afterLoop

afterLoop:                                        ; preds = %loop, %entry
  %5 = load i32, i32* %n
  store i32 0, i32* %i
  %condition3 = icmp ult i32 0, %5
  br i1 %condition3, label %loop1, label %afterLoop2

loop1:                                            ; preds = %afterLoop5, %afterLoop
  %6 = load i32, i32* %i
  %addtmp = add i32 %6, 1
  %7 = load i32, i32* %n
  store i32 %addtmp, i32* %j
  %condition6 = icmp ult i32 %addtmp, %7
  br i1 %condition6, label %loop4, label %afterLoop5

afterLoop2:                                       ; preds = %afterLoop5, %afterLoop
  %8 = load i32, i32* %n
  store i32 0, i32* %i
  %condition19 = icmp ult i32 0, %8
  br i1 %condition19, label %loop17, label %afterLoop18

loop4:                                            ; preds = %ifcont_block, %loop1
  %9 = load i32, i32* %i
  %arr_Index7 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %9
  %10 = load i32, i32* %arr_Index7
  %11 = load i32, i32* %j
  %arr_Index8 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %11
  %12 = load i32, i32* %arr_Index8
  %gtcomparetmp = icmp sgt i32 %10, %12
  br i1 %gtcomparetmp, label %then_block, label %else_block

afterLoop5:                                       ; preds = %ifcont_block, %loop1
  %13 = load i32, i32* %i
  %next15 = add i32 %13, 1
  store i32 %next15, i32* %i
  %loopCondition16 = icmp ult i32 %next15, %5
  br i1 %loopCondition16, label %loop1, label %afterLoop2

then_block:                                       ; preds = %loop4
  %14 = load i32, i32* %i
  %arr_Index9 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %14
  %15 = load i32, i32* %arr_Index9
  store i32 %15, i32* %temp
  %16 = load i32, i32* %i
  %arr_Index10 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %16
  %17 = load i32, i32* %j
  %arr_Index11 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %17
  %18 = load i32, i32* %arr_Index11
  store i32 %18, i32* %arr_Index10
  %19 = load i32, i32* %j
  %arr_Index12 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %19
  %20 = load i32, i32* %temp
  store i32 %20, i32* %arr_Index12
  br label %ifcont_block

else_block:                                       ; preds = %loop4
  br label %ifcont_block

ifcont_block:                                     ; preds = %else_block, %then_block
  %21 = load i32, i32* %j
  %next13 = add i32 %21, 1
  store i32 %next13, i32* %j
  %loopCondition14 = icmp ult i32 %next13, %7
  br i1 %loopCondition14, label %loop4, label %afterLoop5

loop17:                                           ; preds = %loop17, %afterLoop2
  %22 = load i32, i32* %i
  %arr_Index20 = getelementptr [100 x i32], [100 x i32]* @arr, i32 0, i32 %22
  %23 = load i32, i32* %arr_Index20
  %24 = call i32 @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @2, i32 0, i32 0), i32 %23)
  %25 = call i32 bitcast (i32 (i8*, i32)* @printf to i32 (i8*)*)(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @3, i32 0, i32 0))
  %26 = load i32, i32* %i
  %next21 = add i32 %26, 1
  store i32 %next21, i32* %i
  %loopCondition22 = icmp ult i32 %next21, %8
  br i1 %loopCondition22, label %loop17, label %afterLoop18

afterLoop18:                                      ; preds = %loop17, %afterLoop2
  ret i32 0
}

declare i32 @scanf(i8*, i32*)

declare i32 @printf(i8*, i32)
