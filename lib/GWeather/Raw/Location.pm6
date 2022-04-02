use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GLib::Raw::Object;
use GIO::Raw::Definitions;
use GIO::Raw::Structs;
use GWeather::Raw::Definitions;
use GWeather::Raw::Enums;
use GWeather::Raw::Structs;

### /usr/src/libgweather-40.0/libgweather/gweather-location.h

sub gweather_location_deserialize (
  GWeatherLocation $world,
  GVariant         $serialized
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_detect_nearest_city (
  GWeatherLocation $loc,
  gdouble          $lat,
  gdouble          $lon,
  GCancellable     $cancellable,
                   &callback (GWeatherLocation, GAsyncResult, gpointer),
  gpointer         $user_data
)
  is native(gweather)
  is export
{ * }

sub gweather_location_detect_nearest_city_finish (
  GAsyncResult            $result,
  CArray[Pointer[GError]] $error
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_equal (GWeatherLocation $one, GWeatherLocation $two)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_location_find_by_country_code (
  GWeatherLocation $world,
  Str              $country_code
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_find_by_station_code (
  GWeatherLocation $world,
  Str              $station_code
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_find_nearest_city (
  GWeatherLocation $loc,
  gdouble          $lat,
  gdouble          $lon
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_find_nearest_city_full (
  GWeatherLocation $loc,
  gdouble          $lat,
  gdouble          $lon,
                   &func (GWeatherLocation, gpointer --> gboolean),
  gpointer         $user_data,
                   &destroy (gpointer)
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_free_timezones (
  GWeatherLocation         $loc,
  CArray[GWeatherTimezone] $zones
)
  is native(gweather)
  is export
{ * }

sub gweather_location_get_children (GWeatherLocation $loc)
  returns CArray[CArray[GWeatherLocation]]
  is native(gweather)
  is export
{ * }

sub gweather_location_get_city_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_code (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_coords (
  GWeatherLocation $loc,
  gdouble          $latitude  is rw,
  gdouble          $longitude is rw
)
  is native(gweather)
  is export
{ * }

sub gweather_location_get_country (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_country_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_distance (
  GWeatherLocation $loc,
  GWeatherLocation $loc2
)
  returns gdouble
  is native(gweather)
  is export
{ * }

sub gweather_location_get_english_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_english_sort_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_level (GWeatherLocation $loc)
  returns GWeatherLocationLevel
  is native(gweather)
  is export
{ * }

sub gweather_location_get_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_parent (GWeatherLocation $loc)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_get_sort_name (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_timezone (GWeatherLocation $loc)
  returns GWeatherTimezone
  is native(gweather)
  is export
{ * }

sub gweather_location_get_timezone_str (GWeatherLocation $loc)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_get_timezones (GWeatherLocation $loc)
  returns CArray[CArray[GWeatherTimezone]]
  is native(gweather)
  is export
{ * }

sub gweather_location_get_type ()
  returns GType
  is native(gweather)
  is export
{ * }

sub gweather_location_get_world ()
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_has_coords (GWeatherLocation $loc)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_location_level_to_string (GWeatherLocationLevel $level)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_location_new_detached (
  Str     $name,
  Str     $icao,
  gdouble $latitude,
  gdouble $longitude
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_next_child (
  GWeatherLocation $loc,
  GWeatherLocation $child
)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_ref (GWeatherLocation $loc)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_location_serialize (GWeatherLocation $loc)
  returns GVariant
  is native(gweather)
  is export
{ * }

sub gweather_location_unref (GWeatherLocation $loc)
  is native(gweather)
  is export
{ * }
