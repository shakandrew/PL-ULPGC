int fib(int n) {
    int ans;
    if n == 1 {
        ans = 1;
    } else {
        if n == 0 {
            ans = 0;
        } else {
            ans = fib(n-1) + fib(n-2);
        }
    }
    return ans;
}

int main() {
    int n;
    int i;
        read n;
    for i=0:n{
        print fib(i); print " ";
    }

    return 0;
}