/*
  List created from the output of:
    ( find . -name \*.h -exec grep -Hn 'typedef struct'} \; 1>&2 ) 2>&1 | \
       cut -d\  -f 4 | grep -v \{
*/

/* Strategy provided by p6-XML-LibXML:author<FROGGS> */
#ifdef _WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT extern
#endif

#include "libgweather/gweather.h"
#include "libgweather/gweather-private.h";

#define s(name)           DLLEXPORT int sizeof_ ## name  () { return sizeof(name); }
#define st(name1, name2)  DLLEXPORT int sizeof_ ## name2 () { return sizeof(name1); }

typedef struct _GWeatherLocation GWeatherLocation;

s(GWeatherConditions);
st(struct _GWeatherLocation, GWeatherLocation);
s(GWeatherInfo);
s(WeatherLocation);
s(DbLocationRef);
