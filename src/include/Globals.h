#pragma once

#include <memory>
#include <string>
#include <iostream>

#define BENCHMARK

using std::unique_ptr;
using std::shared_ptr;
using namespace std::string_literals;
using std::string;

#define LOG(msg) LOG_SLIM(__FILE__ << "(" << __LINE__ << "): " << msg)
#define LOG_SLIM(msg) std::cout << msg << std::endl

#ifdef BENCHMARK
#include <chrono>
#define BENCHMARK_START auto __benchmarkStart = std::chrono::high_resolution_clock::now()
#define BENCHMARK_END(obj) LOG(obj " finished in: " << std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::high_resolution_clock::now() - __benchmarkStart).count() << "ms")
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
}
