use v6.c;

use GLib::Raw::Exports;
use GIO::Raw::Exports;

unit package GWeather::Raw::Exports;

our @weather-exports is export;

our %exported;

BEGIN {
  @weather-exports = <
    GWeather::Raw::Definitions
    GWeather::Raw::Enums
    GWeather::Raw::Structs
  >;
}
