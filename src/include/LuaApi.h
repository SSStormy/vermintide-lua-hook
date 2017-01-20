#pragma once
#include "Hook.h"

namespace VermHook
{
	class LuaApi
	{
	public:
		class Console
		{
		public:
			static int Out(LuaState* state);
			static int Create(LuaState* state);
		};
		class Path
		{
		public:
			static int GetElements(LuaState* state);
			static int ElementExists(LuaState* state);
		};
	};
}
