#pragma once
#include "globals.h"
#include <Windows.h>

namespace VermHook
{
	class IATHook
	{
	public:
		const PDWORD IATAddress;
		const DWORD OriginalAddress;
		const DWORD OverrideAddress;
		const string Name;

		static PDWORD GetIATAddress(const string& tModule, const string& tFunc);
		static IATHook* Hook(const string& fModule, const string& fName, DWORD overrideAddr);
		~IATHook();

		void Unhook();
	private:
		bool _isHooked = false;

		static void WriteIATMemory(const PDWORD iatPtr, const DWORD newVal);
		IATHook::IATHook(const PDWORD iatAddr, const DWORD origAddr, const DWORD overrideAddr, const string& name);
	};
}