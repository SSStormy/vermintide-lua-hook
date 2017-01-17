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

			// Logs to console
			static int Out(LuaState* state);

			/*
				Creates a new console window.
				Returns: (Type: boolean) See MSDN, AllocConsole function.
			*/
			static int Create(LuaState* state);
		};
	};
}