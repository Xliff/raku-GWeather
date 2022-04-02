use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GWeather::Raw::Definitions;

unit package GWeather::Raw::TimeZone;

### /usr/src/libgweather-40.0/libgweather/gweather-timezone.h

sub gweather_timezone_get_by_tzid (Str $tzid)
  returns GWeatherTimezone
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_dst_offset (GWeatherTimezone $zone)
  returns gint
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_name (GWeatherTimezone $zone)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_offset (GWeatherTimezone $zone)
  returns gint
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_type ()
  returns GType
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_tzid (GWeatherTimezone $zone)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_timezone_get_utc ()
  returns GWeatherTimezone
  is native(gweather)
  is export
{ * }

sub gweather_timezone_has_dst (GWeatherTimezone $zone)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_timezone_ref (GWeatherTimezone $zone)
  returns GWeatherTimezone
  is native(gweather)
  is export
{ * }

sub gweather_timezone_unref (GWeatherTimezone $zone)
  is native(gweather)
  is export
{ * }
