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
		SetConsoleTitle("Vermintide LUA");
		freopen("CONOUT$", "w", stdout);
		freopen("CONOUT$", "w", stderr);
		freopen("CONIN$", "r", stdin);

		LOG("DLL_PROCESS_ATTACH");

		char buf[200];
		GetSystemDirectory(buf, 200);
		strcat_s(buf, "\\DINPUT8.dll");

		HINSTANCE hL = LoadLibrary(buf);

		if (!hL)
		{
			LOG("Could not load DINPUT8.dll in " + string(buf));
			return FALSE;
		}

		fPtr = GetProcAddress(hL, "DirectInput8Create");

		VermHook::InitHook();
		BENCHMARK_END("InitHook");
	}
	else if (reason == DLL_PROCESS_DETACH)
	{
		LOG("DLL_PROCESS_DETACH");
		VermHook::DestroyHook(); 
	}
	
	return Globals::DllReturnValue;
}

extern "C" __declspec(dllexport) __declspec(naked) void DirectInput8Create()
{
	LOG("dinput8 redirect");

	__asm
	{
		jmp fPtr;
	}
}