; ModuleID = 'xlang compiler'

@0 = private unnamed_addr constant [3 x i8] c"%d\00"
@1 = private unnamed_addr constant [3 x i8] c"%d\00"
@2 = private unnamed_addr constant [2 x i8] c" \00"

define i32 @fib(i32) {
entry:
  %ans = alloca i32
  %n = alloca i32
  store i32 %0, i32* %n
  %1 = load i32, i32* %n
  %equalcomparetmp = icmp eq i32 %1, 1
  br i1 %equalcomparetmp, label %then_block, label %else_block

then_block:                                       ; preds = %entry
  store i32 1, i32* %ans
  br label %ifcont_block

else_block:                                       ; preds = %entry
  %2 = load i32, i32* %n
  %equalcomparetmp4 = icmp eq i32 %2, 0
  br i1 %equalcomparetmp4, label %then_block1, label %else_block2

ifcont_block:                                     ; preds = %ifcont_block3, %then_block
  %3 = load i32, i32* %ans
  ret i32 %3

then_block1:                                      ; preds = %else_block
  store i32 0, i32* %ans
  br label %ifcont_block3

else_block2:                                      ; preds = %else_block
  %4 = load i32, i32* %n
  %subtmp = sub i32 %4, 1
  %5 = call i32 @fib(i32 %subtmp)
  %6 = load i32, i32* %n
  %subtmp5 = sub i32 %6, 2
  %7 = call i32 @fib(i32 %subtmp5)
  %addtmp = add i32 %5, %7
  store i32 %addtmp, i32* %ans
  br label %ifcont_block3

ifcont_block3:                                    ; preds = %else_block2, %then_block1
  br label %ifcont_block
}

define i32 @main() {
entry:
  %i = alloca i32
  %n = alloca i32
  %0 = call i32 @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i32* %n)
  %1 = load i32, i32* %n
  store i32 0, i32* %i
  %condition = icmp ult i32 0, %1
  br i1 %condition, label %loop, label %afterLoop

loop:                                             ; preds = %loop, %entry
  %2 = load i32, i32* %i
  %3 = call i32 @fib(i32 %2)
  %4 = call i32 @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @1, i32 0, i32 0), i32 %3)
  %5 = call i32 bitcast (i32 (i8*, i32)* @printf to i32 (i8*)*)(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @2, i32 0, i32 0))
  %6 = load i32, i32* %i
  %next = add i32 %6, 1
  store i32 %next, i32* %i
  %loopCondition = icmp ult i32 %next, %1
  br i1 %loopCondition, label %loop, label %afterLoop

afterLoop:                                        ; preds = %loop, %entry
  ret i32 0
}

declare i32 @scanf(i8*, i32*)

declare i32 @printf(i8*, i32)
