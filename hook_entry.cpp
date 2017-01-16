#include "globals.h"
#include "hook.h"
#include "HookRoutine.h"
#include "Utils.h"

FARPROC fPtr;

const string RelativeBaseModFolder = "mods_devel";

BOOL WINAPI DllMain(HINSTANCE, DWORD reason, LPVOID)
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
			VermHook::Utils::DllFail("Failed to create debug console.");

		LOG("DLL_PROCESS_ATTACH");

		char bufd[200];
		GetSystemDirectory(bufd, 200);
		strcat_s(bufd, "\\DINPUT8.dll");

		HINSTANCE hL = LoadLibrary(bufd);

		if (!hL)
		{
			VermHook::Utils::DllFail("Could not load DINPUT8.dll in " + string(bufd));
		}

		fPtr = GetProcAddress(hL, "DirectInput8Create");
		VermHook::InitHook(std::make_unique<VermHook::ModLoaderRoutine>(RelativeBaseModFolder));
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