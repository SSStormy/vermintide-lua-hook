#include "include/Log.h"

namespace VermHook
{
	static std::ofstream _out(Globals::LogFileName);

	void Logger::Warn(string msg, const char* line, const char* filename)
	{
		_write("  [WARNING] ... ", msg, line, filename);
	}

	void Logger::Debug(string msg, const char* line, const char* filename)
	{
		_write("    [DEBUG] ... ", msg, line, filename);
	}

	void Logger::Write(string msg, const char* line, const char* filename)
	{
		_write("            ... ", msg, line, filename);
	}

	void Logger::RawWrite(std::string msg)
	{
		std::cout << msg;
		_out << msg;
	}

	void Logger::NewLine()
	{
		std::cout << std::endl;
		_out << std::endl;
	}

	void Logger::_write(std::string prefix, std::string msg, const char* line, const char* filename)
	{
		RawWrite(prefix);

		if (filename || line)
		{
			RawWrite("[");
			if (filename)
				RawWrite(filename);
			if (line)
				RawWrite("(" + string(line) + ")");
			RawWrite("]");
		}

		RawWrite(msg);
		NewLine();
	}
}
