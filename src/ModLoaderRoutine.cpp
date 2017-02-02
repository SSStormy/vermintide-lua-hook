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
		Logger::Debug("Routine: ModLoader");

		_iatInitHook = unique_ptr<IATHook>(IATHook::Hook(LuaModule, "luaL_openlibs", (DWORD)ModLoaderRoutine::InitLua));
		_iatLoadBufferHook = unique_ptr<IATHook>(IATHook::Hook(LuaModule, "luaL_loadbuffer", (DWORD)ModLoaderRoutine::LoadBufferHook));

		if (!Utils::ElementExists(Globals::BaseModInitFileDir))
		{
			Logger::Debug("Globals::BaseModInitFileDir (" + string(Globals::BaseModInitFileDir) + ") doesn't exist.");
			Globals::DllReturnValue = FALSE;
		}
	}

	void ModLoaderRoutine::CallLoadBufferNotifier(LuaState* state, const char* methodName, const char* bufName)
	{
		// push the target function onto the stack
		lua_getglobal(state, "__loadBufferHook");
		lua_pushstring(state, methodName);
		lua_gettable(state, -2);

		// push args (self, name)
		lua_getglobal(state, "__loadBufferHook");
		lua_pushstring(state, bufName);
		lua_call(state, 2, 0);

		luaC_pop(state); // get rid of the left over table on the stack
	}

	int ModLoaderRoutine::LoadBufferHook(LuaState* state, const char* buf, size_t size, const char* name)
	{
		CallLoadBufferNotifier(state, "_notify_pre", name);
		int retval = luaL_loadbuffer(state, buf, size, name);
		CallLoadBufferNotifier(state, "_notify_post", name);
		return retval;
	}

	void ModLoaderRoutine::InitLua(LuaState* state)
	{
#define LEXEC(msg, dir) \
		Logger::Debug(msg); \
		result = luaL_dofile(state, dir); \
		if(result != 0) { \
			Logger::Warn("==== FAILED TO INJECT MODLOADER: " + string(lua_tolstring(state, -1, NULL))); \
		return; }

		luaL_openlibs(state);
	
		LuaReg log[] =
		{
			{ "Create",  LuaApi::Log::Create },
			{ "Write",  LuaApi::Log::Write },
			{ "Warn",  LuaApi::Log::Warn},
			{ "Debug",  LuaApi::Log::Debug},
			{ NULL, NULL }
		};

		LuaReg path[]
		{ 
			{ "GetElements", LuaApi::Path::GetElements },
			{ "ElementExists", LuaApi::Path::ElementExists},
			{ NULL, NULL }
		};

		Logger::Debug("Registering custom libraries.");
		luaL_register(state, "Log", log);
		luaL_register(state, "Path", path);

		int result = 1;
		LEXEC("Bootstrapping...", Globals::BootstrapFileDir);
		LEXEC("Running tests...", Globals::TestFileDir);
		LEXEC("Running modloader base...", Globals::BaseModInitFileDir);

		Logger::Debug("Modloader injected.");
	}
}
