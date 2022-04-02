use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Object;
use GLib::Raw::Structs;
use GLib::Raw::Subs;
use GIO::Raw::Definitions;
use SOUP::Raw::Definitions;
use GWeather::Raw::Definitions;
use GWeather::Raw::Enums;

unit package GWeather::Raw::Structs;

class DbLocationRef is repr<CStruct> is export {
	has Pointer $.base;
	has gsize   $.size;
}

class GWeatherConditions is repr<CStruct> is export {
	has gboolean                    $!significant;
	has GWeatherConditionPhenomenon $!phenomenon ;
	has GWeatherConditionQualifier  $!qualifier  ;
}

class WeatherLocation is repr<CStruct> is export {
	has Str      $!name;
  has Str      $!code;
  has Str      $!zone;
  has Str      $!radar;
  has gboolean $.latlon_valid  is rw;
  has gdouble  $.latitude      is rw;
  has gdouble  $.longitude     is rw;
  has Str      $!country_code;
  has Str      $!tz_hint;

	method name is rw {
		Proxy.new:
			FETCH => -> $           { $!name },
			STORE => -> $, Str() \v { $!name := v }
	}

	method code is rw {
		Proxy.new:
			FETCH => -> $           { $!code },
			STORE => -> $, Str() \v { $!code := v }
	}

	method zone is rw {
		Proxy.new:
			FETCH => -> $           { $!zone },
			STORE => -> $, Str() \v { $!zone := v }
	}

	method radar is rw {
		Proxy.new:
			FETCH => -> $           { $!radar },
			STORE => -> $, Str() \v { $!radar := v }
	}

	method country_code is rw {
		Proxy.new:
			FETCH => -> $           { $!country_code },
			STORE => -> $, Str() \v { $!country_code := v }
	}
	method tz_hint is rw {
		Proxy.new:
			FETCH => -> $           { $!tz_hint },
			STORE => -> $, Str() \v { $!tz_hint := v }
	}
}

class GWeatherLocation is repr<CStruct> is export {
	has Pointer               $.db;                         #= GWeatherDb
	has guint                 $.db_idx              is rw;
	HAS DbLocationRef         $.ref;
	has Str                   $.english_name;
	has Str                   $.local_name;
	has Str                   $.local_sort_name;
	has Str                   $.english_sort_name;
	has guint16               $.parent_idx          is rw;
	has GWeatherLocation      $.parent;
	has CArray[Pointer]       $.children;                   #= **children (GWeatherLocation)
	has GWeatherTimezone      $.timezone;
	has GWeatherLocationLevel $.level               is rw;
	has Str                   $.country_code;
	has guint16               $.tz_hint_idx         is rw;
	has Str                   $.station_code;
	has num64                 $.latitude            is rw;
	has num64                 $.longitude           is rw;
	has gboolean              $.valid               is rw;
	has guint                 $.ref_count           is rw;
}

class GWeatherInfo is repr<CStruct> is export {
	HAS GObject               $!parent_instance     ;
	has GWeatherProvider      $.providers            is rw ;
	has GSettings             $!settings            ;
	has Str                   $!application_id      ;
	has Str                   $!contact_info        ;
	has gboolean              $.valid                is rw ;
	has gboolean              $.network_error        is rw ;
	has gboolean              $.sunriseValid         is rw ;
	has gboolean              $.sunsetValid          is rw ;
	has gboolean              $.midnightSun          is rw ;
	has gboolean              $.polarNight           is rw ;
	has gboolean              $.moonValid            is rw ;
	has gboolean              $.tempMinMaxValid      is rw ;
	has gboolean              $.hasHumidity          is rw ;
	HAS WeatherLocation       $.location;
	has GWeatherLocation      $.glocation;
	has GWeatherUpdate        $.update               is rw ;
	has GWeatherUpdate        $.current_time         is rw ;
	has GWeatherSky           $.sky                  is rw ;
	has GWeatherConditions    $.cond                 is rw ;
	has GWeatherTemperature   $.temp                 is rw ;
	has GWeatherTemperature   $.temp_min             is rw ;
	has GWeatherTemperature   $.temp_max             is rw ;
	has GWeatherTemperature   $.dew                  is rw ;
	has GWeatherHumidity      $.humidity             is rw ;
	has GWeatherWindDirection $.wind                 is rw ;
	has GWeatherWindSpeed     $.windspeed            is rw ;
	has GWeatherPressure      $.pressure             is rw ;
	has GWeatherVisibility    $.visibility           is rw ;
	has GWeatherUpdate        $.sunrise              is rw ;
	has GWeatherUpdate        $.sunset               is rw ;
	has GWeatherMoonPhase     $.moonphase            is rw ;
	has GWeatherMoonLatitude  $.moonlatitude         is rw ;
	has GSList                $!forecast_list              ;
	has Str                   $!forecast_attribution       ;
	has CArray[uint8]         $!radar_buffer               ;
	has Str                   $!radar_url                  ;

