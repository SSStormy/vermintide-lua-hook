#include <windows.h>
#include "globals.h"
#include "hook.h"
#include "HookRoutine.h"

FARPROC fPtr;

#define RELATIVE_BASE_MOD_FOLDER "mods_devel"

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID)
{
	if (reason == DLL_PROCESS_ATTACH)
	{
		if (AllocConsole())
		{
#pragma warning(disable:4996)
			freopen("CONOUT$", "w", stdout);
			freopen("CONOUT$", "w", stderr);
			freopen("CONIN$", "r", stdin);
			SetConsoleTitle("Debug Console");
		}
		else
		{
			DLLFAIL("Failed to create debug console.");
		}

		LOG("DLL_PROCESS_ATTACH");

		char bufd[200];
		GetSystemDirectory(bufd, 200);
		strcat_s(bufd, "\\DINPUT8.dll");
			
		HINSTANCE hL = LoadLibrary(bufd);

		if (!hL)
		{
			char err[300] = "Could not load DINPUT8.dll in ";
			strcat_s(err, bufd);
			DLLFAIL(err);
		}

		fPtr = GetProcAddress(hL, "DirectInput8Create");
		VermHook::InitHook(new VermHook::ModLoaderRoutine(RELATIVE_BASE_MOD_FOLDER));
	}
	else if (reason == DLL_PROCESS_DETACH)
	{
		LOG("DLL_PROCESS_DETACH");
		VermHook::DestroyHook();
	}
	
	return 1;
}

extern "C" __declspec(dllexport) __declspec(naked) void DirectInput8Create()
{
	LOG("dinput8 redirect");

	__asm
	{
		jmp fPtr;
	}
}
