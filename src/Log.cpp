#include "include/Log.h"

namespace VermHook
{
	bool Logger::IsLoggingOn = true;
	static std::ofstream _out(Globals::LogFileName);

	void Logger::Warn(string msg, const char* filename, int line)
	{
		_write("  [WARNING] ... ", msg, line, filename);
	}

	void Logger::Debug(string msg, const char* filename, int line)
	{
		_write("    [DEBUG] ... ", msg, line, filename);
	}

	void Logger::Write(string msg, const char* filename, int line)
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

	void Logger::_write(std::string prefix, std::string msg, int line, const char* filename)
	{
		RawWrite(prefix);

		if (filename || line)
		{
			RawWrite("[");
			if (filename)
				RawWrite(filename);
			if (line)
				RawWrite("(" + std::to_string(line) + ")");
			RawWrite("] ");
		}

		RawWrite(msg);
		NewLine();
	}
}
