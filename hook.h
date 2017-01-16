#pragma once
#include "HookRoutine.h"

namespace VermHook
{
	const std::string LuaModule = "lua51.dll"s;
#pragma warning(disable:4138)

	extern void(*lua_pushcclosure) (LuaState*, LuaCFunction, int);
	extern void(*lua_setfield) (LuaState*, int, const char*);
	extern void(*luaL_openlibs) (LuaState*);
	extern int(*luaL_loadfile) (LuaState*, const char*);
	extern int(*lua_type)(LuaState*, int);
	extern const char(*lua_tolstring) (LuaState*, int, size_t*);
	extern void(*lua_call)(LuaState*, int/*nargs*/, int /*nresults*/);

	extern void(*lua_getfield)(LuaState*, int /*index*/, const char */*k*/);
	extern void(*lua_pushstring)(LuaState*, const char */*s*/);
	extern int(*lua_pcall)(LuaState*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	extern void(*luaL_openlib) (LuaState*, const char* /*libname*/, const LuaReg*, int /*nup*/);
	extern void(*LuaRegister) (LuaState*, const char* /*libname*/, const LuaReg*);
	extern void(*lua_remove) (LuaState*, int /*index*/);
	extern int(*luaL_loadbuffer)(LuaState*, const char* /*buff*/, size_t, const char* /*name*/);
	extern int(*luaL_loadstring)(LuaState*, const char*);

	inline void LuaMapFunction(LuaState* state, const string& name, LuaCFunction function);

	void InitHook(unique_ptr<HookRoutine> routine);
	void DestroyHook();
}