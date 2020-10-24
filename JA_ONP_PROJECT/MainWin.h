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
#include <stack>
#include <chrono> 

namespace JAONPPROJECT {

	using namespace System;
	using namespace System::ComponentModel;
	using namespace System::Collections;
	using namespace System::Windows::Forms;
	using namespace System::Data;
	using namespace System::Drawing;
	using namespace System::Threading;
	using namespace std::chrono;

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





	private: System::Windows::Forms::FolderBrowserDialog^ folderBrowserDialog;
	private: System::Windows::Forms::NumericUpDown^ NumericThreads;

	private: System::Windows::Forms::Label^ LabelPath;
	private: System::Windows::Forms::Button^ BtnPath;
	private: System::Windows::Forms::GroupBox^ DataOutpuBox;
	private: System::Windows::Forms::Button^ BtnOutputPath;
	private: System::Windows::Forms::Label^ label1;
	private: System::Windows::Forms::TextBox^ TextBoxOutputPath;







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
			System::ComponentModel::ComponentResourceManager^ resources = (gcnew System::ComponentModel::ComponentResourceManager(MainWin::typeid));
			this->RadioBtnCpp = (gcnew System::Windows::Forms::RadioButton());
			this->RadioBtnAsm = (gcnew System::Windows::Forms::RadioButton());
			this->BtnDo = (gcnew System::Windows::Forms::Button());
			this->menuStrip = (gcnew System::Windows::Forms::MenuStrip());
			this->plikToolStripMenuItem = (gcnew System::Windows::Forms::ToolStripMenuItem());
			this->LabelThreads = (gcnew System::Windows::Forms::Label());
			this->DataGroup = (gcnew System::Windows::Forms::GroupBox());
			this->BtnPath = (gcnew System::Windows::Forms::Button());
			this->LabelPath = (gcnew System::Windows::Forms::Label());
			this->TextBoxPath = (gcnew System::Windows::Forms::TextBox());
			this->AdditionalSettings = (gcnew System::Windows::Forms::GroupBox());
			this->NumericThreads = (gcnew System::Windows::Forms::NumericUpDown());
			this->GroupBoxImplementation = (gcnew System::Windows::Forms::GroupBox());
			this->GroupBoxLogs = (gcnew System::Windows::Forms::GroupBox());
			this->TextBoxLogs = (gcnew System::Windows::Forms::TextBox());
			this->folderBrowserDialog = (gcnew System::Windows::Forms::FolderBrowserDialog());
			this->DataOutpuBox = (gcnew System::Windows::Forms::GroupBox());
			this->BtnOutputPath = (gcnew System::Windows::Forms::Button());
			this->label1 = (gcnew System::Windows::Forms::Label());
			this->TextBoxOutputPath = (gcnew System::Windows::Forms::TextBox());
			this->menuStrip->SuspendLayout();
			this->DataGroup->SuspendLayout();
			this->AdditionalSettings->SuspendLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->NumericThreads))->BeginInit();
			this->GroupBoxImplementation->SuspendLayout();
			this->GroupBoxLogs->SuspendLayout();
			this->DataOutpuBox->SuspendLayout();
			this->SuspendLayout();
			// 
			// RadioBtnCpp
			// 
			resources->ApplyResources(this->RadioBtnCpp, L"RadioBtnCpp");
			this->RadioBtnCpp->Checked = true;
			this->RadioBtnCpp->Name = L"RadioBtnCpp";
			this->RadioBtnCpp->TabStop = true;
			this->RadioBtnCpp->UseVisualStyleBackColor = true;
			// 
			// RadioBtnAsm
			// 
			resources->ApplyResources(this->RadioBtnAsm, L"RadioBtnAsm");
			this->RadioBtnAsm->Name = L"RadioBtnAsm";
			this->RadioBtnAsm->UseVisualStyleBackColor = true;
			// 
			// BtnDo
			// 
			resources->ApplyResources(this->BtnDo, L"BtnDo");
			this->BtnDo->Name = L"BtnDo";
			this->BtnDo->UseVisualStyleBackColor = true;
			this->BtnDo->Click += gcnew System::EventHandler(this, &MainWin::BtnDo_Click);
			// 
			// menuStrip
			// 
			this->menuStrip->Items->AddRange(gcnew cli::array< System::Windows::Forms::ToolStripItem^  >(1) { this->plikToolStripMenuItem });
			resources->ApplyResources(this->menuStrip, L"menuStrip");
			this->menuStrip->Name = L"menuStrip";
			// 
			// plikToolStripMenuItem
			// 
			this->plikToolStripMenuItem->Name = L"plikToolStripMenuItem";
			resources->ApplyResources(this->plikToolStripMenuItem, L"plikToolStripMenuItem");
			this->plikToolStripMenuItem->Click += gcnew System::EventHandler(this, &MainWin::plikToolStripMenuItem_Click);
			// 
			// LabelThreads
			// 
			resources->ApplyResources(this->LabelThreads, L"LabelThreads");
			this->LabelThreads->Name = L"LabelThreads";
			// 
			// DataGroup
			// 
			this->DataGroup->Controls->Add(this->BtnPath);
			this->DataGroup->Controls->Add(this->LabelPath);
			this->DataGroup->Controls->Add(this->TextBoxPath);
			resources->ApplyResources(this->DataGroup, L"DataGroup");
			this->DataGroup->Name = L"DataGroup";
			this->DataGroup->TabStop = false;
			// 
			// BtnPath
			// 
			resources->ApplyResources(this->BtnPath, L"BtnPath");
			this->BtnPath->Name = L"BtnPath";
			this->BtnPath->UseVisualStyleBackColor = true;
			this->BtnPath->Click += gcnew System::EventHandler(this, &MainWin::BtnPath_Click);
			// 
			// LabelPath
			// 
			resources->ApplyResources(this->LabelPath, L"LabelPath");
			this->LabelPath->Name = L"LabelPath";
			// 
			// TextBoxPath
			// 
			resources->ApplyResources(this->TextBoxPath, L"TextBoxPath");
			this->TextBoxPath->Name = L"TextBoxPath";
			this->TextBoxPath->ReadOnly = true;
			// 
			// AdditionalSettings
			// 
			this->AdditionalSettings->Controls->Add(this->NumericThreads);
			this->AdditionalSettings->Controls->Add(this->GroupBoxImplementation);
			this->AdditionalSettings->Controls->Add(this->LabelThreads);
			resources->ApplyResources(this->AdditionalSettings, L"AdditionalSettings");
			this->AdditionalSettings->Name = L"AdditionalSettings";
			this->AdditionalSettings->TabStop = false;
			// 
			// NumericThreads
			// 
			resources->ApplyResources(this->NumericThreads, L"NumericThreads");
			this->NumericThreads->Maximum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 64, 0, 0, 0 });
			this->NumericThreads->Minimum = System::Decimal(gcnew cli::array< System::Int32 >(4) { 1, 0, 0, 0 });
			this->NumericThreads->Name = L"NumericThreads";
			this->NumericThreads->Value = System::Decimal(gcnew cli::array< System::Int32 >(4) { 1, 0, 0, 0 });
			// 
			// GroupBoxImplementation
			// 
			this->GroupBoxImplementation->Controls->Add(this->RadioBtnCpp);
			this->GroupBoxImplementation->Controls->Add(this->RadioBtnAsm);
			resources->ApplyResources(this->GroupBoxImplementation, L"GroupBoxImplementation");
			this->GroupBoxImplementation->Name = L"GroupBoxImplementation";
			this->GroupBoxImplementation->TabStop = false;
			// 
			// GroupBoxLogs
			// 
			this->GroupBoxLogs->Controls->Add(this->TextBoxLogs);
			resources->ApplyResources(this->GroupBoxLogs, L"GroupBoxLogs");
			this->GroupBoxLogs->Name = L"GroupBoxLogs";
			this->GroupBoxLogs->TabStop = false;
			// 
			// TextBoxLogs
			// 
			resources->ApplyResources(this->TextBoxLogs, L"TextBoxLogs");
			this->TextBoxLogs->Name = L"TextBoxLogs";
			this->TextBoxLogs->ReadOnly = true;
			// 
			// DataOutpuBox
			// 
			this->DataOutpuBox->Controls->Add(this->BtnOutputPath);
			this->DataOutpuBox->Controls->Add(this->label1);
			this->DataOutpuBox->Controls->Add(this->TextBoxOutputPath);
			resources->ApplyResources(this->DataOutpuBox, L"DataOutpuBox");
			this->DataOutpuBox->Name = L"DataOutpuBox";
			this->DataOutpuBox->TabStop = false;
			// 
			// BtnOutputPath
			// 
			resources->ApplyResources(this->BtnOutputPath, L"BtnOutputPath");
			this->BtnOutputPath->Name = L"BtnOutputPath";
			this->BtnOutputPath->UseVisualStyleBackColor = true;
			this->BtnOutputPath->Click += gcnew System::EventHandler(this, &MainWin::BtnOutputPath_Click);
			// 
			// label1
			// 
			resources->ApplyResources(this->label1, L"label1");
			this->label1->Name = L"label1";
			// 
			// TextBoxOutputPath
			// 
			resources->ApplyResources(this->TextBoxOutputPath, L"TextBoxOutputPath");
			this->TextBoxOutputPath->Name = L"TextBoxOutputPath";
			this->TextBoxOutputPath->ReadOnly = true;
			// 
			// MainWin
			// 
			resources->ApplyResources(this, L"$this");
			this->AutoScaleMode = System::Windows::Forms::AutoScaleMode::Font;
			this->Controls->Add(this->DataOutpuBox);
			this->Controls->Add(this->GroupBoxLogs);
			this->Controls->Add(this->AdditionalSettings);
			this->Controls->Add(this->DataGroup);
			this->Controls->Add(this->BtnDo);
			this->Controls->Add(this->menuStrip);
			this->FormBorderStyle = System::Windows::Forms::FormBorderStyle::FixedSingle;
			this->MainMenuStrip = this->menuStrip;
			this->MaximizeBox = false;
			this->Name = L"MainWin";
			this->menuStrip->ResumeLayout(false);
			this->menuStrip->PerformLayout();
			this->DataGroup->ResumeLayout(false);
			this->DataGroup->PerformLayout();
			this->AdditionalSettings->ResumeLayout(false);
			this->AdditionalSettings->PerformLayout();
			(cli::safe_cast<System::ComponentModel::ISupportInitialize^>(this->NumericThreads))->EndInit();
			this->GroupBoxImplementation->ResumeLayout(false);
			this->GroupBoxImplementation->PerformLayout();
			this->GroupBoxLogs->ResumeLayout(false);
			this->GroupBoxLogs->PerformLayout();
			this->DataOutpuBox->ResumeLayout(false);
			this->DataOutpuBox->PerformLayout();
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

	private: System::Void BtnOutputPath_Click(System::Object^ sender, System::EventArgs^ e) {
		this->folderBrowserDialog->ShowDialog();
		this->TextBoxOutputPath->Text = this->folderBrowserDialog->SelectedPath;
	}

	public:
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
		/** Konwertuje std::string na String^
		* @param buff: std::string
		* @return String^
		*/
		String^ ToDotNetString(std::string buff) {
			return msclr::interop::marshal_as<String^>(buff);
		}

		/** Konwertuje String^ na std::string
		* @param buff: String^
		* @return std::string
		*/
		std::string ToCppString(String^ buff) {
			return  msclr::interop::marshal_as<std::string>(buff);
		}

	public:
		// Typ CONVERT_TO_RPN potrzebny do wywolania funkcji ConvertToRPN z DLL
		typedef void (*CONVERT_TO_RPN)(const char*, char*);

		// Typ CALC_RPN potrzebny do wywolania funkcji CalcRPN z DLL
		typedef double(*CALC_RPN)(const char*);

		CONVERT_TO_RPN convertToRpnProc;	// Uchwyt dla funkcji ConverToRPN 
		CALC_RPN calcRpnProc;				// Uchwyt dla funkcji CalcRPN 

	private: System::Void BtnDo_Click(System::Object^ sender, System::EventArgs^ e) {

		// TODO: validate();

		this->TextBoxLogs->Text = "";
		log("================PARAMETRY=================");
		log("Dane Ÿród³owe: " + this->TextBoxPath->Text);
		log("Iloœæ w¹tków: " + this->NumericThreads->Value.ToString());
		this->RadioBtnCpp->Checked ? log("Implementacja: C++") : log("Implementacja: ASM");

		HINSTANCE hDll = NULL;													// Uchwyt dla biblioteki

		log("=================BIBLIOTEKA=================");
		log("Próba ³adowania biblioteki DLL, proszê czekaæ ...");
		hDll = this->RadioBtnCpp->Checked ?
			LoadLibrary(TEXT("DLLCpp")) : LoadLibrary(TEXT("DLLAsm"));

		try {
			if (hDll != NULL)
			{
				log("Uda³o za³adowaæ siê bibliotekê DLL :)");
				log("Próba ³adowania potrzebnych funkcji biblotecznych, proszê czekaæ ...");
				
																							// Zaladowanie funkcji bibliotecznych
				convertToRpnProc = (CONVERT_TO_RPN)GetProcAddress(hDll, "ConvertToRPN");
				calcRpnProc = (CALC_RPN)GetProcAddress(hDll, "CalcRPN");
				int numOfThreads = static_cast<int>(this->NumericThreads->Value);			// Ilosc faktycznie uruchomionych watkow

				if (convertToRpnProc != NULL && calcRpnProc != NULL)
				{
					log("Uda³o za³adowaæ siê wymagane funkcje biblioteczne :)");							
					log("=================PLIKI=================");
					log("Analizowanie plikow w katalogu Ÿród³owym");
					
					std::stack<std::string> filesInDir;										// Stos zawierajacy sciezki do plikow	
					for (const auto& entry : std::filesystem::directory_iterator(ToCppString(this->TextBoxPath->Text))) {
						if (entry.is_regular_file())  
							filesInDir.push(entry.path().string());
					}

																							// Sprawdzenie czy ilosc watkow > ilosci plikow
					if (filesInDir.size() < this->NumericThreads->Value)
					{
						log("Iloœæ plików jest mniejsza ni¿ zadeklarowana iloœæ w¹tków");
						numOfThreads = filesInDir.size();									// Nie zezwalamy na "puste" watki
						log("Liczba w¹tków zostaje zmniejszona do: " + std::to_string(numOfThreads));
					}
								
					log("Segregacja plików ze wzglêdu na iloœæ w¹tków");

					array<ThreadClass^>^ cf = gcnew array<ThreadClass^>(numOfThreads);		// Tablica obiektow watkowych
																							// Przyporzadkowanie plikow tak aby kazdy watek mial zblizona ilosc plikow
					int step = round(filesInDir.size() / numOfThreads);
					int counter = 0;
					for (counter = 0; counter < numOfThreads - 1; counter++) {
						cf[counter] = gcnew ThreadClass(this);
						for (int j = 0; j < step; j++) {
							cf[counter]->AddPath(ToDotNetString(filesInDir.top()));
							filesInDir.pop();
						}
					}
					cf[counter] = gcnew ThreadClass(this);
					while (filesInDir.size() > 0) {
						cf[counter]->AddPath(ToDotNetString(filesInDir.top()));
						filesInDir.pop();
					}

					log("Tworzenie w¹tków");

					array<Thread^>^ threads = gcnew array<Thread^>(numOfThreads);			// Tablica watkow

					for (int i = 0; i < numOfThreads; i++)
						threads[i] = gcnew Thread(gcnew ParameterizedThreadStart(&CalculateFiles::CalFile));

					log("Rozpoczêcie wczytywania i przetwarzania danych z plików w w¹tkach");
						
					steady_clock::time_point start = GetTimePoint();						// Otrzymanie czasu poczatkowego timera

					for (int i = 0; i < numOfThreads; i++)
						threads[i]->Start(cf[i]);											// Wystartowanie watkow
						
					for (int i = 0; i < numOfThreads; i++)
						threads[i]->Join();

					steady_clock::time_point stop = GetTimePoint();							// Otrzymanie czasu koncowego timera
					microseconds duration = GetDuration(stop, start);						// Obiczenie czasu				
					
					log("Zakoñczono przetwarzanie plików w w¹tkach");
					log(L"Pliki zosta³y utworzone w katalogu: " + this->TextBoxOutputPath->Text);
					log("Czas przetwarzania plików [microseconds]: " + std::to_string(duration.count()));
				}
				else throw std::runtime_error("Nie uda³o wczytaæ siê wszystkich potrzebnych funkcji z DLL");
				FreeLibrary(hDll);															// Zwolnienie biblioteki
				hDll = NULL;																// Ustawienie uchwytu biblioteki na NULL
			}
			else throw std::runtime_error("Nie uda³o za³adowaæ siê DLL: [hDLL is NULL]");
		}
		catch (const std::exception& ex) {
			log("=================ERROR===================");
			log(ex.what());
		}
	}

	/** Funkcja zwracajaca czas
	*@return Zwraca czas: steady_clock::time_point
	*/
	steady_clock::time_point GetTimePoint()
	{
		return high_resolution_clock::now();
	}

	/** Funkcja zwracajaca czas wykonywanego algorytmu w mikrosekundach
	*@param Stop: const steady_clock::time_point&
	*@param Start: const steady_clock::time_point&
	*@return Zwraca czas w mikrosekundach: microseconds
	*/
	microseconds GetDuration(const steady_clock::time_point& stop, const steady_clock::time_point& start)
	{
		return duration_cast<microseconds>(stop - start);
	}

	/** Klasa zawierjaca obiekt watkowy */
	ref class ThreadClass {
	public:
		MainWin^ mw; // "this" MainWIn
		// Lista z sciezkami do przetworzenia
		System::Collections::Generic::List<String^>^ paths = gcnew System::Collections::Generic::List<String^>();
	public:
		ThreadClass(MainWin^ _mw) {
			mw = _mw;
		}
		/* Metoda dodaje sciezke do listy
		* @param String^ p sciezka do pliku
		*/
		void AddPath(String^ p) {
			paths->Add(p);
		}
	};

	/** Klasa obslugujaca watek */
	ref class CalculateFiles {
	public:
		/* Metoda wykonujaca obliczenia w watkach
		* @param Object^ data obiekt watkowy klasy ThreadClass
		*/
		static void CalFile(Object^ data)
		{	
			ThreadClass^ threadClass = (ThreadClass^)data;							// Zrzutowanie na typ pakujacy dane	
			double result = 0;														// Wynik wyrazenia ONP
			steady_clock::time_point start;
			steady_clock::time_point stop;
			microseconds duration;
			std::ofstream fOut;
			std::string srcPath;													// Œcie¿ka do pliku zrodlowego
			std::string outPath;													// Œcie¿ka do pliku wynikowego
			std::string fInputline;													// Zm. zawierajaca pobrana linie z pliku
			std::string fOutnName;													// Zm. zawierjaca nazwe pliku wynikowego
			std::string ext =														// "Rozszerzenie" pliku wynikowego
				threadClass->mw->RadioBtnCpp->Checked ? ".rCPP" : ".rASM";
			int bSlashPosNext;														// Zm. wykorzystywan do zdobycia nazwy pliku z sciezki
																					// Przetworzenie plikow w petli
			for each (String ^ %st in threadClass->paths) {
				result = 0;
				srcPath = std::string();
				outPath = std::string();
				fInputline = std::string();
				char* rpn = (char*)calloc(256, sizeof(char));							// Alokacja pamieci dla wyrazenia ONP

				srcPath = threadClass->mw->ToCppString(st);
				bSlashPosNext = srcPath.find_last_of('\\') + 1;
				fOutnName = srcPath.substr(bSlashPosNext, srcPath.size() - bSlashPosNext);
				outPath = threadClass->mw->ToCppString(threadClass->mw->TextBoxOutputPath->Text) + "\\" +fOutnName + ext;

				std::ifstream file(srcPath, std::ios::in);
				
				if (file.is_open()) {
					std::getline(file, fInputline);										// Wczytanie wyrazenia z pliku

					// TODO::Sprawdzenie poprawnosci danych
					//

					try {
						// Wyzerowanie wyniku ONP
						start = threadClass->mw->GetTimePoint();					// Otrzymanie czasu poczatkowego timera
						(threadClass->mw->convertToRpnProc)(fInputline.c_str(), rpn);	// Konwersja wyrazenia matemaycznego na ONP
						result = (threadClass->mw->calcRpnProc)(rpn);					// Obliczenie wyrazenia ONP
						stop = threadClass->mw->GetTimePoint();					// Otrzymanie czasu koncowego timera
						duration = threadClass->mw->GetDuration(stop, start);		// Obiczenie czasu			
					}
					catch (const std::runtime_error& e) {
						std::ofstream fOut(outPath, std::ios::out);
						if (fOut.is_open()) {
							fOut << "Wyra¿enie wejœciowe: " << fInputline << '\n';
							fOut << "Nie uda³o dokonaæ siê konwersji wyra¿enia'\n'";
							fOut.close();
							continue;
						}

					}

					std::ofstream fOut(outPath, std::ios::out);							// Stworzenie pliku do zapisu
					if (fOut.good()) {
						// Wypisanie wyrazenia ONP, czasu i wyniku do pliku 
						fOut << "Wyra¿enie wejœciowe: " << fInputline << '\n';
						fOut << "Uzyskane wyra¿enie ONP: ";
						for (int c = 0; c < strlen(rpn); c++) {							// Zapis wyrazenia ONP do pliku wynikowego (this->TextBoxOutputPath->Text)
							fOut << rpn[c];
						}
						fOut << "\nUzyskany wynik obliczeñ: " << result << "\n";		// Zapis wyniku ONP do pliku wynikowego
						fOut << "Uzyskany czas [microseconds]: " << duration.count() << '\n';						// Zapis czasu przetwarzania do pliku wynikowego
						fOut.close();
					} // if fOut.good()
					file.close();
				}
				else {
					String^ msg = L"Nie uda³o otworzyæ siê pliku: " + st;
					MessageBox::Show(msg);
				}
				delete rpn;
			} // for each (String ^ %st in threadClass->paths)
		}
	}; 	
}; 
}
