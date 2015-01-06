mapnik-dependencies
===================

Build scripts for Mapnik dependencies

## Requirements

 - [Visual Studio 2014 CTP 4 or Visual Studio 2015 Preview](http://support.microsoft.com/kb/2967191)
 - [Python 2.7 32 bit](https://www.python.org/downloads/windows/) installed into `C:\Python27`
 - [git](https://msysgit.github.io/)
 - [7zip 64bit](http://www.7-zip.org/download.html)
 - [cmake](http://www.cmake.org/download/)
 - [gnu bsdtar, make and wget](http://gnuwin32.sourceforge.net/packages.html)

## Setup

Install all requirements and make sure gnu tools and cmake are available on your PATH then

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git
    cd mapnik-dependencies
    settings.bat 64 14

Options for settings.bat:
`settings.bat 32|64 14 Release|Debug`

## Building

To download and build all dependencies, mapnik and node-mapnik run:

    scripts/build.bat


Or to run individual builds e.g. do:

    scripts/build_icu.bat

## Tip

If you want to compile 32bit and 64bit use `clean.bat` before compling the second architecture, this will clean all package directories.

A better way would be to create a dedicated directory for each architecture, e.g.:

### 64bit

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git mapnik-dependencies-64
    cd mapnik-dependencies-64
    settings.bat 64 14
    scripts/build.bat

### 32bit

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git mapnik-dependencies-32
    cd mapnik-dependencies-32
    settings.bat 32 14
    scripts/build.bat

### Bonus Tip

To create a mapnik SDK package, including all necessary header files, libs and dlls:

    cd packages\mapnik-master\mapnik-gyp
    package.bat

This will create a file in the form of

    mapnik-win-sdk-<MSBUILD VERSION>-<ARCHITECTURE>-<CURRENT MAPNIK GIT TAG>.7z`

 e.g.

    `mapnik-win-sdk-14.0-x64-v3.0.0-rc1-242-g2a33ead.7z`
