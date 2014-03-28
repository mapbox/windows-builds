update solution files
http://blogs.msdn.com/b/vcblog/archive/2010/03/25/to-the-command-line-enthusiasts-some-quick-know-hows-for-upgrading-to-vs-2010.aspx
devenv.exe /upgrade <solution file (.sln)> !!BETTER!!
vcupgrade.exe <project file (.dsp/.vcproj)>



=======DEPS

------cmake for GEOS
extract to bin\cmake
http://www.cmake.org/cmake/resources/software.html
http://www.cmake.org/files/v2.8/cmake-2.8.12.2-win32-x86.zip

-------7zip
http://www.7-zip.org/

-------Cmder
Full version (includes msysgit)
http://bliker.github.io/cmder/

-------CygWin NOT!! necessary
http://www.cygwin.org/install.html
doesn' work without admin: setup-x86.exe --no-admin
bash: Shells -> bash
make: Devel -> make
cmake: Devel -> cmake
coreutils: Base -> coreutils

-------wget
http://gnuwin32.sourceforge.net/packages/wget.htm
download zip and deps.zip and extract to bin

-------bsdtar
http://gnuwin32.sourceforge.net/packages/libarchive.htm
download zip and deps.zip and extract to bin

-------make
http://gnuwin32.sourceforge.net/packages/make.htm
download zip and deps.zip and extract to bin

-------LIBPNG
set LIBPNG_VERSION=1.5.17 (available anymore)
to
SET LIBPNG_VERSION=1.5.18

-------BOOST
use 1.55.0
http://stackoverflow.com/a/17440811