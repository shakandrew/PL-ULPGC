; ModuleID = 'xlang compiler'

@0 = private unnamed_addr constant [3 x i8] c"%d\00"
@1 = private unnamed_addr constant [3 x i8] c"%d\00"

define i32 @some(i32) {
entry:
  %dz = alloca i32
  store i32 %0, i32* %dz
  %1 = load i32, i32* %dz
  %ltcomparetmp = icmp slt i32 %1, 10
  br i1 %ltcomparetmp, label %then_block, label %else_block

then_block:                                       ; preds = %entry
  %2 = load i32, i32* %dz
  %addtmp = add i32 %2, 1
  %3 = call i32 @some(i32 %addtmp)
  store i32 %3, i32* %dz
  br label %ifcont_block

else_block:                                       ; preds = %entry
  br label %ifcont_block

ifcont_block:                                     ; preds = %else_block, %then_block
  %4 = load i32, i32* %dz
  ret i32 %4
}

define i32 @main() {
entry:
  %a = alloca i32
  %0 = call i32 @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i32* %a)
  %1 = load i32, i32* %a
  %2 = call i32 @some(i32 %1)
  %3 = call i32 @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @1, i32 0, i32 0), i32 %2)
  ret i32 0
}

declare i32 @scanf(i8*, i32*)

declare i32 @printf(i8*, i32)
