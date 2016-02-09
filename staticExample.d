void foo(T)(T[] v)
if (is(T == float) || is(T == double))
{
    // some code
    static if (is(T == float))
    {
        // conservative code
    }
    else static if (is(T == double))
    {
        // aggressive code
    }
    // more code
}

auto reduce(string op, T)(T[] a)
{
    static auto someFunction(T a, T b)
    {
        return mixin (`a ` ~ op ~ ` b`);
    }
    return a.reduce!someFunction;
}

auto reduce(alias F, T)(T[] a)
if (__traits(compiles, { T v = F(a[0], a[0]); }))
{
    T v = 0;
    foreach (el; a)
    {
        v = F(v, el);
    }
    return v;
}

unittest
{
    import core.simd;
    int[] a = new int[](1024);
    int testSum = 0;
    foreach (el; a)
        testSum += el;

    auto vecSum = a.toVec!4.reduce!"+";

    assert (testSum == vecSum.array.reduce!(
            (total, el) => total + el)
    );
}

auto toVec(uint length, T)(T[] a)
in
{
    assert (a.length % length == 0);
}
body
{
    import core.simd;
    return cast(Vector!(T[length])[])cast(T[length][])a;
}
