mapnik-dependencies
===================

Windows build scripts for mapnik dependencies and mapnik itself.

## Requirements

 - __64bit__ operating system (W7, 8, 8.1, Server 2012)
 - [Visual Studio 2015 CTP5](http://support.microsoft.com/kb/2967191)
 - [Python 2.7 32 bit](https://www.python.org/downloads/windows/) installed into `C:\Python27`
 - [git](https://msysgit.github.io/) installed into `C:\Program Files (x86)\Git`

## Setup

Install:

 - Python 2.7 32 bit
 - Git
 - Visual Studio 2015 CTP5

Then:

```
git clone https://github.com/BergWerkGIS/mapnik-dependencies.git
cd mapnik-dependencies
settings.bat (default settings: e.g. 64bit)
```

-----

Options for settings.bat (see source for overridable parameters):

    settings.bat ["OVERRIDABLE-PARAM=VALUE"] ["OVERRIDABLE-PARAM-TWO=VALUE"]

__Overridable parameters have to be quoted!__

## Building

To download and build all dependencies, mapnik and node-mapnik run:

    scripts\build.bat

## Tip

If you want to compile 32bit and 64bit use `clean.bat` before compling the second architecture, this will clean all package directories.

A better way would be to create a dedicated directory for each architecture, e.g.:

### 64bit

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git mapnik-dependencies-64
    cd mapnik-dependencies-64
    settings.bat
    scripts\build.bat

### 32bit

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git mapnik-dependencies-32
    cd mapnik-dependencies-32
    settings.bat
    scripts\build.bat "TARGET_ARCH=32"

### Bonus Tip

To create a mapnik SDK package, including all necessary header files, libs and dlls adjust the `settings.bat` call:

    settings.bat "PACKAGEMAPNIK=1"

The package will be created in the directory `packages\mapnik-<MAPNIKBRANCH>\mapnik-gyp` with this name:

    mapnik-win-sdk-<MSBUILD VERSION>-<ARCHITECTURE>-<MAPNIK GIT TAG>.7z

 e.g.

    `mapnik-win-sdk-14.0-x64-v3.0.0-rc1-242-g2a33ead.7z`
