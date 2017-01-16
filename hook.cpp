#include "hook.h"
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
	void(*lua_pushcclosure) (LuaState*, LuaCFunction, int);
	void(*lua_setfield) (LuaState*, int, const char*);
	void(*luaL_openlibs) (LuaState*);
	int(*luaL_loadfile) (LuaState*, const char*);
	int(*lua_type)(LuaState*, int);
	const char(*lua_tolstring) (LuaState*, int, size_t*);
	void(*lua_call)(LuaState*, int/*nargs*/, int /*nresults*/);
	void(*lua_getfield)(LuaState*, int /*index*/, const char */*k*/);
	void(*lua_pushstring)(LuaState*, const char */*s*/);
	int(*lua_pcall)(LuaState*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	void(*luaL_openlib) (LuaState*, const char* /*libname*/, const LuaReg*, int /*nup*/);
	void(*LuaRegister) (LuaState*, const char* /*libname*/, const LuaReg*);
	void(*lua_remove) (LuaState*, int /*index*/);
	int(*luaL_loadbuffer)(LuaState*, const char* /*buff*/, size_t, const char* /*name*/);
	int(*luaL_loadstring)(LuaState*, const char*);

	unique_ptr<HookRoutine> Routine;

	inline void LuaMapFunction(LuaState* state, const char* name, LuaCFunction function)
	{
		lua_pushcclosure(state, function, 0);
		lua_setfield(state, LUA_GLOBALSINDEX, name);
	}

	void InitHook(unique_ptr<HookRoutine> routine)
	{
		LOG("Initialize hook.");
		Routine = std::move(routine);

		LOG("mapcalling lua functions");
		auto luaModule = GetModuleHandle(LuaModule.c_str());

#define mapcall(name) *(void**)(&name) = GetProcAddress(luaModule, #name);\
	if(name == nullptr) LOG(#name << " mapcall IS nullptr!")

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
		mapcall(LuaRegister);
		mapcall(lua_remove);
		mapcall(luaL_loadbuffer);
		mapcall(luaL_loadstring);
		
#undef mapcall

		Routine->PostInit();
	}

	void DestroyHook()
	{
		Routine.get_deleter();
	}
}