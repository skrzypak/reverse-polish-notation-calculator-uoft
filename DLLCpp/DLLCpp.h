/** DLLCpp
* 
* Library to reverse polish notation calculator project
* 
* Author: Konrad Skrzypczyk
* Subject: Assembly languages
* Academic year: 2020/21
* Implementation: C++
* Implementation file: DLLCpp.cpp
* 
* =================== CHANELOG =================== 
* 
* v0.1:
* Adding and implementing new method char* ConvertToRPN(const char* data);
* 
* v0.2:
* 
*/

#pragma once

#ifdef DLLCpp_EXPORTS
#define DLLCpp_API __declspec(dllexport)
#else
#define DLLCpp_API __declspec(dllimport)
#endif

#include <string>
#include <stack>
#include <intrin.h>
#include <stdexcept>

/* Convert mathematical expression to reverse polish notation
* @param data: char* mathematical expression
* @param result: char* converted expression - C# out
* @warning MEMORY ALLCATED !!!
*/
extern "C" DLLCpp_API char* __cdecl ConvertToRPN(const char* data);

