Auto download & compile libcurl
-----------

This batch script will automatically download the latest libcurl source code and build it using Visual Studio compiler.

Supported Visual Studio are:
*  Visual C++ 6 (require Windows Server 2003 Platform SDK released in February 2003)
*  Visual Studio 2005
*  Visual Studio 2008
*  Visual Studio 2010
*  Visual Studio 2012
*  Visual Studio 2013

Usage :

    $ build.bat

Output :

    third-party
    |-- libcurl
    |    |-- include
    |    +-- lib
    

## Release
**static linking**
*  libcurl.lib
    
**dynamic linking (dll)**
*  libcurl.dll
*  libcurl_imp.lib

## Debug

**static linking**
*  libcurld.lib
    
**dynamic linking (dll)**
*  libcurld.dll
*  libcurld_imp.lib

## FAQ
If you get message something like below, please re-run build.bat again.

    **** Retrieving:http://curl.haxx.se/download.html ****
    Downloading latest curl...
    http://curl.haxx.seAn unhandled exception occurred at $004C7D39 :: Bad port number.

License (build.bat)
-----------

    The MIT License (MIT)
    
    Copyright (c) 2013 Mohd Rozi
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
