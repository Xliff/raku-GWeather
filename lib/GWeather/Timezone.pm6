use v6.c;

use GLib::Raw::Traits;

use GWeather::Raw::Types;
use GWeather::Raw::Timezone;

# BOXED
class GWeather::Timezone {
  has GWeatherTimezone $!wtz;

  submethod BUILD ( :$gweather-timezone ) {
    $!wtz = $gweather-timezone;
  }

  method new (GWeatherTimezone $gweather-timezone, :$ref = True) {
    return Nil unless $gweather-timezone;

    my $o = self.bless( :$gweather-timezone );
    $o.ref if $ref;
    $o;
  }

  method Weather::Raw::Structs::GWeatherTimezone
  { $!wtz }

  method get_by_tzid ( Str() $tzid, :$raw = False ) is static {
    gweather_timezone_get_by_tzid($tzid),
    propReturnObject(
      $raw,
      |self.getTypePair
    )
  }

  method get_dst_offset {
    gweather_timezone_get_dst_offset($!wtz);
  }

  method get_name {
    gweather_timezone_get_name($!wtz);
  }

  method get_offset {
    gweather_timezone_get_offset($!wtz);
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &gweather_timezone_get_type, $n, $t );
  }

  method get_tzid {
    gweather_timezone_get_tzid($!wtz);
  }

  method get_utc ( :$raw = False ) is static {
    propReturnObject(
      gweather_timezone_get_utc(),
      $raw,
      |self.getTypePair
    );
  }

  method has_dst {
    so gweather_timezone_has_dst($!wtz);
  }

  method ref {
    gweather_timezone_ref($!wtz);
    self;
  }

  method unref {
    gweather_timezone_unref($!wtz);
  }
}
