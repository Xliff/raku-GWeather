gcc -DGWEATHER_I_KNOW_THIS_IS_UNSTABLE -I/usr/src/libgweather-40.0 -I/usr/src/libgweather-40.0/build `pkg-config --cflags gweather-3.0`  00-struct-sizes.c -fPIC -Wno-deprecated-declarations -shared -o 00-struct-sizes.so `pkg-config --libs gweather-3.0`
