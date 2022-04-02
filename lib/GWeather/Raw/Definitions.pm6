use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

use GLib::Roles::Pointers;

unit package GWeather::Raw::Definitions;

constant gweather is export = 'gweather-3',v16;

#class GWeatherLocation is repr<CPointer> does GLib::Roles::Pointers is export { }
class GWeatherTimezone is repr<CPointer> does GLib::Roles::Pointers is export { }

constant GWeatherUpdate       is export = time_t;
constant GWeatherTemperature  is export = gdouble;
constant GWeatherHumidity     is export = gdouble;
constant GWeatherWindSpeed    is export = gdouble;
constant GWeatherPressure     is export = gdouble;
constant GWeatherVisibility   is export = gdouble;
constant GWeatherMoonPhase    is export = gdouble;
constant GWeatherMoonLatitude is export = gdouble;

sub fmod (Num() \fpn)                   is export { fpn - fpn.truncate              }

sub TEMP_F_TO_C             ( \f     )  is export { f - 32.0 * 0.555556             }
sub TEMP_F_TO_K             ( \f     )  is export { TEMP_F_TO_C(f) + 273.15         }
sub TEMP_C_TO_F             ( \c     )  is export { c * 1.8 + 32.0                  }

sub  WINDSPEED_KNOTS_TO_KPH ( \knots )	is export { knots * 1.851965                }
sub  WINDSPEED_KNOTS_TO_MPH ( \knots )	is export { knots * 1.150779                }
sub  WINDSPEED_KNOTS_TO_MS  ( \knots )	is export { knots * 0.514444                }
sub  WINDSPEED_MS_TO_KNOTS  ( \ms    )	is export { ms    / 0.514444                }

# 1 bft ~= (1 m/s / 0.836) ^ (2/3)is export
sub  WINDSPEED_KNOTS_TO_BFT ( \knots )  is export { (knots * 0.615363) ** 0.66666   }

sub  PRESSURE_INCH_TO_KPA   ( \inch  )	is export { inch * 3.386                    }
sub  PRESSURE_INCH_TO_HPA   ( \inch  )	is export { inch * 33.86                    }
sub  PRESSURE_INCH_TO_MM    ( \inch  )	is export { inch * 25.40005                 }
sub  PRESSURE_INCH_TO_MB    ( \inch  )	is export { PRESSURE_INCH_TO_HPA(inch)      }
sub  PRESSURE_INCH_TO_ATM   ( \inch  )	is export { inch * 0.033421052              }
sub  PRESSURE_MBAR_TO_INCH  ( \mbar  )	is export { mbar * 0.029533373              }

sub  VISIBILITY_SM_TO_KM    ( \sm    )	is export { sm * 1.609344                   }
sub  VISIBILITY_SM_TO_M     ( \sm    )	is export { VISIBILITY_SM_TO_KM(sm)  * 1000 }

sub  DEGREES_TO_RADIANS     ( \deg   )  is export { fmod(deg/360) / 180      * π    }
sub  RADIANS_TO_DEGREES     ( \rad   )  is export { rad * 180                / π    }
sub  RADIANS_TO_HOURS       ( \rad   )  is export { rad * 12                 / π    }

#
# Planetary Mean Orbit and their progressions from J2000 are based on the
# values in http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf
# converting longitudes from heliocentric to geocentric coordinates (+180)
#
sub  EPOCH_TO_J2000          ( \t )     is export { t - 946727935.816                         }
sub  MEAN_ECLIPTIC_LONGITUDE ( \d )     is export { 280.46457166 + d / 36525 * 35999.37244981 }
sub  SOL_PROGRESSION                    is export { 360 / 365.242191                          }
sub  PERIGEE_LONGITUDE       ( \d )     is export { 282.93768193 + d / 36525 * 0.32327364     }


sub gweather-supplement is export {
  state $libname = do {
    my ($arch, $os, $ext) = resources-info;
    my $libkey = "lib/{ $arch }/{ $os }/libgweather-supplement.{ $ext }";
    say "Using '$libkey' as support library." if $DEBUG;
    $libname = %?RESOURCES{$libkey}.absolute;
  }

  $libname;
}
