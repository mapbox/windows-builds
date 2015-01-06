mapnik-dependencies
===================

Build scripts for Mapnik dependencies

### Requirements

 - [Visual Studio 2014 CTP 4 or Visual Studio 2015 Preview](http://support.microsoft.com/kb/2967191)
 - [Python 2.7 32 bit](https://www.python.org/downloads/windows/) installed into `C:\Python27`
 - [git](https://msysgit.github.io/)
 - [7zip 64bit](http://www.7-zip.org/download.html)
 - [cmake](http://www.cmake.org/download/)
 - [gnu bsdtar, make and wget](http://gnuwin32.sourceforge.net/packages.html)

### Setup

Install all requirements and make sure gnu tools and cmake are available on your PATH then

    git clone https://github.com/BergWerkGIS/mapnik-dependencies.git
    cd mapnik-dependencies
    settings.bat 64 14

Options for settings.bat:
`settings.bat 32|64 14 Release|Debug`

### Building

To download and build all dependencies, mapnik and node-mapnik run:

    scripts/build.bat


Or to run individual builds e.g. do:

    scripts/build_icu.bat

