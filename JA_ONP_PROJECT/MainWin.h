#pragma once
#include <string>
#include <wtypes.h>
#include <fstream>
#include <sstream>
#include <exception>
#include <msclr\marshal_cppstd.h>
#include <filesystem>
#include <thread>
#include <windows.h>

namespace JAONPPROJECT {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;

	/// <summary>
	/// Summary for MainWin
	/// </summary>
	public ref class MainWin : public System::Windows::Forms::Form
	{
	public:
		MainWin(void)
		{
			InitializeComponent();
			//
			//TODO: Add the constructor code here
			//
		}

	protected:

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		~MainWin()
		{
			if (components)
			{
				delete components;
			}
		}
	private: System::Windows::Forms::RadioButton^ RadioBtnCpp;
	private: System::Windows::Forms::RadioButton^ RadioBtnAsm;
	private: System::Windows::Forms::Button^ BtnDo;
	protected:






	private: System::Windows::Forms::MenuStrip^ menuStrip;







	private: System::Windows::Forms::ToolStripMenuItem^ plikToolStripMenuItem;
	private: System::Windows::Forms::Label^ LabelThreads;




	private: System::Windows::Forms::GroupBox^ DataGroup;
	private: System::Windows::Forms::TextBox^ TextBoxPath;











	private: System::Windows::Forms::GroupBox^ AdditionalSettings;
	private: System::Windows::Forms::GroupBox^ GroupBoxImplementation;
	private: System::Windows::Forms::GroupBox^ GroupBoxLogs;
	private: System::Windows::Forms::TextBox^ TextBoxLogs;
	private: System::Windows::Forms::GroupBox^ GroupBoxDataEntryNotation;

	private: System::Windows::Forms::RadioButton^ RadioBtnDataTypeONP;
	private: System::Windows::Forms::RadioButton^ RadioBtnDataTypeClassic;

	private: System::Windows::Forms::FolderBrowserDialog^ folderBrowserDialog;
	private: System::Windows::Forms::NumericUpDown^ NumericThreads;

	private: System::Windows::Forms::Label^ LabelPath;
	private: System::Windows::Forms::Button^ BtnPath;





	protected:

	private:
		/// <summary>
		/// Required designer variable.
		/// </summary>
		System::ComponentModel::Container^ components;

#pragma region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		void InitializeComponent(void)
		{
			this->RadioBtnCpp = (gcnew System::Windows::Forms::RadioButton());
			this->RadioBtnAsm = (gcnew System::Windows::Forms::RadioButton());
			this->BtnDo = (gcnew System::Windows::Forms::Button());
			this->menuStrip = (gcnew System::Windows::Forms::MenuStrip());
			this->plikToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->LabelThreads = (gcnew System::Windows::Forms::Label());
			this->DataGroup = (gcnew System::Windows::Forms::GroupBox());
			this->BtnPath = (gcnew System::Windows::Forms::Button());
			this->GroupBoxDataEntryNotation = (gcnew System::Windows::Forms::GroupBox());
			this->RadioBtnDataTypeONP = (gcnew System::Windows::Forms::RadioButton());
			this->RadioBtnDataTypeClassic = (gcnew System::Windows::Forms::RadioButton());
			this->LabelPath = (gcnew System::Windows::Forms::Label());
			this->TextBoxPath = (gcnew System::Windows::Forms::TextBox());
			this->AdditionalSettings = (gcnew System::Windows::Forms::GroupBox());
			this->NumericThreads = (gcnew System::Windows::Forms::NumericUpDown());
			this->GroupBoxImplementation = (gcnew System::Windows::Forms::GroupBox());
			this->GroupBoxLogs = (gcnew System::Windows::Forms::GroupBox());
			this->TextBoxLogs = (gcnew System::Windows::Forms::TextBox());
			this->folderBrowserDialog = (gcnew System::Windows::Forms::FolderBrowserDialog());
			this->menuStrip->SuspendLayout();
			this->DataGroup->SuspendLayout();
			this->GroupBoxDataEntryNotation->SuspendLayout();
			this->AdditionalSettings->SuspendLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->NumericThreads))->BeginInit();
			this->GroupBoxImplementation->SuspendLayout();
			this->GroupBoxLogs->SuspendLayout();
			this->SuspendLayout();
			// 
			// RadioBtnCpp
			// 
			this->RadioBtnCpp->AutoSize = true;
			this->RadioBtnCpp->Checked = true;
			this->RadioBtnCpp->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 9.75F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(238)));
			this->RadioBtnCpp->Location = System::Drawing::Point(57, 19);
			this->RadioBtnCpp->Name = L"RadioBtnCpp";
			this->RadioBtnCpp->Size = System::Drawing::Size(49, 20);
			this->RadioBtnCpp->TabIndex = 2;
			this->RadioBtnCpp->TabStop = true;
			this->RadioBtnCpp->Text = L"C++";
			this->RadioBtnCpp->UseVisualStyleBackColor = true;
			// 
			// RadioBtnAsm
			// 
			this->RadioBtnAsm->AutoSize = true;
			this->RadioBtnAsm->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 9.75F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(238)));
			this->RadioBtnAsm->Location = System::Drawing::Point(121, 19);
			this->RadioBtnAsm->Name = L"RadioBtnAsm";
			this->RadioBtnAsm->Size = System::Drawing::Size(55, 20);
			this->RadioBtnAsm->TabIndex = 3;
			this->RadioBtnAsm->Text = L"ASM";
			this->RadioBtnAsm->UseVisualStyleBackColor = true;
			// 
			// BtnDo
			// 
			this->BtnDo->Location = System::Drawing::Point(13, 451);
			this->BtnDo->Name = L"BtnDo";
			this->BtnDo->Size = System::Drawing::Size(586, 34);
			this->BtnDo->TabIndex = 4;
			this->BtnDo->Text = L"Wykonaj";
			this->BtnDo->UseVisualStyleBackColor = true;
			this->BtnDo->Click += gcnew System::EventHandler(this, &MainWin::BtnDo_Click);
			// 
			// menuStrip
			// 
			this->menuStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(1) { this->plikToolStripMenuItem });
			this->menuStrip->Location = System::Drawing::Point(0, 0);
			this->menuStrip->Name = L"menuStrip";
			this->menuStrip->Size = System::Drawing::Size(610, 24);
			this->menuStrip->TabIndex = 9;
			this->menuStrip->Text = L"menuStrip";
			// 
			// plikToolStripMenuItem
			// 
			this->plikToolStripMenuItem->Name = L"plikToolStripMenuItem";
			this->plikToolStripMenuItem->Size = System::Drawing::Size(86, 20);
			this->plikToolStripMenuItem->Text = L"O programie";
			this->plikToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainWin::plikToolStripMenuItem_Click);
			// 
			// LabelThreads
			// 
			this->LabelThreads->AutoSize = true;
			this->LabelThreads->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 9.75F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(238)));
			this->LabelThreads->Location = System::Drawing::Point(9, 26);
			this->LabelThreads->Name = L"LabelThreads";
			this->LabelThreads->Size = System::Drawing::Size(164, 16);
			this->LabelThreads->TabIndex = 10;
			this->LabelThreads->Text = L"Okreœl iloœæ w¹tków (1-64):";
			// 
			// DataGroup
			// 
			this->DataGroup->Controls->Add(this->BtnPath);
			this->DataGroup->Controls->Add(this->GroupBoxDataEntryNotation);
			this->DataGroup->Controls->Add(this->LabelPath);
			this->DataGroup->Controls->Add(this->TextBoxPath);
			this->DataGroup->Location = System::Drawing::Point(13, 40);
			this->DataGroup->Name = L"DataGroup";
			this->DataGroup->Size = System::Drawing::Size(586, 155);
			this->DataGroup->TabIndex = 14;
			this->DataGroup->TabStop = false;
			this->DataGroup->Text = L"Dane Ÿród³owe";
			// 
			// BtnPath
			// 
			this->BtnPath->Location = System::Drawing::Point(489, 36);
			this->BtnPath->Name = L"BtnPath";
			this->BtnPath->Size = System::Drawing::Size(78, 36);
			this->BtnPath->TabIndex = 18;
			this->BtnPath->Text = L"Wybierz";
			this->BtnPath->UseVisualStyleBackColor = true;
			this->BtnPath->Click += gcnew System::EventHandler(this, &MainWin::BtnPath_Click);
			// 
			// GroupBoxDataEntryNotation
			// 
			this->GroupBoxDataEntryNotation->Controls->Add(this->RadioBtnDataTypeONP);
			this->GroupBoxDataEntryNotation->Controls->Add(this->RadioBtnDataTypeClassic);
			this->GroupBoxDataEntryNotation->Location = System::Drawing::Point(12, 78);
			this->GroupBoxDataEntryNotation->Name = L"GroupBoxDataEntryNotation";
			this->GroupBoxDataEntryNotation->Size = System::Drawing::Size(555, 62);
			this->GroupBoxDataEntryNotation->TabIndex = 17;
			this->GroupBoxDataEntryNotation->TabStop = false;
			this->GroupBoxDataEntryNotation->Text = L"Notacja danych wejœciowych";
			// 
			// RadioBtnDataTypeONP
			// 
			this->RadioBtnDataTypeONP->AutoSize = true;
			this->RadioBtnDataTypeONP->Location = System::Drawing::Point(181, 29);
			this->RadioBtnDataTypeONP->Name = L"RadioBtnDataTypeONP";
			this->RadioBtnDataTypeONP->Size = System::Drawing::Size(143, 17);
			this->RadioBtnDataTypeONP->TabIndex = 1;
			this->RadioBtnDataTypeONP->Text = L"Odwrotna notacja polska";
			this->RadioBtnDataTypeONP->UseVisualStyleBackColor = true;
			// 
			// RadioBtnDataTypeClassic
			// 
			this->RadioBtnDataTypeClassic->AutoSize = true;
			this->RadioBtnDataTypeClassic->Checked = true;
			this->RadioBtnDataTypeClassic->Location = System::Drawing::Point(10, 29);
			this->RadioBtnDataTypeClassic->Name = L"RadioBtnDataTypeClassic";
			this->RadioBtnDataTypeClassic->Size = System::Drawing::Size(165, 17);
			this->RadioBtnDataTypeClassic->TabIndex = 0;
			this->RadioBtnDataTypeClassic->TabStop = true;
			this->RadioBtnDataTypeClassic->Text = L"Notacja infiksowa (klasyczna)";
			this->RadioBtnDataTypeClassic->UseVisualStyleBackColor = true;
			// 
			// LabelPath
			// 
			this->LabelPath->AutoSize = true;
			this->LabelPath->Font = (gcnew System::Drawing::Font(L"Microsoft Sans Serif", 8.25F, System::Drawing::FontStyle::Regular, System::Drawing::GraphicsUnit::Point,
				static_cast<System::Byte>(238)));
			this->LabelPath->Location = System::Drawing::Point(9, 26);
			this->LabelPath->Name = L"LabelPath";
			this->LabelPath->Size = System::Drawing::Size(258, 13);
			this->LabelPath->TabIndex = 14;
			this->LabelPath->Text = L"Podaj scie¿kê do katalogu z plikami do przetworzenia";
			// 
			// TextBoxPath
			// 
			this->TextBoxPath->Location = System::Drawing::Point(12, 42);
			this->TextBoxPath->Name = L"TextBoxPath";
			this->TextBoxPath->ReadOnly = true;
			this->TextBoxPath->Size = System::Drawing::Size(471, 20);
			this->TextBoxPath->TabIndex = 9;
			this->TextBoxPath->Text = L"..\\files";
			// 
			// AdditionalSettings
			// 
			this->AdditionalSettings->Controls->Add(this->NumericThreads);
			this->AdditionalSettings->Controls->Add(this->GroupBoxImplementation);
			this->AdditionalSettings->Controls->Add(this->LabelThreads);
			this->AdditionalSettings->Location = System::Drawing::Point(13, 201);
			this->AdditionalSettings->Name = L"AdditionalSettings";
			this->AdditionalSettings->Size = System::Drawing::Size(586, 102);
			this->AdditionalSettings->TabIndex = 15;
			this->AdditionalSettings->TabStop = false;
			this->AdditionalSettings->Text = L"Okreœlenie wymagañ";
			// 
			// NumericThreads
			// 
			this->NumericThreads->Location = System::Drawing::Point(199, 27);
			this->NumericThreads->Maximum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 64, 0, 0, 0 });
			this->NumericThreads->Minimum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 1, 0, 0, 0 });
			this->NumericThreads->Name = L"NumericThreads";
			this->NumericThreads->Size = System::Drawing::Size(62, 20);
			this->NumericThreads->TabIndex = 13;
			this->NumericThreads->Value = System::Decimal(gcnew cli::array< System::Int32 >(4) { 1, 0, 0, 0 });
			// 
			// GroupBoxImplementation
			// 
			this->GroupBoxImplementation->Controls->Add(this->RadioBtnCpp);
			this->GroupBoxImplementation->Controls->Add(this->RadioBtnAsm);
			this->GroupBoxImplementation->Location = System::Drawing::Point(12, 53);
			this->GroupBoxImplementation->Name = L"GroupBoxImplementation";
			this->GroupBoxImplementation->Size = System::Drawing::Size(249, 43);
			this->GroupBoxImplementation->TabIndex = 12;
			this->GroupBoxImplementation->TabStop = false;
			this->GroupBoxImplementation->Text = L"Jak¹ implementacjê algorytmu wybierasz";
			// 
			// GroupBoxLogs
			// 
			this->GroupBoxLogs->Controls->Add(this->TextBoxLogs);
			this->GroupBoxLogs->Location = System::Drawing::Point(13, 309);
			this->GroupBoxLogs->Name = L"GroupBoxLogs";
			this->GroupBoxLogs->Size = System::Drawing::Size(586, 136);
			this->GroupBoxLogs->TabIndex = 16;
			this->GroupBoxLogs->TabStop = false;
			this->GroupBoxLogs->Text = L"Logi";
			// 
			// TextBoxLogs
			// 
			this->TextBoxLogs->Location = System::Drawing::Point(7, 20);
			this->TextBoxLogs->Multiline = true;
			this->TextBoxLogs->Name = L"TextBoxLogs";
			this->TextBoxLogs->ReadOnly = true;
			this->TextBoxLogs->ScrollBars = System::Windows::Forms::ScrollBars::Both;
			this->TextBoxLogs->Size = System::Drawing::Size(572, 110);
			this->TextBoxLogs->TabIndex = 0;
			// 
			// folderBrowserDialog
			// 
			this->folderBrowserDialog->RootFolder = System::Environment::SpecialFolder::ApplicationData;
			// 
			// MainWin
			// 
			this->AutoScaleDimensions = System::Drawing::SizeF(6, 13);
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->ClientSize = System::Drawing::Size(610, 497);
			this->Controls->Add(this->GroupBoxLogs);
			this->Controls->Add(this->AdditionalSettings);
			this->Controls->Add(this->DataGroup);
			this->Controls->Add(this->BtnDo);
			this->Controls->Add(this->menuStrip);
			this->MainMenuStrip = this->menuStrip;
			this->Name = L"MainWin";
			this->Text = L"Kalkulator ONP";
			this->menuStrip->ResumeLayout(false);
			this->menuStrip->PerformLayout();
			this->DataGroup->ResumeLayout(false);
			this->DataGroup->PerformLayout();
			this->GroupBoxDataEntryNotation->ResumeLayout(false);
			this->GroupBoxDataEntryNotation->PerformLayout();
			this->AdditionalSettings->ResumeLayout(false);
			this->AdditionalSettings->PerformLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->NumericThreads))->EndInit();
			this->GroupBoxImplementation->ResumeLayout(false);
			this->GroupBoxImplementation->PerformLayout();
			this->GroupBoxLogs->ResumeLayout(false);
			this->GroupBoxLogs->PerformLayout();
			this->ResumeLayout(false);
			this->PerformLayout();

		}

