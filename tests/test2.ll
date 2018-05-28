; ModuleID = 'xlang compiler'

@a = common global i32 0, align 4
@b = common global i32 0, align 4
@c = common global i32 0, align 4
@0 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@1 = private unnamed_addr constant [4 x i8] c"%d\0A\00"
@2 = private unnamed_addr constant [4 x i8] c"%d\0A\00"

define i32 @main() {
entry:
  store i32 1, i32* @a
  store i32 2, i32* @b
  store i32 3, i32* @c
  %0 = load i32, i32* @a
  %1 = call i32 @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @0, i32 0, i32 0), i32 %0)
  %2 = load i32, i32* @b
  %3 = call i32 @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @1, i32 0, i32 0), i32 %2)
  %4 = load i32, i32* @a
  %5 = load i32, i32* @b
  %addtmp = add i32 %4, %5
  %6 = load i32, i32* @c
  %addtmp1 = add i32 %addtmp, %6
  %7 = call i32 @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @2, i32 0, i32 0), i32 %addtmp1)
  ret i32 0
}

declare i32 @printf(i8*, i32)
