use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Traits;
use GWeather::Raw::Types;
use GWeather::Raw::Info;
use DateTime::Parse;

use GLib::GSList;
use GWeather::Location;

use GLib::Roles::Object;
use GLib::Roles::Signals::Generic;

our subset GWeatherInfoAncestry is export of Mu
  where GWeatherInfo | GObject;

class GWeather::Info {
  also does GLib::Roles::Object;
  also does GLib::Roles::Signals::Generic;

  has GWeatherInfo $!wi           handles(*);
  has Bool         $!prep-called              = False;

  submethod BUILD ( :$gweather-info ) {
    self.setGWeatherInfo( $gweather-info ) if $gweather-info;
  }

  method setGWeatherInfo (GWeatherInfoAncestry $_) {
    my $to-parent;

    $!wi = do {
      when GWeatherInfo {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GWeatherInfo, $_);
      }
    }
    self!setObject($to-parent)
  }

  method Weather::Raw::Definitions::GWeatherInfo
    is also<GWeatherInfo>
  { $!wi }

  method gist {
    $!wi.gist;
  }

  proto method new (|)
  { * }

  multi method new ($arg, :$ref = True) {
    state $times = 0;
    say "In typeless .new...({ $times++ })" if ($DEBUG // 0) > 2;
    #last if $times > 15;
    say "A: $arg ({ $arg.^name })" if ($DEBUG // 0) > 2;
    samewith(
      do given $arg {
        when .^can('GWeatherLocation') {
          say 'Cast to GWeatherLocation...';
          .GWeatherLocation;
        }

        when GWeatherLocation {
          $_
        }

        when .^can('GWeatherInfo') {
          say 'Cast to GWeatherInfo...';
          .GWeatherInfo
        }

        when .^can('GObject') {
          say 'Cast to GObject...';
          .GObject;
        }

        default {
          die "Do not know how to handle creation given a { .^name }";
        }
      },
      :$ref
    );
  }
  multi method new (GWeatherInfoAncestry $gweather-info, :$ref = True) {
    say 'In identity constructor...' if ($DEBUG // 0) > 2;

    return Nil unless $gweather-info;

    my $o = self.bless( :$gweather-info );
    $o.ref if $ref;
    $o;
  }
  multi method new (GWeather::Location $location) {
    samewith($location.GWeatherLocation);
  }
  multi method new (GWeatherLocation $location) {
    say 'In GWeatherLocation.new...' if ($DEBUG // 0) > 2;

    # cw: This currently SEGVs.
    my $gweather-info = gweather_info_new($location);

    $gweather-info ?? self.bless( :$gweather-info ) !! Nil;
  }
  multi method new (Num() $latitude, Num() $longitude) {
    say 'In geographical point .new...' if ($DEBUG // 0) > 2;

    samewith(
      GWeather::Location.new($latitude, $longitude).GWeatherLocation
    )
  }

  method prep {
    gweather_info_ensure_sun($!wi);
    gweather_info_ensure_moon($!wi);
    $!prep-called = True;
  }

  # Type: string
  method application-id is rw  is also<application_id> {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        warn 'application-id does not allow reading' if ($DEBUG // 0);
        '';
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('application-id', $gv);
      }
    );
  }

  # Type: string
  method contact-info is rw  is also<contact_info> {
    my $gv = GLib::Value.new( G_TYPE_STRING );
    Proxy.new(
      FETCH => sub ($) {
        warn 'contact-info does not allow reading' if ($DEBUG // 0);
        '';
      },
      STORE => -> $, Str() $val is copy {
        $gv.string = $val;
        self.prop_set('contact-info', $gv);
      }
    );
  }

  # Type: GWeatherProvider
  method enabled-providers is rw  is also<enabled_providers> {
    my $gv = GLib::Value.new( GLib::Value.typeFromEnum(GWeatherProvider) );
    Proxy.new(
      FETCH => sub ($) {
        warn 'enabled-providers does not allow reading' if ($DEBUG // 0);
        0;
      },
      STORE => -> $, Int() $val is copy {
        $gv.valueFromEnum(GWeatherProvider) = $val;
        self.prop_set('enabled-providers', $gv);
      }
    );
  }

  method latLong (:$degrees = False) is rw {
    Proxy.new:
      FETCH => -> $ {
        my $mult = $degrees ?? 180/π !! 1;
        ($!wi.location.latitude, $!wi.location.longitude).map({ $_ * $mult });
      },

      STORE => -> $, $v where *.elems == 2 {
        my $mult = $degrees ?? π/180 !! 1;

        ($!wi.location.latitude, $!wi.location.longitude) =
          $v.map({ $_ * $mult });
        $!wi.location.latlon_valid = 1;
      }
  }

  method setCurrentTime ($time) {
    $!wi.current_time = do given $time {
      when Str {
        my $t = DateTime::parse.new($time);

        if $t {
          $_ = $t;
          proceed;
        }
      }

      when DateTime {
        .posix;
      }

      when Int { $_ }

      default {
        die "Don't know how to convert a { .^name } value to POSIX time!";
      }
    }
  }

  # Signal
  method updated {
    self.connect($!wi, 'updated');
  }

  method abort {
    gweather_info_abort($!wi);
  }

  method get_apparent is also<get-apparent> {
    gweather_info_get_apparent($!wi);
  }

  method get_application_id is also<get-application-id> {
    gweather_info_get_application_id($!wi);
  }

  method get_attribution is also<get-attribution> {
    gweather_info_get_attribution($!wi);
  }

  method get_conditions is also<get-conditions> {
    gweather_info_get_conditions($!wi);
  }

  method get_contact_info is also<get-contact-info> {
    gweather_info_get_contact_info($!wi);
  }

  method get_dew is also<get-dew> {
    gweather_info_get_dew($!wi);
  }

  method get_enabled_providers ( :$raw = False )
    is also<get-enabled-providers>
  {
    my $bit = gweather_info_get_enabled_providers($!wi);
    return $bit if $raw;
    getFlags(GWeatherProviderEnum, $bit);
  }

  method get_forecast_list ( :$raw = False, :$list = False )
    is also<get-forecast-list>
  {
    returnGSList(
      gweather_info_get_forecast_list($!wi),
      $raw,
      |self.getTypePair
    );
  }

  method get_humidity is also<get-humidity> {
    gweather_info_get_humidity($!wi);
  }

  method get_icon_name is also<get-icon-name> {
    gweather_info_get_icon_name($!wi);
  }

  method get_location (:$raw = False) is also<get-location> {
    propReturnObject(
      gweather_info_get_location($!wi),
      $raw,
      |GWeather::Location.getTypePair
    );
  }

  method get_location_name is also<get-location-name> {
    gweather_info_get_location_name($!wi);
  }

  method get_pressure is also<get-pressure> {
    gweather_info_get_pressure($!wi);
  }

  method get_radar is also<get-radar> {
    gweather_info_get_radar($!wi);
  }

  method get_sky is also<get-sky> {
    gweather_info_get_sky($!wi);
  }

  method get_sunrise is also<get-sunrise> {
    gweather_info_get_sunrise($!wi);
  }

  method get_sunset is also<get-sunset> {
    gweather_info_get_sunset($!wi);
  }

  method get_symbolic_icon_name is also<get-symbolic-icon-name> {
    gweather_info_get_symbolic_icon_name($!wi);
  }

  method get_temp is also<get-temp> {
    gweather_info_get_temp($!wi);
  }

  method get_temp_max is also<get-temp-max> {
    gweather_info_get_temp_max($!wi);
  }

  method get_temp_min is also<get-temp-min> {
    gweather_info_get_temp_min($!wi);
  }

  method getTempRange {
    (self.get_temp_min .. self.get_temp_max);
  }

  method get_temp_summary is also<get-temp-summary> {
    gweather_info_get_temp_summary($!wi);
  }

  proto method get_upcoming_moonphases (|)
    is also<get-upcoming-moonphases>
  { * }

  multi method get_upcoming_moonphases (:$raw = False, :$datetime = True) {
    samewith($, :$raw, :$datetime);
  }
  multi method get_upcoming_moonphases (
     $phases is rw,
    :$raw           = False,
    :$datetime      = True
  ) {
    self.prep unless $!prep-called;
    my $p = CArray[time_t].new;
    $p[$_] = 0 for ^4;

    gweather_info_get_upcoming_moonphases($!wi, $p);

    $phases  = $p;
    $phases  = CArrayToArray($phases) unless $raw;
    $phases .= map({ DateTime.new($_) }) if $datetime;
    $phases;
  }

  method get_update is also<get-update> {
    gweather_info_get_update($!wi);
  }

  proto method get_value_apparent (|)
    is also<get-value-apparent>
  { * }

  multi method get_value_apparent (Int() $unit) {
    samewith($unit, $);
  }
  multi method get_value_apparent (Int() $unit, $value is rw) {
    my gdouble $v                 = 0e0;
    my GWeatherTemperatureUnit $u = $unit;

    gweather_info_get_value_apparent($!wi, $unit, $v) ?? ($value = $v) !! Nil;
  }

  method get_value_conditions (Int() $phenomenon, Int() $qualifier)
    is also<get-value-conditions>
  {
    my GWeatherConditionPhenomenon $p = $phenomenon;
    my GWeatherConditionQualifier  $q = $qualifier;

    gweather_info_get_value_conditions($!wi, $p, $q);
  }

  proto method get_value_dew (|)
    is also<get-value-dew>
  { * }

  multi method get_value_dew (Int() $unit) {
    samewith($unit, $);
  }
  multi method get_value_dew (Int() $unit, $value is rw) {
    my GWeatherTemperatureUnit $u = $unit;

    gweather_info_get_value_dew($!wi, $unit, $value);
  }

  proto method get_value_moonphase (|)
    is also<get-value-moonphase>
  { * }

  multi method get_value_moonphase {
    samewith($, $);
  }
  multi method get_value_moonphase ($value is rw, $lat is rw) {
    my gdouble ($v, $l) = 0e0 xx 2;

    self.prep unless $!prep-called;
    gweather_info_get_value_moonphase($!wi, $v, $l)
      ?? ($value = $v, $lat = $l)
      !! Nil;
  }

  method get_value_pressure (GWeatherPressureUnit $unit, gdouble $value is rw)
    is also<get-value-pressure>
  {
    my gdouble $v = 0e0;

    gweather_info_get_value_pressure($!wi, $unit, $v) ?? ($value = $v)
                                                      !! Nil;
  }

  method get_value_sky (GWeatherSky $sky) is also<get-value-sky> {
    gweather_info_get_value_sky($!wi, $sky);
  }

  method get_value_sunrise (Int() $value) is also<get-value-sunrise> {
    my time_t $v = $value;

    self.prep unless $!prep-called;
    gweather_info_get_value_sunrise($!wi, $v);
  }

  method get_value_sunset (Int() $value) is also<get-value-sunset> {
    my time_t $v = $value;

    self.prep unless $!prep-called;
    gweather_info_get_value_sunset($!wi, $v);
  }

  method get_value_temp (Int() $unit, $value is rw) is also<get-value-temp> {
    my GWeatherTemperatureUnit $u = $unit;
    my gdouble                 $v = 0e0;

    gweather_info_get_value_temp($!wi, $unit, $v) ?? ($value = $v) !! Nil;

  }

  proto method get_value_temp_max (|)
    is also<get-value-temp-max>
  { * }

  multi method get_value_temp_max (Int() $unit) {
    samewith($unit, $);
  }
  multi method get_value_temp_max (Int() $unit, $value is rw) {
    my GWeatherTemperatureUnit $u = $unit;
    my gdouble                 $v = 0e0;

    gweather_info_get_value_temp_max($!wi, $unit, $v) ?? ($value = $v) !! Nil;
  }

  proto method get_value_temp_min (|)
    is also<get-value-temp-min>
  { * }

  multi method get_value_temp_min (Int() $unit) {
    samewith($unit, $);
  }
  multi method get_value_temp_min (Int() $unit, $value is rw) {
    my GWeatherTemperatureUnit $u = $unit;
    my gdouble                 $v = 0e0;

    gweather_info_get_value_temp_min($!wi, $unit, $v) ?? ($value = $v) !! Nil;
  }

  method get_value_update (Int() $value) is also<get-value-update> {
    my time_t $v = $value;

    gweather_info_get_value_update($!wi, $v);
  }

  proto method get_value_visibility (|)
    is also<get-value-visibility>
  { * }

  multi method get_value_visibility (Int() $unit) {
    samewith($unit, $);
  }
  multi method get_value_visibility (Int() $unit, $value is rw) {
    my GWeatherDistanceUnit $u = $unit;
    my gdouble                 $v = 0e0;

    gweather_info_get_value_visibility($!wi, $unit, $v) ?? ($value = $v)
                                                        !! Nil;
  }

  proto method get_value_wind (|)
    is also<get-value-wind>
  { * }

  multi method get_value_wind (Int() $unit) {
    samewith($unit, $, $);
  }
  multi method get_value_wind (Int() $unit, $speed is rw, $direction is rw) {
    my GWeatherSpeedUnit     $u = $unit;
    my gdouble               $s = 0e0;
    my GWeatherWindDirection $d = 0;

    gweather_info_get_value_wind($!wi, $unit, $s, $d)
      ?? ($speed = $s, $direction = $d)
      !! Nil
  }

  method get_visibility is also<get-visibility> {
    gweather_info_get_visibility($!wi);
  }

  method get_weather_summary is also<get-weather-summary> {
    gweather_info_get_weather_summary($!wi);
  }

  method get_wind is also<get-wind> {
    gweather_info_get_wind($!wi);
  }

  method is_daytime is also<is-daytime> {
    so gweather_info_is_daytime($!wi);
  }

  method is_valid is also<is-valid> {
    so gweather_info_is_valid($!wi);
  }

  method network_error is also<network-error> {
    so gweather_info_network_error($!wi);
  }

  method next_sun_event is also<next-sun-event> {
    gweather_info_next_sun_event($!wi);
  }

  method set_application_id (Str() $application_id)
    is also<set-application-id>
  {
    gweather_info_set_application_id($!wi, $application_id);
  }

  method set_contact_info (Str() $contact_info) is also<set-contact-info> {
    gweather_info_set_contact_info($!wi, $contact_info);
  }

  method set_enabled_providers (GWeatherProvider() $providers)
    is also<set-enabled-providers>
  {
    gweather_info_set_enabled_providers($!wi, $providers);
  }

  method set_location (GWeatherInfo() $location) is also<set-location> {
    gweather_info_set_location($!wi, $location);
  }

  method store_cache is static is also<store-cache> {
    gweather_info_store_cache();
  }

  method update {
    gweather_info_update($!wi);
  }

  method conditions_to_string (Int() $condition) is static
    is also<conditions-to-string>
  {
    my GWeatherConditions $c = $condition;

    gweather_conditions_to_string($c);
  }

  # method conditions_to_string_full (
  #   Int() $condition,
  #   Int() $options
  # )
  #   is static
  # {
  #   my GWeatherConditions    $c = $condition;
  #   my GWeatherFormatOptions $o = $options;
  #
  #   gweather_conditions_to_string_full($c, $o);
  # }
  #
  # method sky_to_string (Int() $sky) is static {
  #   my GWeatherSky $s = $sky;
  #
  #   gweather_sky_to_string($sky);
  # }
  #
  # method sky_to_string_full (Int() $sky,  Int() $options) is static {
  #   my GWeatherSky           $s = $sky;
  #   my GWeatherFormatOptions $o = $options;
  #
  #   gweather_sky_to_string_full($s, $options);
  # }
  #
  # method speed_unit_to_string is static (Int() $unit) is static {
  #   my GWeatherSpeedUnit $u = $unit;
  #
  #   gweather_speed_unit_to_string($u);
  # }

  method temperature_unit_to_real (Int() $unit) is static
    is also<temperature-unit-to-real>
  {
    my GWeatherTemperatureUnit $u = $unit;

    GWeatherTemperatureUnitEnum( gweather_temperature_unit_to_real($u) );
  }

  method wind_direction_to_string (Int() $dir)
    is static
    is also<wind-direction-to-string>
  {
    my GWeatherWindDirection $d = $dir;

    gweather_wind_direction_to_string($d);
  }

  method wind_direction_to_string_full (Int() $dir, Int() $options)
    is static
    is also<wind-direction-to-string-full>
  {
    my GWeatherFormatOptions $o = $options;
    gweather_wind_direction_to_string_full($!wi, $options);
  }

}
