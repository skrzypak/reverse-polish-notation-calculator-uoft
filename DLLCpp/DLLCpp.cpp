// DLLCpp.cpp : Defines the exported functions for the DLL.
#include "pch.h" // use stdafx.h in Visual Studio 2017 and earlier
#include "DLLCpp.h"

int __cdecl TestMethod(int x, int y) {
    return x - y;
}
