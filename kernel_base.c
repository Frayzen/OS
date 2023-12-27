extern void test()
{
    *(char*)0xb8000 = 'Q';
    return;
}
