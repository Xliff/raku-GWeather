use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Traits;
use GWeather::Raw::Types;
use GWeather::Raw::Location;

use GLib::Slice;
use GLib::TimeZone;
use GLib::Variant;

use GLib::Roles::Object;

our subset GWeatherLocationAncestry is export of Mu
  where GWeatherLocation | GObject;

class GWeather::Location {
  also does GLib::Roles::Object;

  has GWeatherLocation $!wl;

  submethod BUILD ( :$gweather-location ) {
    self.setGWeatherLocation( $gweather-location ) if $gweather-location
  }

  method setGWeatherLocation (GWeatherLocationAncestry $_) {
    my $to-parent;

    $!wl = do {
      when GWeatherLocation {
        $to-parent = cast(GObject, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GWeatherLocation, $_);
      }
    }
    self!setObject($to-parent)
  }

  method Weather::Raw::Definitions::GWeatherLocation
    is also<GWeatherLocation>
  { $!wl }

  method checkLatLong ($latitude, $longitude) is static {
    die "Invalid latitude: { $latitude // '»UNDEF«' }"
      unless
        $latitude &&
        ($latitude == GDOUBLE_MAX || $latitude  ~~   -90.0 .. 90.0);

    die "Invalid longitude: { $longitude // '»UNDEF«' }"
      unless
        $longitude &&
        ($longitude == GDOUBLE_MAX || $longitude ~~ -180.0 .. 180.0);
  }

  multi method new (GWeatherLocationAncestry $gweather-location, :$ref = True) {
    return Nil unless $gweather-location;

    my $o = self.bless( :$gweather-location );
    $o.ref if $ref;
    $o;
  }
  multi method new (
    Int()  $level,
    Num() :$latitude  = GDOUBLE_MAX,
    Num() :$longitude = GDOUBLE_MAX
  ) {
    samewith($level, $longitude, $latitude);
  }
  multi method new (
    Num() $latitude,
    Num() $longitude
  ) {
    samewith(GWEATHER_LOCATION_DETACHED, $latitude, $longitude);
  }
  multi method new (
    Int() $level,
    Num() $latitude  = GDOUBLE_MAX,
    Num() $longitude = GDOUBLE_MAX
  ) {
    my $loc =  GWeatherLocation.new;
    ($loc.db_idx, $loc.tz_hint_idx, $loc.level, $loc.ref_count, $loc.valid) =
      ($level, 1, INVALID_IDX, INVALID_IDX, 0);

    GWeather::Location.checkLatLong($latitude, $longitude);

    $loc.longitude = $longitude if $longitude;
    $loc.latitude  = $latitude  if $latitude;

    $loc.valid     = 1 if $loc.longitude && $loc.latitude;

    self.bless( gweather-location => $loc );
  }

  method new_detached (
    Str() $name,
    Str() $icao,
    Num() $latitude,
    Num() $longitude
  )
    is also<new-detached>
  {
    my gdouble ($l1, $l2) = ($latitude, $longitude);

    GWeather::Location.checkLatLong($latitude, $longitude);

    my $gweather-location = gweather_location_new_detached(
      $name,
      $icao,
      $l1,
      $l2
    );

    $gweather-location ?? self.bless( :$gweather-location ) !! Nil;
  }

  method deserialize (GVariant() $serialized, :$raw = False) {
    propReturnObject(
      gweather_location_deserialize($!wl, $serialized),
      $raw,
      |self.getTypePair
    );
  }

  proto method detect_nearest_city (|)
    is also<detect-nearest-city>
  { * }

  multi method detect_nearest_city (
    Num()           $lat,
    Num()           $lon,
                    &callback,
    gpointer        $user_data   = gpointer,
    GCancellable() :$cancellable = GCancellable,
  ) {
    samewith($lat, $lon, $cancellable, &callback, $user_data);
  }
  multi method detect_nearest_city (
    Num()          $lat,
    Num()          $lon,
    GCancellable() $cancellable,
                   &callback,
    gpointer       $user_data = gpointer
  ) {
    my gdouble ($l1, $l2) = ($lat, $lon);

    gweather_location_detect_nearest_city(
      $!wl,
      $l1,
      $l2,
      $cancellable,
      &callback,
      $user_data
    );
  }

