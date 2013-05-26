@echo off
setlocal EnableDelayedExpansion 

REM Check if Visual Studio 2005 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 8\VC\vcpackages"
if exist %MSVCDIR% (
	goto begin
) 

REM Check if Visual Studio 2008 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 9.0\VC\vcpackages"
if exist %MSVCDIR% (
	goto begin
)

echo Warning : Microsoft Visual Studio is not installed.
goto end

:begin

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

REM Add MSVCDIR to environment variable
echo Setting up environment
path %path%;%MSVCDIR%

REM Get download url .Look under <blockquote><a type='application/zip' href='xxx'>
%XIDEL% http://curl.haxx.se/download.html -e "//blockquote/a[@type='application/zip']/@href" > tmp_url
set /p url=<tmp_url

REM Download latest curl and rename to curl.zip
%WGET% "http://curl.haxx.se%url%" -O curl.zip

REM Extract downloaded zip file to tmp_libcurl
%SEVEN_ZIP% x curl.zip -y -otmp_libcurl
 
REM Upgrade libcurl project file to compatible installed Visual Studio version
cd tmp_libcurl\curl*\vs\vc6\lib
vcbuild /upgrade vc6libcurl.dsp

REM Build!
vcbuild vc6libcurl.vcproj /errfile:build_errors.txt /wrnfile:build_warnings.txt

REM Copy compiled .*lib files in lib-release folder to third-party folder
xcopy "lib-release\*.lib" %ROOT_DIR%\third-party\libpng\lib\ /S

REM Copy compiled .*lib files in lib-debug folder to third-party folder
xcopy "lib-debug\*.lib" %ROOT_DIR%\third-party\libpng\lib\ /S

REM Copy compiled .*lib and *.dll files in dll-release folder to third-party folder
xcopy "dll-release\*.lib" %ROOT_DIR%\third-party\libpng\lib\ /S
xcopy "dll-release\*.dll" %ROOT_DIR%\third-party\libpng\lib\ /S

REM Copy compiled .*lib and *.dll files in dll-debug folder to third-party folder
xcopy "dll-debug\*.lib" %ROOT_DIR%\third-party\libpng\lib\ /S
xcopy "dll-debug\*.dll" %ROOT_DIR%\third-party\libpng\lib\ /S

REM Copy include folder to third-party folder
cd %ROOT_DIR%\tmp_libcurl\curl*\
xcopy include %ROOT_DIR%\third-party\libpng\include\ /S 

REM Copy license information to third-party folder
xcopy COPYING %ROOT_DIR%\third-party\libpng\ /S 

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b