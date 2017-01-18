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

			/*
                Writes objects to stdout.
                Params: variadic lua objects.
                Returns: --
            */
			static int Out(LuaState* state);
			/*
				Creates a new console window. See MSDN, AllocConsole function.
                Params: --
				Returns: boolean
			*/
			static int Create(LuaState* state);
		};
        class Directory
        {
        public:
            /*
                Indexes all files in a directory.
                Params: string which represents the directory.
                Returns: an indexed table of strings that represent the name of files that exist at the given directory.
            */
            static int GetFiles(LuaState* state);
            /*
                Indexes all folders in a directory
                Params: string which represents the directory.
                Returns: an indexed table of strings that represent the name of folders that exist at the given directory.
            */
            static int GetFolders(LuaState* state);
            /*
                Check if an element (folder, file etc) exists at the given path.
                Params: string which holds the path
                Returns: whether the element exists or not.
            */
            static int ElementExists(LuaState* state);  
        private:
            static inline const char* AssertStrArg(LuaState* state); 
        }
	};
}
