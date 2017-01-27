#pragma once

#include <memory>
#include <string>
#include <iostream>
#include "Log.h"

#define BENCHMARK

using std::unique_ptr;
using std::shared_ptr;
using namespace std::string_literals;
using std::string;

#define LOG_RAW(msg) std::cout  << __FILE__ << "(" << __LINE__ << "): " << msg
#define LOG_T(msg) Logger::Write(msg, __FILE__, __LINE__);
#define LOG_W(msg) Logger::Warn(msg, __FILE__, __LINE__);
#define LOG_D(msg) Logger::Debug(msg, __FILE__, __LINE__);

#ifdef BENCHMARK
#include <chrono>
#define BENCHMARK_START auto __benchmarkStart = std::chrono::high_resolution_clock::now()
#define BENCHMARK_END(obj) VermHook::Logger::Debug(obj + " finished in: "s + std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::high_resolution_clock::now() - __benchmarkStart).count()) + "ms")
#else
#define BENCHMARK_START
#define BENCHMARK_END()
#endif

namespace Globals
{
	static int DllReturnValue;
	static const char* BaseModInitFileDir = "mods/base/main.lua";
	static const char* TestFileDir = "mods/base/tests.lua";
	static const char* BootstrapFileDir = "mods/base/bootstrap.lua";
	static const char* LogFileName = "vermintide-hook.log";
}


