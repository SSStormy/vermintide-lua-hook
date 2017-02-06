#pragma once
#include <fstream>
#include <vector>
#include "Globals.h"

namespace VermHook
{
	class Logger
	{
	private:
		static void _write(std::string prefix, std::string msg, const char* line, const char* filename);
	public:
		static void Warn(std::string msg, const char* line = nullptr, const char* filename = nullptr);
		static void Debug(std::string msg, const char* line = nullptr, const char* filename = nullptr);
		static void Write(std::string msg, const char* line = nullptr, const char* filename = nullptr);
		static void RawWrite(std::string msg);
	};
}