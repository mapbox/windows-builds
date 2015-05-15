windows-builds
===================

**Things are moving fast and sometimes break.
If something doesn't work for you, please [open an issue](https://github.com/mapbox/windows-builds/issues/new).**

Windows build scripts mainly targeting:
* mapnik and its dependencies
* C++11 build of node
* node-mapnik

Other supported software: .
* node-gdal
* osmium: libosmium, node-osmium, osmium-tool
* osrm

## Requirements

 - __64bit__ operating system (W7, 8, 8.1, Server 2012)
 - [Visual Studio 2015 RC](http://support.microsoft.com/kb/2967191), **No earlier versions suppported, C++11 support needed!**
 - [Python 2.7 32 bit](https://www.python.org/downloads/windows/) installed into `C:\Python27`
 - [git](https://msysgit.github.io/) installed into `C:\Program Files (x86)\Git`

## System Setup

Install:

 - Python 2.7 32 bit
 - Git
 - Visual Studio VS2015 RC1

**When using your builds on machines, that don't have Visual Studio installed, you have to install the C++ runtime corresponding to the VS version that was used for building:**
* VS2014 CTP4 runtime: [x64](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2014-CTP4/vcredist_x64.exe>) [x86](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2014-CTP4/vcredist_x86.exe>)
* VS2015 CTP5 runtime: [x64](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015-CTP5/vcredist_x64.exe>) [x86](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015-CTP5/vcredist_x86.exe>)
* VS2015 CTP6 runtime: [x64](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015-CTP6/vcredist_x64.exe>) [x86](<https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/vcredist-VS2015-CTP6/vcredist_x86.exe>)
* VS2015 RC1 runtime: [x64](<https://mapnik.s3.amazonaws.com/dist/dev/visual-studio-runtimes/vcredist-VS2015-RC1/vc_redist.x64.exe>) [x86](<https://mapnik.s3.amazonaws.com/dist/dev/visual-studio-runtimes/vcredist-VS2015-RC1/vc_redist.x86.exe>)

## Build Setup

There is no need to manually download any dependencies, they all get downloaded automatically when needed.


```
git clone https://github.com/mapbox/windows-builds.git
cd windows-builds
settings.bat
```

This defines default options to get a quick 64bit build of mapnik: e.g dependencies are not compiled, but **already compiled binary dependencies** get downloaded.

**At the moment these pre-compiled dependencies are compiled with VS2014 CTP4. If you are using a different VS version you have to compile them yourself using `"FASTBUILD=0"`!!!** 

### Options for settings.bat ([see source for overridable parameters](/settings.bat)):

    settings.bat ["OVERRIDABLE-PARAM=VALUE"] ["OVERRIDABLE-PARAM-TWO=VALUE"]

You can combine as many overridable parameters as you like, **but each one has to be quoted with double quotes!**

Examples:
* Turning on compilation of dependencies: `settings "FASTBUILD=0"`
* Building 32bit and using mapnik branch `win-perf`: `settings "TARGET_ARCH=32" "MAPNIKBRANCH=win-perf"` 


## Building mapnik and node-mapnik

    scripts\build.bat

With `"FASTBUILD=1"` (the default):
* downloads pre-compiled dependencies
* pulls latest mapnik (honoring `MAPNIKBRANCH`)
* builds mapnik only
* to also build node-mapnik, issue `scripts\build_node_mapnik.bat` afterwards

With `"FASTBUILD=0"`:
* downloads/pulls source and builds each dependencies
* pulls latest mapnik (honoring `MAPNIKBRANCH`)
* builds mapnik
* pulls and builds nodejs
* pulls latest node-mapnik (honoring `NODEMAPNIKBRANCH`)
* builds node-mapnik

With `"PACKAGEMAPNIK=1"` (the default) a mapnik SDK package is created, including all necessary header files, libs and DLLs.

The package will be created in the directory `packages\mapnik-<MAPNIKBRANCH>\mapnik-gyp` with this name:

    mapnik-win-sdk-<MSBUILD VERSION>-<ARCHITECTURE>-<MAPNIK GIT TAG>.7z

 e.g.

    mapnik-win-sdk-14.0-x64-v3.0.0-rc1-242-g2a33ead.7z


## Building osmium

    scripts\build_libosmium_deps
    scripts\package_libosmium_deps
    scripts\build_libosmium vs
    scripts\build_osmium-tool
    
## Building node-gdal

    scripts\build_node_gdal.bat
    
## Building nodejs

    scripts\build_node
    
## Building osrm - WORK IN PROGRESS

    scripts\build_osrm builddeps

Will create:
* `bin\osrm-deps-win-x64-14.0.7z`
* `bin\osrm-release-<GIT-TAG>-x64-win-14.0.7z`