#include "hook.h"
#include "vlua.h"
#include "globals.h"
#include "HookRoutine.h"
#include "IATHook.h"
#include "Utils.h"

namespace VermHook
{
	const string ModLoaderRoutine::BaseModFolderName = "base";
	const string ModLoaderRoutine::ModConfigFilename = "config.json";

	namespace
	{
		int hep_luaL_loadbuffer(LuaState* state, const char* buffer, size_t sz, const char* name)
		{
			return luaL_loadbuffer(state, buffer, sz, name);
		}
	}

	ModLoaderRoutine::ModLoaderRoutine(const string& relativeModFldr) : RelativeModFolderDirectory(relativeModFldr)
	{
	}

	ModLoaderRoutine::~ModLoaderRoutine()
	{
		for (auto& iat : _iatHooks)
			iat->Unhook;
	}

	void ModLoaderRoutine::PostInit()
	{
		LOG("Routine: ExportHook");

		_iatHooks.push_back(
			unique_ptr<IATHook>(
				IATHook::Hook(LuaModule, "luaL_loadbuffer", (unsigned long)hep_luaL_loadbuffer)));

		ReloadMods();
	}

	void ModLoaderRoutine::ReloadMods()
	{
		LOG("Reloading mods");
		SAVE_PWD_N(RelativeModFolderDirectory.c_str());

		const char* bmfnC = BaseModFolderName.c_str();
		LoadMod(bmfnC);

		WIN32_FIND_DATA fi;
		HANDLE h = FindFirstFileEx("*", FindExInfoStandard, &fi, FindExSearchLimitToDirectories ,nullptr, 0);

		if (h != INVALID_HANDLE_VALUE)
		{
			do
			{
				if (fi.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY
					&& !(*fi.cFileName == '.' || fi.cFileName[1] == '.')
					&& strcmp(bmfnC, fi.cFileName) != 0)
				{
					LoadMod(fi.cFileName);
				}
					
			} while (FindNextFile(h, &fi));

			FindClose(h);
		}
		RESTORE_PWD;
	}


	void ModLoaderRoutine::LoadMod(LPCSTR rFdir)
	{
		LOG("Loading mod folder at relative dir " << rFdir);
		SAVE_PWD_N(rFdir);

		if (!Utils::FileExists(ModConfigFilename.c_str()))
			Utils::DllFail(string(rFdir) + ": is missing config: " + ModConfigFilename);

		_mods.push_back(std::make_unique<LuaMod>(rFdir, ModConfigFilename));

		RESTORE_PWD;
	}
}