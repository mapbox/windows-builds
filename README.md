mapnik-dependencies
===================

Build scripts for Mapnik dependencies

### Requirements

 - Visual Studio 2013 (Express is okay but MSBuild 12 alone is not sufficient)
 - wget, msysgit, and 7zip

### Setup

First grab the build dependencies.

You can do this with [chocolatey](https://chocolatey.org/):

    cinst wget msysgit 7zip

### Building

Simply run:

    settings.bat
    scripts/build.bat


Or to run individual builds do:

    settings.bat
    scripts/build_icu.bat

### TODO

 - cmake/geos
 - test with cmder (http://bliker.github.io/cmder)
