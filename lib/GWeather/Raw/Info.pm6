use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GDK::Raw::Definitions;
use GWeather::Raw::Definitions;
use GWeather::Raw::Enums;
use GWeather::Raw::Structs;

unit package Weather::Raw::Info;

### /usr/src/libgweather-40.0/libgweather/gweather-weather.h

sub gweather_conditions_to_string (GWeatherConditions $conditions)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_conditions_to_string_full (
  GWeatherConditions    $conditions,
  GWeatherFormatOptions $options
)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_abort (GWeatherInfo $info)
  is native(gweather)
  is export
{ * }

sub gweather_info_get_apparent (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_application_id (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_attribution (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_conditions (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_contact_info (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_dew (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_enabled_providers (GWeatherInfo $info)
  returns GWeatherProvider
  is native(gweather)
  is export
{ * }

sub gweather_info_get_forecast_list (GWeatherInfo $info)
  returns GSList
  is native(gweather)
  is export
{ * }

sub gweather_info_get_humidity (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_icon_name (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_location (GWeatherInfo $info)
  returns GWeatherLocation
  is native(gweather)
  is export
{ * }

sub gweather_info_get_location_name (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_pressure (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_radar (GWeatherInfo $info)
  returns GdkPixbufAnimation
  is native(gweather)
  is export
{ * }

sub gweather_info_get_sky (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_sunrise (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_sunset (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_symbolic_icon_name (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_temp (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_temp_max (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_temp_min (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_temp_summary (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_upcoming_moonphases (
  GWeatherInfo   $info,
  CArray[time_t] $phases
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_update (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_apparent (
  GWeatherInfo            $info,
  GWeatherTemperatureUnit $unit,
  gdouble                 $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_conditions (
  GWeatherInfo                $info,
  GWeatherConditionPhenomenon $phenomenon,
  GWeatherConditionQualifier  $qualifier
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_dew (
  GWeatherInfo            $info,
  GWeatherTemperatureUnit $unit,
  gdouble                 $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_moonphase (
  GWeatherInfo         $info,
  GWeatherMoonPhase    $value,
  GWeatherMoonLatitude $lat
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_pressure (
  GWeatherInfo         $info,
  GWeatherPressureUnit $unit,
  gdouble              $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_sky (GWeatherInfo $info, GWeatherSky $sky)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_sunrise (GWeatherInfo $info, time_t $value)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_sunset (GWeatherInfo $info, time_t $value)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_temp (
  GWeatherInfo            $info,
  GWeatherTemperatureUnit $unit,
  gdouble                 $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_temp_max (
  GWeatherInfo            $info,
  GWeatherTemperatureUnit $unit,
  gdouble                 $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_temp_min (
  GWeatherInfo            $info,
  GWeatherTemperatureUnit $unit,
  gdouble                 $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_update (GWeatherInfo $info, time_t $value)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_visibility (
  GWeatherInfo         $info,
  GWeatherDistanceUnit $unit,
  gdouble              $value is rw
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_value_wind (
  GWeatherInfo          $info,
  GWeatherSpeedUnit     $unit,
  gdouble               $speed      is rw,
  GWeatherWindDirection $direction
)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_get_visibility (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_weather_summary (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_get_wind (GWeatherInfo $info)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_info_is_daytime (GWeatherInfo $info)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_is_valid (GWeatherInfo $info)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_network_error (GWeatherInfo $info)
  returns uint32
  is native(gweather)
  is export
{ * }

sub gweather_info_new (GWeatherLocation $location)
  returns GWeatherInfo
  is native(gweather)
  is export
{ * }

sub gweather_info_next_sun_event (GWeatherInfo $info)
  returns gint
  is native(gweather)
  is export
{ * }

sub gweather_info_set_application_id (GWeatherInfo $info, Str $application_id)
  is native(gweather)
  is export
{ * }

sub gweather_info_set_contact_info (GWeatherInfo $info, Str $contact_info)
  is native(gweather)
  is export
{ * }

sub gweather_info_set_enabled_providers (
  GWeatherInfo     $info,
  GWeatherProvider $providers
)
  is native(gweather)
  is export
{ * }

sub gweather_info_set_location (GWeatherInfo $info, GWeatherLocation $location)
  is native(gweather)
  is export
{ * }

sub gweather_info_store_cache ()
  is native(gweather)
  is export
{ * }

sub gweather_info_update (GWeatherInfo $info)
  is native(gweather)
  is export
{ * }

sub gweather_info_ensure_sun (GWeatherInfo $info)
  is native(&gweather-supplement)
  is export
  is symbol('_gweather_info_ensure_sun')
{ * }

sub gweather_info_ensure_moon (GWeatherInfo $info)
  is native(&gweather-supplement)
  is export
  is symbol('_gweather_info_ensure_moon')
{ * }

sub gweather_sky_to_string (GWeatherSky $sky)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_sky_to_string_full (
  GWeatherSky           $sky,
  GWeatherFormatOptions $options
)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_speed_unit_to_string (GWeatherSpeedUnit $unit)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_temperature_unit_to_real (GWeatherTemperatureUnit $unit)
  returns GWeatherTemperatureUnit
  is native(gweather)
  is export
{ * }

sub gweather_wind_direction_to_string (GWeatherWindDirection $wind)
  returns Str
  is native(gweather)
  is export
{ * }

sub gweather_wind_direction_to_string_full (
  GWeatherWindDirection $wind,
  GWeatherFormatOptions $options
)
  returns Str
  is native(gweather)
  is export
{ * }
