#include "include/IATHook.h"
#include "include/Globals.h"

namespace VermHook
{
	PDWORD IATHook::GetIATAddress(const string& tModule, const string& tFunc)
	{
		const char* tModuleC = tModule.c_str();
		const char* tFuncC = tFunc.c_str();

		HINSTANCE  hHandle = GetModuleHandle(NULL);
		IMAGE_NT_HEADERS* coffHeader = (IMAGE_NT_HEADERS*)((DWORD)hHandle + (DWORD)((IMAGE_DOS_HEADER*)hHandle)->e_lfanew);
		IMAGE_DATA_DIRECTORY importTableHeader = coffHeader->OptionalHeader.DataDirectory[1];
		IMAGE_IMPORT_DESCRIPTOR* importTable = (IMAGE_IMPORT_DESCRIPTOR*)(importTableHeader.VirtualAddress + (DWORD)hHandle);

		IMAGE_IMPORT_DESCRIPTOR* moduleImports = importTable--;
		char* mName = nullptr;

		do
		{
			mName = (char*)((DWORD)hHandle + (++moduleImports)->Name);
		} while (strcmp(tModuleC, mName) != 0);


		PDWORD oft = (PDWORD)((DWORD)moduleImports->OriginalFirstThunk + (DWORD)hHandle);
		PDWORD ft = (PDWORD)((DWORD)moduleImports->FirstThunk + (DWORD)hHandle);

		int i = 0;
		PDWORD retval = NULL;

		while (*(oft + i) != 0x00000000)
		{
			char* name = (char *)(*(oft + i) + (DWORD)hHandle + 2);
			if (strcmp(name, tFuncC) == 0)
			{
				retval = ft + i;
				break;
			}
			i++;
		}
		return retval;
	}

	IATHook::IATHook(const PDWORD iatAddr, const DWORD origAddr, const DWORD overrideAddr, const string& name)
		: IATAddress(iatAddr), OriginalAddress(origAddr), OverrideAddress(overrideAddr), Name(name)
	{
	}

	IATHook::~IATHook()
	{
		Unhook();
	}

	IATHook* IATHook::Hook(const string& fModule, const string& fName, DWORD overrideAddr)
	{
		PDWORD iat_addr = GetIATAddress(fModule, fName);
		if (iat_addr == nullptr)
		{
			Logger::Warn("Failed to hook " + string(fName) + ": iat_addr is nullptr");
			return nullptr;
		}

		DWORD orig_addr = *iat_addr;
		WriteIATMemory(iat_addr, overrideAddr);

		Logger::Debug("Hooked function " + fName);
		return new IATHook(iat_addr, orig_addr, overrideAddr, fName);
	}

	void IATHook::WriteIATMemory(PDWORD iatPtr, DWORD newVal)
	{
		DWORD oldProtect = NULL;
		VirtualProtect(iatPtr, sizeof(DWORD), PAGE_READWRITE, &oldProtect);
		(*iatPtr) = newVal;
		VirtualProtect(iatPtr, sizeof(DWORD), oldProtect, &oldProtect);
	}

	void IATHook::Unhook()
	{
		if (_isHooked)
			return;

		_isHooked = true;
		WriteIATMemory(IATAddress, OriginalAddress);
		Logger::Debug("Unhooked");
	}
}

