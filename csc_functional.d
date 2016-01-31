import exitclean;

auto logisticMap(double r, double x)
{
    import std.range;
    return x.recurrence!(
        (a, n) => r * a[n-1] * (1 - a[n-1])
    );
}

mixin Main!((string[] args)
{
    import std.stdio : File;
    import std.range : takeExactly, chunks;
    import std.algorithm : copy;

    double r, x;
    ulong nSteps;
    string outputFileName;

    args.getOptions(r, x, nSteps, outputFileName);

    auto outputFile = File(outputFileName, "wb");

    enum bufferSize = 4096;
    foreach(chunk; logisticMap(r, x)
                   .takeExactly(nSteps + 1)
                   .chunks(bufferSize))
    {
        double[bufferSize] buff;
        chunk.copy(buff[]);
        outputFile.rawWrite(buff[0 .. chunk.length]);
    }
});

void getOptions(string[] args, out double r, out double x, out ulong nSteps,
    out string outputFileName)
{
    import std.getopt;
    import std.stdio;

    enum help =`
Logistic map calculator
=======================
Prints the first n applications of the logistic map to a file.

Formula: Xₙ = r Xₙ₋₁ (1 - Xₙ₋₁)

Options:
--initial=<> or -x<> : the initial value of X, i.e. X₀
--ratio=<> or -r<>   : the scaling factor r
--nSteps=<> or -n<>  : the number of iterations to perform
--output=<> or -o<>  : output file name

The output is in native-endian IEEE754 double-precision floats.
The output includes the initial value and therefore is 8 (nSteps + 1) bytes long.
`;

    GetoptResult rslt;
    try
    {
        rslt = getopt(args,
            config.required, "initial|x", &x,
            config.required,   "ratio|r", &r,
            config.required,  "nSteps|n", &nSteps,
            config.required,  "output|o", &outputFileName);
    }
    catch(GetOptException)
    {
        stderr.writeln(help);
        exit(1);
    }
    if (rslt.helpWanted)
    {
        stderr.writeln(help);
        exit(0);
    }
}
