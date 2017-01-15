#include "hook.h"
#include "windows.h"
#include "globals.h"
#include "IATHook.h"
#include "HookRoutine.h"

/*
int result = luaL_loadfile(state, "init.lua");
LOG("result " << result);

lua_pcall(state, 0, 1, 0);
*/
namespace VermHook
{
	void(*lua_pushcclosure) (lua_state*, lua_cfunction, int);
	void(*lua_setfield) (lua_state*, int, const char*);
	void(*luaL_openlibs) (lua_state*);
	int(*luaL_loadfile) (lua_state*, const char*);
	int(*lua_type)(lua_state*, int);
	const char(*lua_tolstring) (lua_state*, int, size_t*);
	void(*lua_call)(lua_state*, int/*nargs*/, int /*nresults*/);
	void(*lua_getfield)(lua_state*, int /*index*/, const char */*k*/);
	void(*lua_pushstring)(lua_state*, const char */*s*/);
	int(*lua_pcall)(lua_state*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	void(*luaL_openlib) (lua_state*, const char* /*libname*/, const luaL_reg*, int /*nup*/);
	void(*luaL_register) (lua_state*, const char* /*libname*/, const luaL_reg*);
	void(*lua_remove) (lua_state*, int /*index*/);
	int(*luaL_loadbuffer)(lua_state*, const char* /*buff*/, size_t, const char* /*name*/);
	int(*luaL_loadstring)(lua_state*, const char*);

	HookRoutine* Routine;

	inline void LuaMapFunction(lua_state* state, const char* name, lua_cfunction function)
	{
		lua_pushcclosure(state, function, 0);
		lua_setfield(state, LUA_GLOBALSINDEX, name);
	}

	void InitHook(HookRoutine* routine)
	{
		LOG("Initialize hook.");
		Routine = routine;

		LOG("mapcalling lua functions");
		auto luaModule = GetModuleHandle(LUA_MODULE);

#define mapcall(name) *(void**)(&name) = GetProcAddress(luaModule, #name);\
	if(name == NULL) LOG(#name << " mapcall IS NULL!")

		mapcall(luaL_openlibs);
		mapcall(lua_pushcclosure);
		mapcall(lua_setfield);
		mapcall(lua_call);
		mapcall(lua_type);
		mapcall(lua_tolstring);
		mapcall(lua_getfield);
		mapcall(lua_pushstring);
		mapcall(luaL_loadfile);
		mapcall(lua_pcall);
		mapcall(luaL_openlib);
		mapcall(luaL_register);
		mapcall(lua_remove);
		mapcall(luaL_loadbuffer);
		mapcall(luaL_loadstring);
		
#undef mapcall

		Routine->PostInit();
	}

	void DestroyHook()
	{
		delete Routine;
	}
}