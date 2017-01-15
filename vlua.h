#pragma once

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

#define LUA_GLOBALSINDEX	(-10002)

	class lua_state;
	typedef int(*lua_cfunction) (lua_state*);

	class luaL_reg
	{
		const char* name;
		lua_cfunction function;
	};
}
