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

cd tmp_libcurl\curl-*\winbuild

if %COMPILER_VER% == "6" (
	set VCVERSION = 6
	goto buildnow
)

if %COMPILER_VER% == "2005" (
	set VCVERSION = 8
	goto buildnow
)

if %COMPILER_VER% == "2008" (
	set VCVERSION = 9
	goto buildnow
)

if %COMPILER_VER% == "2010" (
	set VCVERSION = 10
	goto buildnow
)

if %COMPILER_VER% == "2012" (
	set VCVERSION = 11
	goto buildnow
)

if %COMPILER_VER% == "2013" (
	set VCVERSION = 12
	goto buildnow
)

:buildnow
REM Build!
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=yes
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=no GEN_PDB=yes
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=yes
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=no

REM Copy compiled .*lib, *.pdb, *.dll files folder to third-party\lib\dll-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-debug-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-debug
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-debug
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-debug
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-debug

REM Copy compiled .*lib, *.pdb, *.dll files to third-party\lib\dll-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-release-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-release
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-release
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release

REM Copy compiled .*lib file in lib-release folder to third-party\lib\static-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-debug-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-debug
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-debug

REM Copy compiled .*lib files in lib-release folder to third-party\lib\static-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-release-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-release
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-release

REM Copy include folder to third-party folder
%CP% -rf include %ROOT_DIR%\third-party\libcurl

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b