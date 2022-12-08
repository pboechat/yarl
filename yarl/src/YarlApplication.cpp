#include "YarlApplication.h"

using namespace FastCG;

YarlApplication::YarlApplication() : Application({"Yarl", 1024, 768, 60, false, RenderingPath::DEFERRED, {"Yarl"}})
{
}