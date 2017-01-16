#pragma once
#include "vlua.h"
#include "HookRoutine.h"

namespace VermHook
{
#define LUA_MODULE "lua51.dll"

	extern void(*lua_pushcclosure) (lua_state*, lua_cfunction, int);
	extern void(*lua_setfield) (lua_state*, int, const char*);
	extern void(*luaL_openlibs) (lua_state*);
	extern int(*luaL_loadfile) (lua_state*, const char*);
	extern int(*lua_type)(lua_state*, int);
	extern const char(*lua_tolstring) (lua_state*, int, size_t*);
	extern void(*lua_call)(lua_state*, int/*nargs*/, int /*nresults*/);

	extern void(*lua_getfield)(lua_state*, int /*index*/, const char */*k*/);
	extern void(*lua_pushstring)(lua_state*, const char */*s*/);
	extern int(*lua_pcall)(lua_state*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	extern void(*luaL_openlib) (lua_state*, const char* /*libname*/, const luaL_reg*, int /*nup*/);
	extern void(*luaL_register) (lua_state*, const char* /*libname*/, const luaL_reg*);
	extern void(*lua_remove) (lua_state*, int /*index*/);
	extern int(*luaL_loadbuffer)(lua_state*, const char* /*buff*/, size_t, const char* /*name*/);
	extern int(*luaL_loadstring)(lua_state*, const char*);

	inline void LuaMapFunction(lua_state* state, const char* name, lua_cfunction function);

	void InitHook(HookRoutine* routine);
	void DestroyHook();
}