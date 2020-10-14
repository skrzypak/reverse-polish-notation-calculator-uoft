#pragma once

#ifdef DLLCpp_EXPORTS
#define DLLCpp_API __declspec(dllexport)
#else
#define DLLCpp_API __declspec(dllimport)
#endif

#include <string>
#include <stack>

extern "C" DLLCpp_API int __cdecl TestMethod(int x, int y);
