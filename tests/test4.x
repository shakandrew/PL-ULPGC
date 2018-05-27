int some(int dz) {
    if dz <10 {
        dz = some(dz + 1);
    }
    return dz;
}

int main() {
    int a;
    read a;
    print some(a);
    return 0;
}


