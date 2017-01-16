#pragma once

#include <memory>
#include <string>
#include <iostream>

using std::unique_ptr;
using std::shared_ptr;
using namespace std::string_literals;
using std::string;

#define LOG(msg) std::cout << __FILE__ << "(" << __LINE__ << "): " << msg << std::endl