#pragma endregion

	private: System::Void plikToolStripMenuItem_Click(System::Object^ sender, System::EventArgs^ e) {
		MessageBox::Show(
			"Kalkulator odwrotnej notacji polskiej\nAutor: Konrad Skrzypczyk\nKierunek: Informatyka\nGrupa: 2\nSemestr: V\nRok akademicki: 2020/21",
			"O programie",
			MessageBoxButtons::OK
		);
	}

	private: System::Void BtnPath_Click(System::Object^ sender, System::EventArgs^ e) {
		this->folderBrowserDialog->ShowDialog();
		this->TextBoxPath->Text = this->folderBrowserDialog->SelectedPath;
	}

	private:
		void log(String^ s) {
			s += "\r\n";
			this->TextBoxLogs->Text += s;
			return;
		}

		void log(std::string s) {
			s += "\r\n";
			this->TextBoxLogs->Text += ToDotNetString(s);
			return;
		}

		void log(double val) {
			std::ostringstream stream;
			stream << val;
			log(stream.str());
		}

	private:
		/** Convert std::string to String^
		* @param buff: std::string;
		* @return String^
		*/
		String^ ToDotNetString(std::string buff) {
			return msclr::interop::marshal_as<String^>(buff);
		}

		/** Convert String^ to std::string
		* @param buff: String^;
		* @return std::string
		*/
		std::string ToCppString(String^ buff) {
			return  msclr::interop::marshal_as<std::string>(buff);
		}

		// Additional alias to ConvertToRPN function from DLL
		typedef char* (_stdcall* CONVERT_TO_RPN)(const char*);
			
	private: System::Void BtnDo_Click(System::Object^ sender, System::EventArgs^ e) {

		// TODO: validate();

		this->TextBoxLogs->Text = "";
		log("================PARAMETRY=================");
		log("Dane Ÿród³owe: " + this->TextBoxPath->Text);
		log("Iloœæ w¹tków: " + this->NumericThreads->Value.ToString());
		this->RadioBtnCpp->Checked ? log("Implementacja: C++") : log("Implementacja: ASM");

		HINSTANCE hDll = NULL;
		CONVERT_TO_RPN convertToRpn;

		log("=================BIBLIOTEKA=================");
		log("Próba ³adowania biblioteki DLL, proszê czekaæ ...");
		hDll = this->RadioBtnCpp->Checked ?
			LoadLibrary(TEXT("DLLCpp")) : LoadLibrary(TEXT("DLLAsm"));

		try {
			if (hDll != NULL)
			{
				log("Uda³o za³adowaæ siê bibliotekê DLL :)");
				log("Próba ³adowania potrzebnych funkcji biblotecznych, proszê czekaæ ...");
				convertToRpn = (CONVERT_TO_RPN)GetProcAddress(hDll, "ConvertToRPN");

				if (convertToRpn != NULL)
				{
					log("Uda³o za³adowaæ siê wymagane funkcje biblioteczne :)");
					log("===================PLIKI=====================");
					log("Rozpoczêcie wczytywania i przetwarzania danych z plików");

					int i;
					std::string line[2];
					std::string path = ToCppString(this->TextBoxPath->Text);

					// TODO: Threads
					std::stringstream stream;

					for (const auto& entry : std::filesystem::directory_iterator(path)) {

						// TODO: Check extension
						
						i = 0;
						line[0] = std::string();
						line[1] = std::string();
						
						std::ifstream file(entry.path(), std::ios::in);

						if (file.is_open()) {
							
							log("=== Otwarto plik: " + entry.path().string() + " ===");
							while (std::getline(file, line[i])) {
								i++;
							}
							try {
								double freq = 0.0;
								stream.str(std::string());
								auto counterStart = StartCounter(freq);

								// Convert input to RPN
								char* onp = (convertToRpn)(line[0].c_str());
								
								// Output result to stream
								for(int c = 0; c < strlen(onp); c++)
									stream << onp[c];

								// Free allocated memory
								delete onp;
								
								auto time = GetCounter(freq, counterStart);
								
								log("Wejœcie -> " + line[0]);
								log(line[1] + "   =?   " + stream.str());
								log("Czas ->" + time);
							} catch(const std::runtime_error& e) {
								log("=================ERROR===================");
								log(e.what());
							}
						}
						else log("Nie mo¿na otworzyæ pliku:" + entry.path().string());
					}
				}
				else throw std::runtime_error("Nie uda³o wczytaæ siê funkcji z DLL: [testMethod is NULL]");
				FreeLibrary(hDll);
				hDll = NULL;
			}
			else throw std::runtime_error("Nie uda³o za³adowaæ siê DLL: [hDLL is NULL]");
		}
		catch (const std::exception& ex) {
			log("=================ERROR===================");
			log(ex.what());
		}
	}

	/** Start counter function
	*@param PCFreq: double& return cpu frequency
	*@return time in cpu ticks: __int64
	*/
	__int64 StartCounter(double& PCFreq)
	{
		LARGE_INTEGER li;
		if (!QueryPerformanceFrequency(&li))
			throw std::runtime_error("QueryPerformanceFrequency failed!\n");
		PCFreq = double(li.QuadPart) / 1000.0;
		QueryPerformanceCounter(&li);
		return li.QuadPart;
	}

	/** Get counter function
	*@param PCFreq: const double& cpu frequency
	*@param CounterStart: const __int64& start cpu ticks value
	*@return time in ms
	*/
	double GetCounter(const double& PCFreq, const __int64& CounterStart)
	{
		LARGE_INTEGER li;
		QueryPerformanceCounter(&li);
		return double(li.QuadPart - CounterStart) / PCFreq;
	}

};}
