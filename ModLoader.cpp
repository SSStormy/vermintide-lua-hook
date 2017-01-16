#include "hook.h"
#include "vlua.h"
#include "globals.h"
#include "HookRoutine.h"
#include "IATHook.h"
#include <vector>

namespace VermHook
{
#define BASE_MOD_FOLDER_NAME "base"

	namespace
	{
		int hep_luaL_loadbuffer(lua_state* state, const char* buffer, size_t sz, const char* name)
		{
			return luaL_loadbuffer(state, buffer, sz, name);
		}
	}

	std::vector<IATHook*> *_hooks = new std::vector<IATHook*>();

	ModLoaderRoutine::ModLoaderRoutine(const char* relativeModFldr)
	{
		RelativeModFolderDirectory = relativeModFldr;
	}

	ModLoaderRoutine::~ModLoaderRoutine()
	{
		for (auto hook : *_hooks)
		{
			hook->Unhook();
			delete hook;
		}

		delete Mods;
		delete _hooks;
	}

	void ModLoaderRoutine::PostInit()
	{
		LOG("Routine: ExportHook");
		_hooks->push_back(IATHook::Hook(LUA_MODULE, "luaL_loadbuffer", (DWORD)hep_luaL_loadbuffer));

		ReloadMods();
	}

	void ModLoaderRoutine::ReloadMods()
	{
		SAVE_PWD;
		LOG("Reloading mods");
		SetCurrentDirectory(RelativeModFolderDirectory);

		LoadMod(BASE_MOD_FOLDER_NAME);

		WIN32_FIND_DATA fi;
		HANDLE h = FindFirstFileEx("*", FindExInfoStandard, &fi, FindExSearchLimitToDirectories ,NULL, 0);

		if (h != INVALID_HANDLE_VALUE)
		{
			do
			{
				if (fi.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY
					&& !(*fi.cFileName == '.' || fi.cFileName[1] == '.')
					&& strcmp(BASE_MOD_FOLDER_NAME, fi.cFileName) != 0)
				{
					LoadMod(fi.cFileName);
				}
					
			} while (FindNextFile(h, &fi));

			FindClose(h);
		}

		RESTORE_PWD;
	}

#define MOD_CONFIG_FNAME "config.json"

	void ModLoaderRoutine::LoadMod(LPCSTR rFdir)
	{
		LOG("Loading mod folder at relative dir " << rFdir);
		SAVE_PWD;

		SetCurrentDirectory(rFdir);
		if (!Utils::FileExists(MOD_CONFIG_FNAME))
		{
			DLLFAIL_C(3, rFdir, ": is missing config: ", MOD_CONFIG_FNAME);
		}

		Mods->push_back(new LuaMod(rFdir, MOD_CONFIG_FNAME));

		RESTORE_PWD;
	}
}