	# Augmented and bootstrapped into proper type in GWeather::UI
	has Pointer               $!radar_loader               ; #= GdkPixbufLoader
	has Pointer               $!radar                      ; #= GdkPixbufAnimation

	has SoupSession           $.session                    ;
	has GSList                $.requests_pending           ;

	method gist {
		unless self.defined {
			say '(GWeatherInfo)';
			return;
		}

		qq:to/GIST/;
			GWeatherInfo.new(\n{
		    self.^attributes.map({
					"    { .name } => {
						my $v = .get_value(self);
						$v.defined ?? $v !! 'Nil'
					}"
				}).join("\n") ~ "\n"
			})
			GIST
	}

	method radar_loader is rw {
		Proxy.new:
			FETCH => -> $             { $!radar_loader },
			STORE => -> $, Pointer \v { $!radar_loader := v }
	}

	method radar is rw {
		Proxy.new:
			FETCH => -> $             { $!radar },
			STORE => -> $, Pointer \v { $!radar := v }
	}

	method forecast_attribution is rw {
		Proxy.new:
			FETCH => -> $           { $!forecast_attribution },
			STORE => -> $, Str() \v { $!forecast_attribution := v }
	}

	method radar_buffer is rw {
		Proxy.new:
			FETCH => -> $                    { $!radar_buffer },
			STORE => -> $, CArray[uint8] \v  { $!radar_buffer := v }
	}

	method radar_url is rw {
		Proxy.new:
			FETCH => -> $           { $!radar_url },
			STORE => -> $, Str() \v { $!radar_url := v }
	}

	method session is rw {
		Proxy.new:
			FETCH => -> $                   { $!session },
			STORE => -> $, SoupSession() \v { $!session := v }
	}

	method requests_pending is rw {
		Proxy.new:
			FETCH => -> $              { $!requests_pending },
			STORE => -> $, GSList() \v { $!requests_pending := v }
	}

	method application_id is rw {
		Proxy.new:
			FETCH => -> $           { $!application_id },
			STORE => -> $, Str() \v { $!application_id := v }
	}

	method contact_info is rw {
		Proxy.new:
			FETCH => -> $           { $!contact_info },
			STORE => -> $, Str() \v { $!contact_info := v }
	}

}

# cw: To be migrated to GWeather-UI.
# class GWeatherLocationEntry is repr<CStruct> is export {
# 	has GtkSearchEntry               $!parent;
# 	has GWeatherLocationEntryPrivate $!priv  ;
# }
#
# class GWeatherLocationEntryClass is repr<CStruct> is export {
# 	has GtkSearchEntryClass $!parent_class;
# }
#
# class GWeatherTimezoneMenu is repr<CStruct> is export {
# 	has GtkComboBox      $!parent;
# 	has GWeatherTimezone $!zone  ;
# }
#
# class GWeatherTimezoneMenuClass is repr<CStruct> is export {
# 	has GtkComboBoxClass $!parent_class;
# }
