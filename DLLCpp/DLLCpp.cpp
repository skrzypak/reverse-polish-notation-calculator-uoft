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

char* __cdecl ConvertToRPN(const char* data)
{
    bool wasNum = false;
    BYTE priority;
    std::stack<char> s;
    std::string r = "";

    for(int i = 0; i < strlen(data); i++)
    {
        if ((data[i] >= '0' && data[i] <= '9') || data[i] == '.') {
            r = r + data[i];
            wasNum = true;
        }
        else {

            if (wasNum) {
                r = r + ' ';
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
                        r = r + s.top() + " ";
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
                    r = r + s.top() + " ";
                    s.pop();
                };
                s.pop();
                break;
            default:
                throw std::invalid_argument("Niepoprawne wyra¿enie matematyczne");
            }
        }
    }

    r += " ";
    while (s.size() > 0) {
        r = r + s.top() + " ";
        s.pop();
    }

    char* ch = new char[strlen(r.c_str()) + 1];
    strcpy_s(ch, strlen(r.c_str()) + 1, r.c_str());
    return ch;
}
