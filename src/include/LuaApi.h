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
			static int Dump(LuaState* state);
			static int Toggle(LuaState* state);
			static int IsEnabled(LuaState* state);

		private:
			static string ConcatVaargs(LuaState* state);
			static void GetFunctionInfo(LuaState* state, int* outCount, string* outSrc);
		};

		class Path
		{
		public:
			static int GetElements(LuaState* state);
			static int ElementExists(LuaState* state);
		};
	};
}