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
* - Adding and implementing new method: char* ConvertToRPN(const char* data);
* 
* v0.11:
* - Change of function definition from char* __cdecl ConvertToRPN(const char* data) to 
* void __cdecl ConvertToRPN(const char* data, char* result);
* 
* v0.2:
* - Adding new function definiton: long double __cdecl CalcRPN(const char* rpn) 
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
* @param result: char* converted expression
* @warning Allocated memory of scope 'result' before call function
*/
extern "C" DLLCpp_API void __cdecl ConvertToRPN(const char* data, char* result);

/** Calculate reverse polish notation expression
* @param rpn: const char* reverse polish notation expression
* @return result of rpn expression: long double
*/
extern "C" DLLCpp_API long double __cdecl CalcRPN(const char* rpn);

