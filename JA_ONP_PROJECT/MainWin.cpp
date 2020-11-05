#include "MainWin.h"

#include "windows.h"
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>  
#include <crtdbg.h>

using namespace System;
using namespace System::Windows::Forms;

[STAThreadAttribute]
void Main(array<String^>^ args) {
    Application::EnableVisualStyles();
    Application::SetCompatibleTextRenderingDefault(false);

    _CrtMemState sOld;
    _CrtMemState sNew;
    _CrtMemState sDiff;
    _CrtMemCheckpoint(&sOld);

    // Main window
    JAONPPROJECT::MainWin form;
    Application::Run(% form);

    _CrtMemCheckpoint(&sNew);
    if (_CrtMemDifference(&sDiff, &sOld, &sNew))
    {
        OutputDebugString(L"-----------_CrtMemDumpStatistics ---------");
        _CrtMemDumpStatistics(&sDiff);
        OutputDebugString(L"-----------_CrtMemDumpAllObjectsSince ---------");
        _CrtMemDumpAllObjectsSince(&sOld);
        OutputDebugString(L"-----------_CrtDumpMemoryLeaks ---------");
        _CrtDumpMemoryLeaks();
    }
}