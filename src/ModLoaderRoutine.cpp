#include "include/Hook.h"
#include "include/Globals.h"
#include "include/Routine/ModLoaderRoutine.h"
#include "include/IATHook.h"
#include "include/Utils.h"
#include "include/LuaApi.h"

namespace VermHook
{
	void ModLoaderRoutine::PostInit()
	{
		LOG("Routine: ModLoader");

		_iatInitHook = unique_ptr<IATHook>(IATHook::Hook(LuaModule, "luaL_openlibs", (DWORD)ModLoaderRoutine::InitLua));

		if (!Utils::ElementExists(Globals::BaseModInitFileDir))
		{
			LOG("Globals::BaseModInitFileDir (" << string(Globals::BaseModInitFileDir) << ") doesn't exist.");
			Globals::DllReturnValue = FALSE;
		}
	}

	void ModLoaderRoutine::InitLua(LuaState* state)
	{
#define LEXEC(msg, dir) \
		LOG(msg); \
		result = luaL_dofile(state, dir); \
		if(result != 0) { \
			LOG("==== FAILED TO INJECT MODLOADER: " << lua_tolstring(state, -1, NULL)); \
		return; }

		luaL_openlibs(state);
	
		LuaReg console[] =
		{
			{ "create",  LuaApi::Console::Create },
			{ "out",  LuaApi::Console::Out},
			{ NULL, NULL }
		};

		LuaReg path[]
		{ 
			{ "get_elements", LuaApi::Path::GetElements },
			{ "element_exists", LuaApi::Path::ElementExists},
			{ NULL, NULL }
		};

		LOG("Registering custom libraries.");
		luaL_register(state, "console", console);
		luaL_register(state, "path", path);

		int result = 1;
		LEXEC("Bootstrapping...", Globals::BootstrapFileDir);
		LEXEC("Running tests...", Globals::TestFileDir);
		LEXEC("Running modloader base...", Globals::BaseModInitFileDir);

		LOG("Modloader injected.");
	}
}
