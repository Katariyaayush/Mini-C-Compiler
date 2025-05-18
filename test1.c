int x;
float y;

int add(int a, int b) {
    int result;
    result = a + b;
    return result;
}

int main() {
    x = 10;
    y = 20.5;
    int z;
    z = add(x, (int)y);
    return 0;
}
