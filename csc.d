import std.stdio, std.getopt;

/// rdmd csc.d -x 0.1 -r 4 -n 4 | god -t f8 -An -v -w8
void main(string[] args)
{
    double r, x;
    ulong n;
    string outputFileName;

    GetoptResult rslt;
    try {
        rslt = getopt(args,
            config.required, "initial|x", &x,
            config.required, "r|r",       &r,
            config.required, "nSteps|n",  &n,
            config.required, "output|o",  &outputFileName);
        if (rslt.helpWanted) throw new GetOptException("");
    }
    catch(GetOptException) {
        defaultGetoptPrinter("Logistic map calculator\n Options:\n",
            rslt.options);
    }

    auto outputFile = File(outputFileName, "wb");

    double[4096] buff;
    size_t idx = 0;

    outputFile.rawWrite((&x)[0..1]);
    foreach(_; 0 .. n)
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
}
