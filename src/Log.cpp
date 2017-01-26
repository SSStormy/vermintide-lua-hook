#include "include/Log.h"

namespace VermHook
{
	static std::ofstream _out(Globals::LogFileName);

	void Logger::Warn(string msg, const char* line, const char* filename)
	{
		Write("[!WARNING] "s + msg, line, filename);
	}

	void Logger::Debug(string msg, const char* line, const char* filename)
	{
		Write(msg, line, filename);
	}

	void Logger::Write(string msg, const char* line, const char* filename)
	{
		_write(msg.c_str(), line, filename);
	}

	void Logger::_write(const char* msg, const char* line, const char* filename)
	{
		if (filename)
			_out << filename;
		if (line)
			_out << "(" << line << ")";

		std::cout << msg << std::endl;
		_out << msg << std::endl;
	}
}
