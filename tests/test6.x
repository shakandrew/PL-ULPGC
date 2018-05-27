int arr[100];
int main() {
    int n;
    int i;
    int j;
    int temp;
    read n;
    for i=0:n {
        read arr[i];
    }
    for i=0:n {
        for j=i+1:n {
            if arr[i] > arr[j] {
                temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
    }
    for i=0:n {
        print arr[i]; print " ";
    }
    return 0;
}