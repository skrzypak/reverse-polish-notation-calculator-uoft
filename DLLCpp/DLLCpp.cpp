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

void __cdecl ConvertToRPN(const char* data, char* result)
{
    int i = 0;                                          // Licznik petli i indeks const char* data
    int c = 0;                                          // Indeks zmiennej char* result
    BYTE priority;                                      // Zmienna przechowujaca uzyskany priorytet znaku
    bool wasNum = false;                                // Zmienna wykorzystywana w celu korekcji ilosci spacji
    std::stack<char> s;                                 // Stos do przechowywania operatorow
                                                        
                                                        // Sprawdzenie czy pierwszy znak jest minusem (liczba ujeman)
    if (*data == '-') {
        result[c++] = '-';
        wasNum = true;
        i++;
    }

    for(i; i < strlen(data); i++)
    {
        // Sprawdzenie czy wczytana zostala liczba czy operator
        if ((data[i] >= '0' && data[i] <= '9') || data[i] == '.') {
            result[c++] = data[i];
            wasNum = true;
        }
        else {

            // Sprawdzenie czy byla wczesniej wczytywana liczba, jesli tak to dodanie spacji do rezultatu
            if (wasNum) {
                result[c++] = ' ';
                wasNum = false;
            }

            switch (data[i]) {
            case '+': 
            case '-':
            case '*':
            case '/':
                // Wykonanie czynnosci zwiazanych z operatorami matemtaycznymi (alg. konwersji)
                priority = checkSignPriority(data[i]);
                while (s.size())
                {
                    if (priority <= checkSignPriority(s.top())) {
                        result[c++] = s.top();
                        result[c++] = ' ';
                        s.pop();
                    }
                    else break;
                }
                s.push(data[i]);
                break;
            case '(':
                // Wykonanie czynnosci zwiazanych z znakiem otwierajacym nawias
                s.push(data[i]);
                if (data[++i] == '-') {
                    result[c++] = '-';
                    wasNum = true;
                    break;
                }
                i--;
                break;
            case ')':
                // Wykonanie czynnosci zwiazanych z znakiem zamykajacym nawias
                while(s.top() != '(') {
                    result[c++] = s.top();
                    result[c++] = ' ';
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
    }

    // Wypisanie do wyniku pozostalych operatorow na stosie (algortym konwersji)
    result[c++] = ' ';
    while (s.size() > 0) {
        result[c++] = s.top();
        result[c++] = ' ';
        s.pop();
    }

    // Dodanie znaku NULL do resultatu
    result[c] = '\0';
}

double __cdecl CalcRPN(const char* rpn) noexcept
{
    std::stack<double> s;                                       // Stos przechowujacy liczby
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
        if (*rpn >= '0' || *rpn == '.') {
            std::stringstream ss;
            while (*rpn != ' ') {                               // Jesli tak to wczytanie calej liczby do strumienia
                ss << *rpn;
                rpn++;
            }
            ss >> num1;                                         // Konwersja liczby z string na double
            num1 = sign == '+' ? num1 : num1 * (-1);            // Okreslenie jej znaku
            s.push(num1);                                       // Zaladowanie liczby na stos
            sign = '+';                                         // Przywrocenie znaku liczby dodatniej
            rpn++;                                              // Ominiecie spacji i przescie do kolejengo obiegu petli
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

