import std.stdio, std.getopt;

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

int main(string[] args)
{
    double r, x;
    ulong n;
    string outputFileName;

    GetoptResult rslt;
    try
    {
        rslt = getopt(args,
            config.required, "initial|x", &x,
            config.required, "r|r",       &r,
            config.required, "nSteps|n",  &n,
            config.required, "output|o",  &outputFileName);
    }
    catch (GetOptException)
    {
        stderr.writeln(help);
        return 1;
    }
    if (rslt.helpWanted)
    {
        stderr.writeln(help);
        return 0;
    }

    auto outputFile = File(outputFileName, "wb");

    double[4096] buff;
    size_t idx = 0;

    outputFile.rawWrite((&x)[0..1]);
    foreach (_; 0 .. n)
    {
        x = r * x * (1 - x);
        buff[idx++] = x;
        if (idx == buff.length)
        {
            outputFile.rawWrite(buff);
            idx = 0;
        }
    }
    if (idx != 0)
        outputFile.rawWrite(buff[0 .. idx]);

    return 0;
}
