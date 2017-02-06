#pragma once
#include <fstream>
#include <vector>
#include "Globals.h"

namespace VermHook
{
	class Logger
	{
	private:
		static void _write(std::string prefix, std::string msg, int line, const char* filename);
	public:
		static void Warn(std::string msg, const char* filename = nullptr, int line = 0);
		static void Debug(std::string msg, const char* filename = nullptr, int line = 0);
		static void Write(std::string msg, const char* filename = nullptr, int line = 0);
		static void RawWrite(std::string msg);
		static void NewLine();
	};
}