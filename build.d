/+ dub.sdl:
    dependency "dbuild" version="*"
    dependency "pkg-config" version="*"
+/


// will be replaced by dub#1453
void genLinkerFile(R)(R flagRange)
{
    import std.path : buildPath;
    import std.process : environment;
    import std.stdio : File, stdout;

    const flagFilename = buildPath(environment.get("DUB_PACKAGE_DIR", "."), "linker_flags.txt");
    stdout.writeln("generating ", flagFilename);

    auto flagF = File(flagFilename, "w");
    foreach (lf; flagRange) {
        flagF.writeln(lf);
    }
}

string[string] readJConfig(in string jconfigh)
{
    import std.regex : regex, matchFirst;
    import std.stdio : File;

    auto settingRe = regex(`^\s*#define\s+(\w+)\s+([^\s]+)`);
    auto optionSetRe = regex(`^\s*#define\s+(\w+)\s*(/\*.*\*/)?$`);
    auto optionUnsetRe = regex(`#undef\s+(\w+)`);

    string[string] config;
    auto confF = File(jconfigh, "r");
    foreach (l; confF.byLine) {
        auto m = matchFirst(l, settingRe);
        if (m) {
            config[m[1].idup] = m[2].idup;
            continue;
        }
        m = matchFirst(l, optionSetRe);
        if (m) {
            config[m[1].idup] = "true";
            continue;
        }
        m = matchFirst(l, optionUnsetRe);
        if (m) {
            config[m[1].idup] = "false";
            continue;
        }
    }

    return config;
}

void writeJConfig(string[string] config)
{
    import std.path : buildPath;
    import std.process : environment;
    import std.regex : Captures, regex, replaceAll;
    import std.stdio : File;

    string replace (Captures!string m) {
        auto c = m[1].idup in config;
        if (c) {
            return *c;
        }
        else if (m[2].length) {
            return m[3].idup;
        }
        else {
            throw new Exception("Could not find config or default value for "~m[0]);
        }
    }

    auto slotRe = regex(`@(\w+)(:(.*))?@`);

    const tjd = environment.get("DUB_PACKAGE_DIR", ".");
    const inPath = buildPath(tjd, "source", "turbojpeg", "jconfig.d.in");
    const outPath = buildPath(tjd, "source", "turbojpeg", "jconfig.d");

    auto inF = File(inPath, "r");
    auto outF = File(outPath, "w");

    foreach (l; inF.byLineCopy) {
        outF.writeln(replaceAll!(replace)(l, slotRe));
    }
}

void main()
{
    import std.algorithm : sort, uniq;
    import std.array : array;
    import std.file : exists;
    import std.path : buildPath;
    import std.range : chain, only;
    import std.stdio : stdout, stderr;

    bool foundJConf;

    try {
        import pkg_config : pkgConfig;

        auto jlib = pkgConfig("libjpeg", "2.0")
            .cflags()
            .libs()
            .msvc()
            .invoke();
        auto tjlib = pkgConfig("libturbojpeg", "2.0")
            .cflags()
            .libs()
            .msvc()
            .invoke();

        foreach (ip; jlib.includePaths.chain(tjlib.includePaths)) {
            const path = ip.buildPath("jconfig.h");
            if (path.exists()) {
                stdout.writefln("found %s", path);
                auto config = readJConfig(path);
                writeJConfig(config);
                foundJConf = true;
                break;
            }
        }

        genLinkerFile((jlib.lflags ~ tjlib.lflags).sort().uniq());
    }
    catch(Exception ex)
    {
        import dbuild : archiveFetchSource, Build, CMake, libTarget;

        stdout.writefln("Could not find turbojpeg with pkg-config: %s", ex.msg);
        stdout.writefln("Will build it from source.");
        stdout.flush();

        auto src = archiveFetchSource(
            "https://sourceforge.net/projects/libjpeg-turbo/files/2.0.0/libjpeg-turbo-2.0.0.tar.gz",
            "b12a3fcf1d078db38410f27718a91b83"
        );
        auto cmakeOptions = [
            "-DENABLE_SHARED=OFF", "-DENABLE_STATIC=ON",
            "-DWITH_JPEG7=ON", "-DWITH_JPEG8=ON"
        ];
        auto cmake = CMake.create(null, cmakeOptions).buildSystem();
        auto res = Build
            .dubWorkDir()
            .src(src)
            .release()
            .target(libTarget("jpeg"))
            .target(libTarget("turbojpeg"))
            .build(cmake);

        const possibleJConfigs = [
            res.dirs.install("include", "jconfig.h"),
        ];
        foreach (pjc; possibleJConfigs) {
            if (!exists(pjc)) continue;
            stdout.writefln("found %s", pjc);
            auto config = readJConfig(pjc);
            writeJConfig(config);
            foundJConf = true;
            break;
        }
        genLinkerFile(only(
            res.artifact("jpeg"), res.artifact("turbojpeg")
        ));
    }
    if (!foundJConf) {
        stderr.writeln("Warning: Could not find jconfig.h. " ~
            "Using conservative configuration in turbojpeg.jconfig.");
        // TODO
    }
}
