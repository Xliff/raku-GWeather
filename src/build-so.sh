srcdir=`pwd`
cd /usr/src/libgweather-40.0/libgweather
gcc -DGWEATHER_I_KNOW_THIS_IS_UNSTABLE -DGWEATHER_COMPILATION -I/usr/src/libgweather-40.0 -I/usr/src/libgweather-40.0/build `pkg-config --cflags gweather-3.0`  -c weather-sun.c -fPIC -Wno-deprecated-declarations -shared -o $srcdir/weather-sun.o
gcc -DGWEATHER_I_KNOW_THIS_IS_UNSTABLE -DGWEATHER_COMPILATION -I/usr/src/libgweather-40.0 -I/usr/src/libgweather-40.0/build `pkg-config --cflags gweather-3.0`  -c weather-moon.c -fPIC -Wno-deprecated-declarations -shared -o $srcdir/weather-moon.o
cd -
gcc -DGWEATHER_I_KNOW_THIS_IS_UNSTABLE weather-sun.o weather-moon.o -fPIC -Wno-deprecated-declarations -shared -o libgweather-supplement.so
cp libgweather-supplement.so ../resources/lib/x86_64/linux
