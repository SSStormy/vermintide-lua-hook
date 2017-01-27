#include "include/Globals.h"
#include "include/Hook.h"
#include "include/Routine/DumpLuaRoutine.h"
#include "include/Routine/ModLoaderRoutine.h"
#include "include/Utils.h"

FARPROC fPtr;

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID)
{
	BENCHMARK_START;

	Globals::DllReturnValue = TRUE;

	if (reason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(hInst);
		AllocConsole();

#pragma warning(disable:4996)
		SetConsoleTitle("Vermintide LUA hook");
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
		freopen("CONIN$", "r", stdin);

		VermHook::Logger::Debug("DLL_PROCESS_ATTACH", false, false);

		char buf[200];
		GetSystemDirectory(buf, 200);
		strcat_s(buf, "\\DINPUT8.dll");

		HINSTANCE hL = LoadLibrary(buf);

		if (!hL)
		{
			VermHook::Logger::Warn("DLL_PROCESS_ATTACH");
			return FALSE;
		}

		fPtr = GetProcAddress(hL, "DirectInput8Create");

		VermHook::InitHook();

		BENCHMARK_END("InitHook"s);
	}
	else if (reason == DLL_PROCESS_DETACH)
	{
		VermHook::Logger::Warn("DLL_PROCESS_ATTACH");
		VermHook::DestroyHook(); 
	}
	
	return Globals::DllReturnValue;
}

extern "C" __declspec(dllexport) __declspec(naked) void DirectInput8Create()
{
	LOG_RAW("dinput8 redirect");

	__asm
	{
		jmp fPtr;
	}
}