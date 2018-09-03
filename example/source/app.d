import std.stdio;

import turbojpeg.turbojpeg;

struct Img
{
    uint[] data;
    uint[2] size;
    int jpegsubsamp;

    this(in uint width, in uint height)
    {
        data = new uint[width * height];
        size = [ width, height ];
    }

    @property uint width() const {
        return size[0];
    }

    @property uint height() const {
        return size[1];
    }
}

version(LittleEndian) {
    enum jpegFmt = TJPF.TJPF_BGRA;
}
else {
    enum jpegFmt = TJPF.TJPF_ARGB;
}

string errorMsg(tjhandle jpeg) {
    import core.stdc.string : strlen;
    char* msg = tjGetErrorStr2(jpeg);
    auto len = strlen(msg);
    return msg[0..len].idup;
}

Img decode (const(ubyte)[] jpegData)
{
    import core.stdc.config : c_ulong;

    tjhandle jpeg = tjInitDecompress();
    scope(exit) tjDestroy(jpeg);

    int width, height, jpegsubsamp, colorspace;
    if (tjDecompressHeader3(jpeg, jpegData.ptr, cast(c_ulong)jpegData.length,
                            &width, &height, &jpegsubsamp, &colorspace) != 0)
    {
        throw new Exception("could not read from memory: "~errorMsg(jpeg));
    }

    auto img = Img(width, height);
    img.jpegsubsamp = jpegsubsamp;

    if(tjDecompress2(jpeg, cast(ubyte*)jpegData.ptr, cast(c_ulong)jpegData.length, cast(ubyte*)(&img.data[0]),
                    width, 0, height, jpegFmt, 0) != 0)
    {
        throw new Exception("could not read from memory: "~errorMsg(jpeg));
    }

    return img;
}

void encode_to_file(in Img img, in string filename)
{
    import core.stdc.config : c_ulong;
    import std.file : write;
    import std.path : baseName;

    tjhandle jpeg = tjInitCompress();
    scope(exit) tjDestroy(jpeg);
    c_ulong len;
    ubyte *bytes;
    if (tjCompress2(jpeg, cast(ubyte*)img.data.ptr, img.width, 0, img.height,
                jpegFmt, &bytes, &len, img.jpegsubsamp, 90,
                TJFLAG_ACCURATEDCT) != 0) {
        throw new Exception("could not encode to jpeg "~filename.baseName~": "~errorMsg(jpeg));
    }
    scope(exit) tjFree(bytes);
    write(filename, cast(void[])bytes[0..cast(uint)len]);
}


void main()
{
    auto jpg = cast(immutable(ubyte)[])import("bird.jpg");
    auto img = decode(jpg);

    // removing the green component
    foreach (x; 0 .. img.width) {
        foreach (y; 0 .. img.height) {
            img.data[x + img.width*y] &= 0xffff00ff;
        }
    }

    encode_to_file(img, "file.jpg");
}
