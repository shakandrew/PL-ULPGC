int bits(int n) {
    int temp;
    while n != 0 {
        temp = n % 2;
        n = n / 2;
        print temp; print " ";
    }
    return 0;
}
int main() {
    int a;
    read a;
    a = bits(a);
    return 0;
}
