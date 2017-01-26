#pragma once
#include "Hook.h"

namespace VermHook
{
	class LuaApi
	{
	public:
		class Log
		{
		public:
			static int Write(LuaState* state);
			static int Warn(LuaState* state);
			static int Debug(LuaState* state);
			static int Create(LuaState* state);

		private:
			static string HandleConsoleOut(LuaState* state, string prefix);
		};

		class Path
		{
		public:
			static int GetElements(LuaState* state);
			static int ElementExists(LuaState* state);
		};
	};
}