  method detect_nearest_city_finish (
    GAsyncResult()          $result,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<detect-nearest-city-finish>
  {
    clear_error;
    my $l = gweather_location_detect_nearest_city_finish($result, $error);
    set_error($error);
    $l;
  }

  method equal (GWeatherLocation() $two) {
    so gweather_location_equal($!wl, $two);
  }

  method find_by_country_code (Str() $country_code, :$raw = False)
    is also<find-by-country-code>
  {
    propReturnObject(
      gweather_location_find_by_country_code($!wl, $country_code),
      $raw,
      |self.getTypePair
    );
  }

  method find_by_station_code (Str() $station_code, :$raw = False)
    is also<find-by-station-code>
  {
    propReturnObject(
      gweather_location_find_by_station_code($!wl, $station_code),
      $raw,
      |self.getTypePair
    );
  }

  method find_nearest_city (Num() $lat, Num() $lon, :$raw = False)
    is also<find-nearest-city>
  {
    my gdouble ($l1, $l2) = ($lat, $lon);

    propReturnObject(
      gweather_location_find_nearest_city($!wl, $l1, $l2),
      $raw,
      |self.getTypePair
    )
  }

  method find_nearest_city_full (
    Num()     $lat,
    Num()     $lon,
              &func,
    gpointer  $user_data = gpointer,
              &destroy   = Callable,
             :$raw       = False
  )
    is also<find-nearest-city-full>
  {
    my gdouble ($l1, $l2) = ($lat, $lon);

    propReturnObject(
      gweather_location_find_nearest_city_full(
        $!wl,
        $l1,
        $l2,
        &func,
        $user_data,
        &destroy
      ),
      $raw,
      |self.getTypePair
    )
  }

  proto method free_timezones (|)
    is also<free-timezones>
  { * }

  multi method free_timezones (@timezones) {
    samewith( ArrayToCArray(GWeatherTimezone, @timezones) );
  }
  multi method free_timezones (CArray[GWeatherTimezone] $zones) {
    gweather_location_free_timezones($!wl, $zones);
  }

  method get_children is also<get-children> {
    gweather_location_get_children($!wl);
  }

  method get_city_name is also<get-city-name> {
    gweather_location_get_city_name($!wl);
  }

  method get_code is also<get-code> {
    gweather_location_get_code($!wl);
  }

  proto method get_coords (|)
    is also<get-coords>
  { * }

  multi method get_coords {
    samewith($, $);
  }
  multi method get_coords ($latitude is rw, $longitude is rw) {
    my gdouble ($l1, $l2) = 0e0 xx 2;

    gweather_location_get_coords($!wl, $l1, $l2);

    ($latitude = $l1, $longitude = $l2);
  }

  method get_country is also<get-country> {
    gweather_location_get_country($!wl);
  }

  method get_country_name is also<get-country-name> {
    gweather_location_get_country_name($!wl);
  }

  method get_distance (GWeatherLocation() $loc2) is also<get-distance> {
    gweather_location_get_distance($!wl, $loc2);
  }

  method get_english_name is also<get-english-name> {
    gweather_location_get_english_name($!wl);
  }

  method get_english_sort_name is also<get-english-sort-name> {
    gweather_location_get_english_sort_name($!wl);
  }

  method get_level is also<get-level> {
    GWeatherLocationLevelEnum( gweather_location_get_level($!wl) );
  }

  method get_name is also<get-name> {
    gweather_location_get_name($!wl);
  }

  method get_parent ( :$raw = False ) is also<get-parent> {
    propReturnObject(
      gweather_location_get_parent($!wl),
      $raw,
      |self.getTypePair
    );
  }

  method get_sort_name is also<get-sort-name> {
    gweather_location_get_sort_name($!wl);
  }

  method get_timezone ( :$raw = False ) is also<get-timezone> {
    propReturnObject(
      gweather_location_get_timezone($!wl),
      $raw,
      |GLib::TimeZone.getTypePair
    );
  }

  method get_timezone_str is also<get-timezone-str> {
    gweather_location_get_timezone_str($!wl);
  }

  method get_timezones ( :$raw = False, :$array = False )
    is also<get-timezones>
  {
    my $tb = gweather_location_get_timezones($!wl);

    return $tb if $raw and $array.not;
    $tb does GLib::Roles::TypedBuffer[GTimeZone];
    return $tb if $array.not;
    $tb.Array.map({ $raw ?? $_ !! GLib::TimeZone.new($_) })
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, gweather_location_get_type, $n, $t );
  }

  method get_world ( :$raw = False ) is static is also<get-world> {
    propReturnObject(
      gweather_location_get_world(),
      $raw,
      |self.getTypePair
    );
  }

  method has_coords is also<has-coords> {
    so gweather_location_has_coords($!wl);
  }

  method level_to_string (Int() $level) is static is also<level-to-string> {
    gweather_location_level_to_string($level);
  }

  method next_child (GWeatherLocation() $child, :$raw = False)
    is also<next-child>
  {
    propReturnObject(
      gweather_location_next_child($!wl, $child),
      $raw,
      |self.getTypePair
    );
  }

  method ref {
    gweather_location_ref($!wl);
    self;
  }

  method serialize ( :$raw = False ) {
    propReturnObject(
      gweather_location_serialize($!wl),
      $raw,
      |GLib::Variant.getTypePair
    );
  }

  method unref {
    gweather_location_unref($!wl);
  }
}
