#pragma once
#include "Globals.h"

namespace VermHook
{
#define LUA_TNONE               (-1)

#define LUA_TNIL                0
#define LUA_TBOOLEAN            1
#define LUA_TLIGHTUSERDATA      2
#define LUA_TNUMBER             3
#define LUA_TSTRING             4
#define LUA_TTABLE              5
#define LUA_TFUNCTION           6
#define LUA_TUSERDATA           7
#define LUA_TTHREAD             8

#define LUA_ERRRUN      2
#define LUA_ERRSYNTAX   3
#define LUA_ERRMEM      4
#define LUA_ERRERR      5
#define LUA_ERRFILE     (LUA_ERRERR+1)

#define LUA_GLOBALSINDEX	(-10002)
#define LUA_IDSIZE      60


	class LuaState;
	typedef int(*LuaCFunction) (LuaState*);

	typedef struct LuaReg
	{
		const char* name;
		LuaCFunction function;
	} LuaReg;

	typedef struct LuaDebug {
		int event;
		const char *name;           /* (n) */
		const char *namewhat;       /* (n) */
		const char *what;           /* (S) */
		const char *source;         /* (S) */
		int currentline;            /* (l) */
		int nups;                   /* (u) number of upvalues */
		int linedefined;            /* (S) */
		int lastlinedefined;        /* (S) */
		char short_src[LUA_IDSIZE]; /* (S) */
	} LuaDebug;

	const std::string LuaModule = "lua51.dll"s;
#pragma warning(disable:4138)

	extern void(*lua_pushcclosure) (LuaState*, LuaCFunction, int);
	extern void(*lua_setfield) (LuaState*, int, const char*);
	extern void(*luaL_openlibs) (LuaState*);
	extern int(*luaL_loadfile) (LuaState*, const char*);
	extern int(*lua_type)(LuaState*, int);
	extern const char*(*lua_tolstring) (LuaState*, int, size_t*);
	extern void(*lua_call)(LuaState*, int/*nargs*/, int /*nresults*/);
	extern void(*lua_getfield)(LuaState*, int /*index*/, const char* /*k*/);
	extern void(*lua_pushstring)(LuaState*, const char* /*s*/);
	extern int(*lua_pcall)(LuaState*, int /*nargs*/, int /*nresults*/, int /*errfunc*/);
	extern void(*luaL_openlib) (LuaState*, const char* /*libname*/, const LuaReg*, int /*nup*/);
	extern void(*LuaRegister) (LuaState*, const char* /*libname*/, const LuaReg*);
	extern void(*lua_remove) (LuaState*, int /*index*/);
	extern int(*luaL_loadbuffer)(LuaState*, const char* /*buff*/, size_t, const char* /*name*/);
	extern int(*luaL_loadstring)(LuaState*, const char*);
	extern void(*luaL_register) (LuaState*, const char* /*libname*/, const LuaReg*);
	extern void(*lua_pushboolean)(LuaState*, int);
	extern int(*lua_gettop)(LuaState*);
	extern void(*lua_settable)(LuaState*, int /*index*/);
	extern int(*luaL_error)(LuaState*, const char */*fmt*/, ...);
	extern void(*lua_createtable)(LuaState*, int /*narr*/, int /*nrec*/);
	extern void(*lua_pushnil)(LuaState*);
	extern int(*lua_toboolean)(LuaState*, int /*index*/);
	extern inline int luaL_dofile(LuaState* state, const char* fileDir);
	extern void(*lua_rawseti)(LuaState*, int /*index*/, int /*n*/);
	extern void(*lua_gettable)(LuaState*, int /*index*/);
	extern int (*lua_getinfo)(LuaState*, const char */*what*/, LuaDebug*/*ar*/);
	extern int(*lua_getstack)(LuaState*, int /*level*/, LuaDebug */*ar*/);

#define lua_getglobal(L,s)  lua_getfield(L, LUA_GLOBALSINDEX, s)
#define luaC_pushboolean(L,b)	lua_pushboolean(L, b ? 1 : 0)

	// luaC for lua custom
	extern inline void luaC_pop(LuaState* state, int n = 1);
	extern inline bool luaC_toboolean(LuaState* state,  int index);

	void InitHook();
	void DestroyHook();
}