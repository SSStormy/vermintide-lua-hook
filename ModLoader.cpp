#include "hook.h"
#include "vlua.h"
#include "globals.h"
#include "HookRoutine.h"
#include "IATHook.h"
#include <vector>

namespace VermHook
{
#define BASE_MOD_FOLDER_NAME = "base"

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
		LOG("Reloading mods");
	}
}