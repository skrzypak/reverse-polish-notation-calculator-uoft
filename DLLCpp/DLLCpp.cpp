// DLLCpp.cpp : Defines the exported functions for the DLL.
#include "pch.h" // use stdafx.h in Visual Studio 2017 and earlier
#include "DLLCpp.h"

inline BYTE checkSignPriority(const char& sign)
{
    switch (sign)
    {
        case '+':
        case '-': return 1;
        case '*':
        case '/': return 2;
        default: return 0;
    }
}

void __cdecl ConvertToRPN(const char* data, char* result)
{
    int c = 0;
    BYTE priority;
    bool wasNum = false;
    std::stack<char> s;

    for(int i = 0; i < strlen(data); i++)
    {
        if ((data[i] >= '0' && data[i] <= '9') || data[i] == '.') {
            result[c++] = data[i];
            wasNum = true;
        }
        else {

            if (wasNum) {
                result[c++] = ' ';
                wasNum = false;
            }

            switch (data[i]) {
            case ' ': break;
            case '+': 
            case '-':
            case '*':
            case '/':
                priority = checkSignPriority(data[i]);
                while (s.size())
                {
                    if (priority < checkSignPriority(s.top())) {
                        result[c++] = s.top();
                        result[c++] = ' ';
                        s.pop();
                    }
                    else break;
                }
                s.push(data[i]);
                break;
            case '(':   
                s.push(data[i]);
                break;
            case ')':
                while(s.top() != '(') {
                    result[c++] = s.top();
                    result[c++] = ' ';
                    s.pop();
                };
                s.pop();
                break;
            default:
                throw std::invalid_argument("Niepoprawne wyra¿enie matematyczne");
            }
        }
    }

    result[c++] = ' ';
    while (s.size() > 0) {
        result[c++] = s.top();
        result[c++] = ' ';
        s.pop();
    }

    result[c] = '\0';
}

long double __cdecl CalcRPN(const char* rpn)
{
    while (*rpn != '\0')
    {
        // TODO:

        rpn++;
    }
    return 0;
}