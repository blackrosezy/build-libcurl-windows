@echo off
setlocal EnableDelayedExpansion 

set PROGFILES=%ProgramFiles%
if not "%ProgramFiles(x86)%" == "" set PROGFILES=%ProgramFiles(x86)%

REM Check if Visual Studio 2015 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 14.0"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"        
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
   	set COMPILER_VER="2015"
        echo Using Visual Studio 2015
	goto setup_env
  )
)
REM Check if Visual Studio 2013 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 12.0"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
    set COMPILER_VER="2013"
    echo Using Visual Studio 2013
	goto setup_env
  )
)

REM Check if Visual Studio 2012 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 11.0"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
    set COMPILER_VER="2012"
    echo Using Visual Studio 2012
	goto setup_env
  )
)

REM Check if Visual Studio 2010 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 10.0"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
    set COMPILER_VER="2010"
    echo Using Visual Studio 2010
	goto setup_env
  )
)

REM Check if Visual Studio 2008 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 9.0"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
    set COMPILER_VER="2008"
    echo Using Visual Studio 2008
	goto setup_env
  )
)

REM Check if Visual Studio 2005 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 8"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio 8\VC\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
	set COMPILER_VER="2005"
    echo Using Visual Studio 2005
	goto setup_env
  )
) 

REM Check if Visual Studio 6 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio\VC98"
set VCVARSALLPATH="%PROGFILES%\Microsoft Visual Studio\VC98\vcvarsall.bat"
if exist %MSVCDIR% (
  if exist %VCVARSALLPATH% (
	set COMPILER_VER="6"
    echo Using Visual Studio 6
	goto setup_env
  )
) 

echo No compiler : Microsoft Visual Studio (6, 2005, 2008, 2010, 2012, 2013 or 2015) is not installed.
goto end

:setup_env

echo Setting up environment
if %COMPILER_VER% == "6" (
	call %MSVCDIR%\Bin\VCVARS32.BAT
	goto begin
)

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
%XIDEL% http://curl.haxx.se/download.html -e "//a[@type='application/zip' and ends-with(@href, '.zip')]/@href" > tmp_url
set /p url=<tmp_url

REM exit on errors, else continue
if %errorlevel% neq 0 exit /b %errorlevel%

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

if %COMPILER_VER% == "2015" (
	set VCVERSION = 14
	goto buildnow
)

:buildnow
REM Build!
echo "%MSVCDIR%\VC\vcvarsall.bat"
call %MSVCDIR%\VC\vcvarsall.bat x86
echo Compiling dll-debug-x86 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=yes

echo Compiling dll-release-x86 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=no GEN_PDB=yes

echo Compiling static-debug-x86 version...
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=yes

echo Compiling static-release-x86 version...
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=no

call %MSVCDIR%\VC\vcvarsall.bat x64
echo Compiling dll-debug-x64 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=yes MACHINE=x64

echo Compiling dll-release-x64 version...
nmake /f Makefile.vc mode=dll VC=%VCVERSION% DEBUG=no GEN_PDB=yes MACHINE=x64

echo Compiling static-debug-x64 version...
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=yes MACHINE=x64

echo Compiling static-release-x64 version...
nmake /f Makefile.vc mode=static VC=%VCVERSION% DEBUG=no MACHINE=x64

REM Copy compiled .*lib, *.pdb, *.dll files folder to third-party\lib\dll-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-debug-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x86
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x86
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x86
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x86

REM Copy compiled .*lib, *.pdb, *.dll files to third-party\lib\dll-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-release-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release-x86

REM Copy compiled .*lib file in lib-release folder to third-party\lib\static-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-debug-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-debug-x86
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-debug-x86

REM Copy compiled .*lib files in lib-release folder to third-party\lib\static-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x86-release-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-release-x86
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-release-x86

REM Copy compiled .*lib, *.pdb, *.dll files folder to third-party\lib\dll-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x64-debug-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x64
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x64
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x64
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-debug-x64

REM Copy compiled .*lib, *.pdb, *.dll files to third-party\lib\dll-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x64-release-dll-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64
%CP% lib\*.pdb %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64
%CP% bin\*.dll %ROOT_DIR%\third-party\libcurl\lib\dll-release-x64

REM Copy compiled .*lib file in lib-release folder to third-party\lib\static-debug folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x64-debug-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-debug-x64
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-debug-x64

REM Copy compiled .*lib files in lib-release folder to third-party\lib\static-release folder
cd %ROOT_DIR%\tmp_libcurl\curl-*\builds\libcurl-vc-x64-release-static-ipv6-sspi-winssl
%MKDIR% -p %ROOT_DIR%\third-party\libcurl\lib\static-release-x64
%CP% lib\*.lib %ROOT_DIR%\third-party\libcurl\lib\static-release-x64


REM Copy include folder to third-party folder
%CP% -rf include %ROOT_DIR%\third-party\libcurl

REM Cleanup temporary file/folders
cd %ROOT_DIR%
%RM% -rf tmp_*

:end
exit /b
