#include "include/Hook.h"
#include "include/Globals.h"
#include "include/IATHook.h"
#include "include/Routine/ModLoaderRoutine.h"
#include <assert.h>

namespace VermHook
{
	void(*lua_pushcclosure) (LuaState*, LuaCFunction, int);
	void(*lua_setfield) (LuaState*, int, const char*);
	void(*luaL_openlibs) (LuaState*);
	int(*luaL_loadfile) (LuaState*, const char*);
	int(*lua_type)(LuaState*, int);
	const char* (*lua_tolstring) (LuaState*, int, size_t*);
	void(*lua_call)(LuaState*, int/*nargs*/, int /*nresults*/);
	void(*lua_getfield)(LuaState*, int /*index*/, const char */*k*/);
	void(*lua_pushstring)(LuaState*, const char */*s*/);
	int(*lua_pcall)(LuaState*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	void(*luaL_openlib) (LuaState*, const char* /*libname*/, const LuaReg*, int /*nup*/);
	void(*luaL_register) (LuaState*, const char* /*libname*/, const LuaReg*);
	void(*lua_remove) (LuaState*, int /*index*/);
	int(*luaL_loadbuffer)(LuaState*, const char* /*buff*/, size_t, const char* /*name*/);
	int(*luaL_loadstring)(LuaState*, const char*);
	void(*lua_pushboolean)(LuaState*, int);
	int(*lua_gettop)(LuaState*);
	void(*lua_settable)(LuaState*, int /*index*/);
	int(*luaL_error)(LuaState*, const char */*fmt*/, ...);
	void(*lua_createtable)(LuaState*, int /*narr*/, int /*nrec*/);
	void(*lua_pushnil)(LuaState*);
	int(*lua_toboolean)(LuaState*, int /*index*/);
	void(*lua_rawseti)(LuaState*, int /*index*/, int /*n*/);
	void(*lua_gettable)(LuaState*, int /*index*/);

#define lua_pop_top lua_remove(state, lua_gettop(state))

	inline bool luaC_toboolean(LuaState* state, int index)
	{
		return lua_toboolean(state, index) == 1;
	}

	inline int luaL_dofile(LuaState* state, const char* fdir)
	{
		return (luaL_loadfile(state, fdir) || lua_pcall(state, 0, -1, 0));
	}

	inline void luaC_pop(LuaState* state, int n)
	{
		assert(n > 0);

		if (n == 1)
		{
			lua_pop_top;
			return;
		}

		for (int i = 0; i < n; i++)
		{
			lua_pop_top;
		}
	}


	typedef ModLoaderRoutine Routinetype;

	unique_ptr<Routinetype> routine = nullptr;

	void InitHook()
	{
		Logger::Debug("Initialize hook.");
		routine = std::make_unique<Routinetype>();

		Logger::Debug("mapcalling lua functions");
		auto luaModule = GetModuleHandle(LuaModule.c_str());

#define mapcall(name) *(void**)(&name) = GetProcAddress(luaModule, #name);\
					assert(name != nullptr);

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
		mapcall(luaL_register);
		mapcall(lua_pushboolean);
		mapcall(lua_gettop);
		mapcall(lua_settable);
		mapcall(luaL_error);
		mapcall(lua_createtable);
		mapcall(lua_pushnil);
		mapcall(lua_toboolean);
		mapcall(lua_rawseti);
		mapcall(lua_gettable);
#undef mapcall

		routine->PostInit();
	}

	void DestroyHook()
	{
		routine.reset();
	}
}
