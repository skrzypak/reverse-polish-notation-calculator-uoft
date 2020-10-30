// DLLCpp.cpp : Defines the exported functions for the DLL.
#include "pch.h" // use stdafx.h in Visual Studio 2017 and earlier
#include "DLLCpp.h"

/** Funkcja sprawdza priorytet operatora
* @param sign: const char& pobrany operator
* @return funkcja zwraca priorytet operatora: BYTE
*/
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

void __cdecl ConvertToRPN(const char* data, char* result, char sep)
{
    BYTE priority;                                      // Zmienna przechowujaca uzyskany priorytet znaku
    std::stack<char> s;                                 // Stos do przechowywania operatorow
                                                        // Sprawdzenie czy pierwszy znak jest minusem (liczba ujeman)
    if (*data == '-') {
        *result = '-';
        result++;
        data++;
        if (*data == '(') {                             // Sprawdzenie czy przypadek "-("
            *result = '1';                              // Jesli tak to wypsianie do resulta "1 "
            result++;
            *result = ' ';
            result++;
                                                        // i wrzucenie * nas stos
            s.push('*');
            s.push('(');
            data++;                                     // przejscie do nastepnego znaku w DATA
        }
    }
    else if (*data == '(') {                            // aby w switch nie wyjsc za zakres
        s.push(*data);
        data++;
    }

    while(*data != '\0')
    {
        // Sprawdzenie czy wczytana zostala liczba czy operator
        if ((*data >= '0' && *data <= '9') || *data == sep) {
            do {
                *result = *data;
                result++;
                data++;
            } while ((*data >= '0' && *data <= '9') || *data == sep);
            if (*data == '\0') goto END;
            *result = ' ';
            result++;
        }
        {
            switch (*data) {
            case '+': 
            case '-':
                if (*(data - 1) == '(') {
                    *result = *data;
                    result++;
                    if (*(data+1) == '(') {                             // Sprawdzenie czy przypadek "-("
                        *result = '1';                              // Jesli tak to wypsianie do resulta "1 "
                        result++;
                        *result = ' ';
                        result++;
                                                                    // i wrzucenie * nas stos
                        s.push('*');
                        s.push('(');
                        data++;                                     // przejscie do nastepnego znaku w DATA
                    }
                    break;
                }
            case '*':
            case '/':
                // Wykonanie czynnosci zwiazanych z operatorami matemtaycznymi (alg. konwersji)
                priority = checkSignPriority(*data);
                while (s.size())
                {
                    if (priority <= checkSignPriority(s.top())) {
                        *result = s.top();
                        result++;
                        *result = ' ';
                        result++;
                        s.pop();
                    }
                    else break;
                }
                s.push(*data);
                break;
            case '(':
                if ((*(data - 1) >= '0' && *(data - 1) <= '9') || *(data - 1) == ')')
                    s.push('*');
                // Wykonanie czynnosci zwiazanych z znakiem otwierajacym nawias
                s.push(*data);
                break;
            case ')':
                // Wykonanie czynnosci zwiazanych z znakiem zamykajacym nawias
                while(s.top() != '(') {
                    *result = s.top();
                    result++;
                    *result = ' ';
                    result++;
                    s.pop();
                };
                s.pop();
                break;
            case ' ': break;
            default:
                // W przypadku wczytania niewiadomego znaku wyrzucenie wyjatku
                throw std::invalid_argument("Niepoprawne wyra¿enie matematyczne");
            }
        }
        data++;
    }
    END:
    // Wypisanie do wyniku pozostalych operatorow na stosie (algortym konwersji)
    *result = ' ';
    result++;
    while (s.size() > 0) {
        *result = s.top();
        result++;
        *result = ' ';
        result++;
        s.pop();
    }

    // Dodanie znaku NULL do resultatu
    *result = '\0';
}

double __cdecl CalcRPN(const char* rpn, char sep) noexcept
{
    std::stack<char> digs;                                      // Stos przechowujacy poszczegolne znaki cyfrowe liczby
    std::stack<double> s;                                       // Stos przechowujacy liczby
    bool fSep = false;
    unsigned int num0;                                          //
    unsigned int mInt;                                          //
    double num1;                                                // Tymaczoswa zmienna dla typu double
    double num2;                                                // Tymaczoswa zmienna dla typu double
    char sign;                                                  // Zmienna przechowujaca znak liczby
                                                                // Okreslenie poczatkowgo znaku liczby
    if (*rpn != '-') {
        sign = '+';
    }
    else {
        sign = '-';
        rpn++;
    }
                                                                // Petla przetwarzajaca dane wejsciowe
    while (*rpn != '\0')
    {
                                                                // Spradzenie czy wczytuje sie cyfre lub seperaotr
        if (*rpn >= '0' && *rpn <= '9') {
            /*
            std::stringstream ss;
            while (*rpn != ' ') {                               // Jesli tak to wczytanie calej liczby do strumienia
                ss << *rpn;
                rpn++;
            }
            ss >> num1;                                         // Konwersja liczby z string na double
            num1 = sign == '+' ? num1 : num1 * (-1);            // Okreslenie jej znaku
           */
                                                               // Pobranie cechy i wrzucenei na stos
            while (*rpn != ' ') {
                digs.push(*rpn);
                rpn++;
                if (*rpn == sep) {
                    fSep = true;
                    rpn++;
                    break;
                }
            }
                                                                // Pobranie cyfr ze stosu i konwersja na liczbe
            num0 = 0;
            mInt = 1;
            while (digs.size() > 0) {
                num0 += (digs.top() - '0') * mInt;
                mInt *= 10;
                digs.pop();
            }  

            num1 = static_cast<double>(num0);                                              
                                                                // Pobranie cechy i zamiana na liczbe
            if (fSep) {
                num2 = 0.1;                                     // Zaladowanie mnoznika 0.1
                while (*rpn != ' ') {
                    num0 = *rpn - '0';
                    num1 += static_cast<double>(num0) * num2;
                    num2 *= 0.1;
                    rpn++;
                }
            }
                                                                // Uwzglednie znaku liczby
            num1 = sign == '+' ? num1 : num1 * (-1);
            s.push(num1);                                       // Zaladowanie liczby na stos
            sign = '+';                                         // Przywrocenie znaku liczby dodatniej
            continue;
        }
        else {
            switch (*rpn) {
            case '+': 
                                                                // Pobranie 2 liczb z stosu i wykonanie obliczen
                num1 = s.top();
                s.pop();
                num2 = s.top();
                s.pop();
                s.push(num2 + num1);
                break;
            case '-':
                                                               // Sprawdzenie czy wczytano operator minus czy znak liczby
                if (*(++rpn) != ' ') {
                    sign = '-';
                    rpn--;
                    break;
                }
                rpn--;                                        // Przywrocenie wskaznika na analizowana liczbe
                                                              // Pobranie 2 liczb z stosu i wykonanie obliczen
                num1 = s.top();
                s.pop();
                num2 = s.top();
                s.pop();
                s.push(num2 - num1);
                break;
            case '*':
                                                              // Pobranie 2 liczb z stosu i wykonanie obliczen
                num1 = s.top();
                s.pop();
                num2 = s.top();
                s.pop();
                s.push(num2 * num1);
                break;
            case '/': 
                                                              // Pobranie 2 liczb z stosu i wykonanie obliczen
                num1 = s.top();
                s.pop();
                num2 = s.top();
                s.pop();
                s.push(num2 / num1);
                break;
            }
        }
        rpn++;
    }
                                                               // Pobranie wyniku ze stosu i zwrocenie go jako wynik funkcji
    double result = s.top();
    s.pop();
    return result;
}

