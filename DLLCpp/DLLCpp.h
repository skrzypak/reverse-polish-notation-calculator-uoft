/** DLLCpp
* 
* Biblioteka zawierajaca funkcje zwiazane z projektem konwersji i
* obliczen wrazen odwrotnej notacji polskiej
* 
* Autor: Konrad Skrzypczyk
* Przedmiot: Jezyki Assemblera
* Rok akademicki: 2020/21
* Implementacja: C++
* Pliki: DLLCpp.cpp, DLLCpp.h
* 
* =================== CHANELOG =================== 
* 
* v0.1:
* - Dodanie i implementacja nowej metody: char* ConvertToRPN(const char* data);
* 
* v0.11:
* - Zmiana defincji z char* ConvertToRPN(const char* data) na
*	void __cdecl ConvertToRPN(const char* data, char* result) throw();
* 
* v0.2:
* - Dodanie nowej definicji funkcji: long double __cdecl CalcRPN(const char* rpn)
* - Dodanie wsparcia dla liczb ujemnych w ConvertToRPN(const char* data, char* result)
* 
* v0.3:
* - Zmiana definicji z long double __cdecl CalcRPN(const char* rpn) na 
*	double __cdecl CalcRPN(const char* rpn) noexcept;
* - Implementacja funkcji double __cdecl CalcRPN(const char* rpn) noexcept;
* 
* v0.4:
* - Poprawa znalezionych bledow (bledna konwersja liczb ujemnych, wychodzenie poza zakres lanucha znakow)
* - Ujednolicenie jezyka komentarzy
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
#include <sstream>

/* Funkcja konwertuje wyrazenie matematyczne na odwrotna notacje polska. 
* Wyrazenie nie moze posiadac spacji (w przypadku liczb ujemnych)
* Funkcja nie sprawdza poprawnosci danych wejsciowych.
* @param data: char* wyrazenie matematyczne
* @param result: char* zwraca skonwertowane wyrazenie w notacji ONP
* @warning przed wywolaniem funkcji nalezy dynamicznie zainicjalizowac zmienna CHAR* RESULT
* @warning w razie wczytania blednego znaku funkcja zwraca wyjatek
*/
extern "C" DLLCpp_API void __cdecl ConvertToRPN(const char* data, char* result) throw();

/** Funkcja oblicza wyrazenie ONP, wynik zwraca w DOUBLE. W wyrazeniu kazda liczba i operator
*  musi byc oddzielona znakiem spacji. Funkcja nie sprawdza poprawnosci danych wejsciowych.
* Dane musza byc zakonczone znakiem NULL
* @param rpn: const char* wyrazenie w ONP w postaci lanucha znakow
* @return funkcja zwraca wyniki wyrazenia ONP: double
*/
extern "C" DLLCpp_API double __cdecl CalcRPN(const char* rpn) noexcept;

