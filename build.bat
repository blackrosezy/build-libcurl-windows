@echo off
setlocal EnableDelayedExpansion 

set PROGFILES=%ProgramFiles%
if not "%ProgramFiles(x86)%" == "" set PROGFILES=%ProgramFiles(x86)%

REM Check if Visual Studio 2013 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 12.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2013"
	goto setup_env
)

REM Check if Visual Studio 2012 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 11.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2012"
	goto setup_env
)

REM Check if Visual Studio 2010 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 10.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2010"
	goto setup_env
)

REM Check if Visual Studio 2008 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 9.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2008"
	goto setup_env
)

REM Check if Visual Studio 2005 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 8"
if exist %MSVCDIR% (
	set COMPILER_VER="2005"
	goto setup_env
) 

REM Check if Visual Studio 6 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio\VC98"
if exist %MSVCDIR% (
	set COMPILER_VER="6"
	goto setup_env
) 

echo No compiler : Microsoft Visual Studio (6, 2005, 2008, 2010, 2012 or 2013) is not installed.
goto end

:setup_env

echo Setting up environment
if %COMPILER_VER% == "6" (
	call %MSVCDIR%\Bin\VCVARS32.BAT
	goto begin
)

call %MSVCDIR%\VC\vcvarsall.bat x86

:begin

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set CP="%CD%\bin\unxutils\cp.exe"
set MKDIR="%CD%\bin\unxutils\mkdir.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set WGET="%CD%\bin\unxutils\wget.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"

REM Housekeeping
%RM% -rf tmp_*
%RM% -rf third-party
%RM% -rf curl.zip
%RM% -rf build_*.txt

REM Get download url .Look under <blockquote><a type='application/zip' href='xxx'>
echo Get download url...
%XIDEL% http://curl.haxx.se/download.html -e "//blockquote/a[@type='application/zip']/@href" > tmp_url
set /p url=<tmp_url

REM Download latest curl and rename to curl.zip
echo Downloading latest curl...
%WGET% "http://curl.haxx.se%url%" -O curl.zip

REM Extract downloaded zip file to tmp_libcurl
%SEVEN_ZIP% x curl.zip -y -otmp_libcurl | FIND /V "ing  " | FIND /V "Igor Pavlov"

if %COMPILER_VER% == "6" goto vc6
if %COMPILER_VER% == "2005" goto vc2005
if %COMPILER_VER% == "2008" goto vc2008
if %COMPILER_VER% == "2010" goto vc2010
if %COMPILER_VER% == "2012" goto vc2012
if %COMPILER_VER% == "2013" goto vc2013

:vc6
REM Upgrade libcurl project file to compatible installed Visual Studio version
cd tmp_libcurl\curl*\vs\vc6\lib

REM Build!
msdev vc6libcurl.dsp /MAKE ALL /build
goto copy_files

:vc2005
:vc2008
REM Upgrade libcurl project file to compatible installed Visual Studio version
cd tmp_libcurl\curl*\vs\vc6\lib
vcbuild /upgrade vc6libcurl.dsp

REM Build!
vcbuild vc6libcurl.vcproj
goto copy_files

:vc2010
:vc2012
:vc2013
REM Upgrade libcurl project file to compatible installed Visual Studio version
cd tmp_libcurl\curl*\vs\vc6\lib
vcupgrade vc6libcurl.dsp

REM Build!
msbuild vc6libcurl.vcxproj /p:Configuration="DLL Debug" /t:Rebuild
msbuild vc6libcurl.vcxproj /p:Configuration="DLL Release" /t:Rebuild
msbuild vc6libcurl.vcxproj /p:Configuration="LIB Debug" /t:Rebuild
msbuild vc6libcurl.vcxproj /p:Configuration="LIB Release" /t:Rebuild
goto copy_files

:copy_files

REM Copy compiled .*lib files in lib-release folder to third-party folder
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\lib-release
%CP% lib-release\*.lib %ROOT_DIR%\third-party\libcurl\lib\lib-release

REM Copy compiled .*lib files in lib-debug folder to third-party folder
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\lib-debug
%CP% lib-debug\*.lib %ROOT_DIR%\third-party\libcurl\lib\lib-debug

REM Copy compiled .*lib and *.dll files in dll-release folder to third-party folder
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release
%CP% dll-release\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-release
%CP% dll-release\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release

REM Copy compiled .*lib and *.dll files in dll-debug folder to third-party folder
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-debug
%CP% dll-debug\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-debug
%CP% dll-debug\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-debug

REM Copy include folder to third-party folder
cd %ROOT_DIR%\tmp_libcurl\curl*\
%CP% -rf include %ROOT_DIR%\third-party\libcurl

REM Copy license information to third-party folder
%CP% COPYING %ROOT_DIR%\third-party\libcurl\

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b
