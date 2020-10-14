#include "MainWin.h"

using namespace System;
using namespace System::Windows::Forms;

[STAThreadAttribute]
void Main(array<String^>^ args) {
    Application::EnableVisualStyles();
    Application::SetCompatibleTextRenderingDefault(false);

    // Main window
    JAONPPROJECT::MainWin form;
    Application::Run(% form);

}