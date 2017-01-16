#include "windows.h"
#include "IATHook.h"
#include "globals.h"

namespace VermHook
{
	PDWORD GetIATAddress(LPCSTR tModule, LPCSTR tFunc)
	{
		HINSTANCE  hHandle = GetModuleHandle(NULL);
		IMAGE_NT_HEADERS* coffHeader = (IMAGE_NT_HEADERS*)((DWORD)hHandle + (DWORD)((IMAGE_DOS_HEADER*)hHandle)->e_lfanew);
		IMAGE_DATA_DIRECTORY importTableHeader = coffHeader->OptionalHeader.DataDirectory[1];
		IMAGE_IMPORT_DESCRIPTOR* importTable = (IMAGE_IMPORT_DESCRIPTOR*)(importTableHeader.VirtualAddress + (DWORD)hHandle);

		IMAGE_IMPORT_DESCRIPTOR* moduleImports = importTable--;
		char* mName = NULL;

		do
		{
			mName = (char*)((DWORD)hHandle + (++moduleImports)->Name);
		} while (strcmp(tModule, mName) != 0);


		PDWORD oft = (PDWORD)((DWORD)moduleImports->OriginalFirstThunk + (DWORD)hHandle);
		PDWORD ft = (PDWORD)((DWORD)moduleImports->FirstThunk + (DWORD)hHandle);

		int i = 0;

		while (*(oft + i) != 0x00000000)
		{
			char* name = (char *)(*(oft + i) + (DWORD)hHandle + 2);
			if (strcmp(name, tFunc) == 0)
				return ft + i;

			i++;
		}
		return NULL;
	}

	IATHook::IATHook(PDWORD iatAddr, DWORD origAddr, DWORD overrideAddr, LPCSTR name)
	{
		IATAddress = iatAddr;
		OriginalAddress = origAddr;
		OverrideAddress = overrideAddr;
		Name = name;
	}

	IATHook::~IATHook()
	{
		Unhook();
		delete[] Name;
		delete IATAddress;
	}

	IATHook::IATHook(const IATHook* other)
	{
		IATAddress = other->IATAddress;
		OriginalAddress = other->OriginalAddress;
		OverrideAddress = other->OverrideAddress;
		Name = other->Name;
	}

	IATHook* IATHook::Hook(LPCSTR fModule, LPCSTR fName, DWORD overrideAddr)
	{
		PDWORD iat_addr = GetIATAddress(fModule, fName);
		if (iat_addr == NULL)
		{
			LOG("Failed to hook " << fName << ": iat_addr is NULL");
			return NULL;
		}

		DWORD orig_addr = *iat_addr;
		WriteIATMemory(iat_addr, overrideAddr);

		LOG("Hooked function " << fName);
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
		LOG("Unhooked");
	}
}

