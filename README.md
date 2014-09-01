mapnik-dependencies
===================

Build scripts for Mapnik dependencies

### Requirements

 - Visual Studio 2014 CTP 3
 - wget, msysgit, and 7zip, cmake

### Setup

First grab the build dependencies.

You can do this with [chocolatey](https://chocolatey.org/)

Install chocolately:

    @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

Then install deps:

    cinst wget msysgit 7zip cmake

### Building

Simply run:

    settings.bat
    scripts/build.bat

Or to run individual builds do:

    settings.bat
    scripts/build_icu.bat

