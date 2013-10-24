@echo off
setlocal EnableDelayedExpansion 

set PROGFILES=%ProgramFiles%
if not "%ProgramFiles(x86)%" == "" set PROGFILES=%ProgramFiles(x86)%

REM Check if Visual Studio 2012 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 11.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2012"
	goto begin
)

REM Check if Visual Studio 2010 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 10.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2010"
	goto begin
)

REM Check if Visual Studio 2008 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 9.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2008"
	goto begin
)

REM Check if Visual Studio 2005 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 8"
if exist %MSVCDIR% (
	set COMPILER_VER="2005"
	goto begin
) 

echo Warning : Microsoft Visual Studio (2005, 2008, 2010 or 2012) is not installed.
goto end

:begin

echo Setting up environment
call %MSVCDIR%\VC\vcvarsall.bat x86

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
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

echo %COMPILER_VER%
if %COMPILER_VER% == "2005" goto vc2005
if %COMPILER_VER% == "2010" goto vc2010
if %COMPILER_VER% == "2012" goto vc2012
if %COMPILER_VER% == "2013" goto vc2013

:vc2005
REM Upgrade libcurl project file to compatible installed Visual Studio version
cd tmp_libcurl\curl*\vs\vc6\lib
vcbuild /upgrade vc6libcurl.dsp

REM Build!
vcbuild vc6libcurl.vcproj /errfile:build_errors.txt /wrnfile:build_warnings.txt
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
xcopy "lib-release\*.lib" %ROOT_DIR%\third-party\libcurl\lib\ /S

REM Copy compiled .*lib files in lib-debug folder to third-party folder
xcopy "lib-debug\*.lib" %ROOT_DIR%\third-party\libcurl\lib\ /S

REM Copy compiled .*lib and *.dll files in dll-release folder to third-party folder
xcopy "dll-release\*.lib" %ROOT_DIR%\third-party\libcurl\lib\ /S
xcopy "dll-release\*.dll" %ROOT_DIR%\third-party\libcurl\lib\ /S

REM Copy compiled .*lib and *.dll files in dll-debug folder to third-party folder
xcopy "dll-debug\*.lib" %ROOT_DIR%\third-party\libcurl\lib\ /S
xcopy "dll-debug\*.dll" %ROOT_DIR%\third-party\libcurl\lib\ /S

REM Copy include folder to third-party folder
cd %ROOT_DIR%\tmp_libcurl\curl*\
xcopy include %ROOT_DIR%\third-party\libcurl\include\ /S 

REM Copy license information to third-party folder
xcopy COPYING %ROOT_DIR%\third-party\libcurl\ /S 

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b