; ModuleID = 'xlang compiler'

@0 = private unnamed_addr constant [3 x i8] c"%d\00"
@1 = private unnamed_addr constant [2 x i8] c" \00"
@2 = private unnamed_addr constant [3 x i8] c"%d\00"

define i32 @bits(i32) {
entry:
  %temp = alloca i32
  %n = alloca i32
  store i32 %0, i32* %n
  %1 = load i32, i32* %n
  %notequalcomparetmp = icmp ne i32 %1, 0
  %whilecon = icmp ne i1 %notequalcomparetmp, false
  br i1 %whilecon, label %loop, label %afterloop

loop:                                             ; preds = %loop, %entry
  %2 = load i32, i32* %n
  %modtmp = urem i32 %2, 2
  store i32 %modtmp, i32* %temp
  %3 = load i32, i32* %n
  %divtmp = sdiv i32 %3, 2
  store i32 %divtmp, i32* %n
  %4 = load i32, i32* %temp
  %5 = call i32 @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @0, i32 0, i32 0), i32 %4)
  %6 = call i32 bitcast (i32 (i8*, i32)* @printf to i32 (i8*)*)(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @1, i32 0, i32 0))
  %7 = load i32, i32* %n
  %notequalcomparetmp1 = icmp ne i32 %7, 0
  %whilecon2 = icmp ne i1 %notequalcomparetmp1, false
  br i1 %whilecon2, label %loop, label %afterloop

afterloop:                                        ; preds = %loop, %entry
  ret i32 0
}

declare i32 @printf(i8*, i32)

define i32 @main() {
entry:
  %a = alloca i32
  %0 = call i32 @scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @2, i32 0, i32 0), i32* %a)
  %1 = load i32, i32* %a
  %2 = call i32 @bits(i32 %1)
  store i32 %2, i32* %a
  ret i32 0
}

declare i32 @scanf(i8*, i32*)
