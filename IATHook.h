#pragma once
#include "windows.h"

namespace VermHook
{
	PDWORD GetIATAddress(LPCSTR tModule, LPCSTR tFunc);

	class IATHook
	{
	public:
		PDWORD IATAddress;
		DWORD OriginalAddress;
		DWORD OverrideAddress;
		LPCSTR Name;

		static IATHook* Hook(LPCSTR fModule, LPCSTR fName, DWORD overrideAddr);
		void Unhook();

		~IATHook();
		IATHook(const IATHook* other);

	private:
		BOOL _isHooked = false;

		IATHook::IATHook(PDWORD iatAddr, DWORD origAddr, DWORD overrideAddr, LPCSTR name);
		static void WriteIATMemory(PDWORD iatPtr, DWORD newVal);
	};
}