use v6;

use GWeather::Info;
use DateTime::Format;

constant FORMAT = '%A %b %d, %Y %T';

sub dt-format ($a) { strftime(FORMAT, $a) }

sub MAIN (
  :$latitude,                           #= observer's latitude in degrees north
  :$longitude,                          #= observer's longitude in degrees east
  :$time       is copy  = DateTime.now  #= time in seconds from Unix epoch
) {
  GWeather::Location.checkLatLong($latitude, $longitude);

  my $info = GWeather::Info.new($latitude, $longitude);
  $info.latLong(:degrees) = ($latitude, $longitude);

  $info.setCurrentTime($time);

  my $ns      = $latitude  >= 0 ?? 'N' !! 'S';
  my $ew      = $longitude >= 0 ?? 'E' !! 'W';

  $info.prep;

  my $sunrise = $info.sunriseValid ?? DateTime.new($info.sunrise)
                                   !! '(invalid)';
  my $sunset  = $info.sunsetValid  ?? DateTime.new($info.sunset)
                                   !! '(invalid)';
  say qq:to/WEATHER/;
    Latitude {
      $latitude.fmt('%7.3f') } { $ns } Longitude {
     $longitude.fmt('%7.3f') } { $ew } for {
        $time.utc.&dt-format }. All times UTC
    daytime:  { $info.is-daytime ?? 'yes' !! 'no' }
    sunrise:  { $sunrise.&dt-format }  sunset: { $sunset.&dt-format }
    WEATHER

  if $info.moonValid {
    say qq:to/PHASE/;
      moonphase: { $info.moonphase }
      moonlat:   { $info.moonlatitude }
      PHASE

    if $info.get-upcoming-moonphases() -> $p {
      my $pn = «' New' 1stQ Full 3rdQ»;

      my $dates = $p.map( *.&dt-format ).cache;
      my $date-size = $dates.map( *.chars ).max;
      $dates .= map( *.fmt("%{ $date-size }s") ).cache;

      .say for
        $p.kv.map(-> $k, $v {
          [ $v, "     { $pn[$k] }: { $dates[$k] }" ]
        }).sort( *[0] ).map( *[1] );
    }
  }

}
