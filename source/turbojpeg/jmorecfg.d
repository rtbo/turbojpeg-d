module turbojpeg.jmorecfg;

import turbojpeg.jconfig;


enum MAX_COMPONENTS = 10;

static if (BITS_IN_JSAMPLE == 8) {
    alias JSAMPLE = ubyte;
    enum JSAMPLE MAXJSAMPLE = 255;
    enum JSAMPLE CENTERJSAMPLE = 128;
}
else static if (BITS_IN_JSAMPLE == 12) {
    alias JSAMPLE = short;
    enum JSAMPLE MAXJSAMPLE = 4095;
    enum JSAMPLE CENTERJSAMPLE = 2048;
}

int GETJSAMPLE(in JSAMPLE value) {
    return value;
}

alias JCOEF = short;

alias JOCTET = ubyte;
ubyte GETJOCTET(in ubyte octet) {
    return octet;
}

alias UINT8 = ubyte;
alias UINT16 = ushort;
alias INT16 = short;
alias INT32 = int;
alias JDIMENSION = uint;

enum int JPEG_MAX_DIMENSION = 65500;

alias boolean = int;
enum boolean FALSE = 0;
enum boolean TRUE = 1;
