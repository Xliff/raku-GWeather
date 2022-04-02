#!/usr/bin/env perl6
use v6.c;

use LWP::Simple;
#use Mojo::DOM:from<Perl5>;
use DOM::Tiny;

use lib <scripts .>;

use GTKScripts;

my @defined-sigs = (
  [ 'gpointer',        'void', 'connect'       ],
  [ 'guint, gpointer', 'void', 'connect-uint'  ],
);

sub MAIN (
  $control     is copy,
  :$var        is copy = 'w',
  :$lib        is copy = 'gobject',
  :$prefix     is copy = "https://developer.gnome.org/gtk3/stable/",
  :$user-data          = False,
) {
  # If it's a URL, then try to pick it apart
  my ($ext, $v) = ('', "\$\!{ $var }");
  my %signals;

  $control = "{ %config<include-directory> //
               '/usr/include/gtk-3.0/gtk' }/{ $control }"
    unless $control.starts-with('http:' | 'https:' | '/');

  sub trimIt ($_) {
    .Str.subst("\n", ' ', :g).subst(/\s+/, ' ', :g)
  }

  if $control ~~ / ^ 'http's?'://' / {
    $control ~~ / 'http' s? '://' <-[\#]>+ /;
    my $new_prefix = $/.Str;
    my $new_control = $new_prefix.split('/')[* - 1];
    $new_control ~~ s/ '.' (.+?) $//;
    $ext = ".{ $/[0] }";
    $new_prefix ~~ s| '/' <-[/]>+? $|/|;
    ($prefix, $control) = ($new_prefix.trim, $new_control.trim);

    say "Attempting with prefix = { $prefix } control = { $control }";

    my $uri = "{ $prefix }{ $control }{ $ext }";
    say "Retrieving: $uri";
    my $dom = DOM::Tiny.parse(
      LWP::Simple.new.get($uri)
    );


    #my $sig-div = $dom.find('div.refsect1 a').to_array.List.grep(
    #  *.attr('name') eq "{ $control }.signal-details"
    #)[0].parent;
    my $found = False;
    quietly {
      for $dom.find('div.refsect1 a') -> $e {
        if $e && $e.attr('name') eq "{ $control }.signal-details" {
          $found = $e.parent;
          last;
        }
      }
    }

    die "Could not find signals section for { $control }" unless $found;

    for $found.find('div h3 code') -> $e {
      (my $mn = $e.text) ~~ s:g/<[“”"]>//;
      my $pre = $e.parent.parent.find('pre').tail;
      my $rts = $pre.find('span.returnvalue').tail;
      my $rt = $rts.text.&trimIt;
      my @t = $pre.find('span.type');

      # Existing check to go here.
      my $s-sig = @t.map(*.text.trim).join(', ');
      my $udm = $s-sig.elems == 2 && $s-sig.tail.contains('void');
      # my $emn = check_defined($s-sig, $rt);

      %signals{$mn} = ( :$udm, :$mn, :$v, :$s-sig, :$rt ).Hash;
    }
  } elsif (my $control-io = $control.IO).r {

    # If it's a readable file, we have to do things the (James) Hardway
    # 1) Read in the .c file for the signal names
    my @signals;
    my $contents = $control-io.slurp;
    my $matches = $contents ~~ m:g/
      'g_signal_new' \s* '('\s* '"' (<[\-\_\w]>+) '"' \s* ',' \s*
      [
        .+?','\s*
        .+?','\s*
        'G_STRUCT_OFFSET' \s* '(' \w+ ',' \s* (<[\w\-\+]>+)
      ]
    /;

    say "Matches: { $matches.gist }";

    my %proper-sig-name;
    for $matches[] {
      %proper-sig-name{ .[0] } = .[0].Str;
      @signals.push: .[0].Str;
      if .[1] {
        @signals.push: .[1].Str;
        %proper-sig-name{ .[1] } = .[0].Str;
      }
    }

    # 2) Read in the .h file for the signal signatures
    my $header = $control-io.absolute.subst('.c', '') ~ '.h';
    die "Could not find header '{ $header }' file for signatures!"
      unless $header.IO.r;

      @signals.push;

    my $signature-matches = $header.IO.slurp ~~ m:g/
      $<rt>=[(\w+) \s* '*'?] '(*' \s*
      $<signal>=<{ @signals.map({ .subst('-', '_', :g) }) }> ')'
      \s*
      '(' $<sig>=( <-[\)]>+ ) ')'
    /;

    say "SM: { $signature-matches.gist }";

    for $signature-matches[] {
      .gist.say;

      my $s-sig = .<sig>.&trimIt.split(',').map({
        .subst('const ', '').subst('gchar', 'Str', :g)
      });
      my $udm = $s-sig.elems == 2 && $s-sig.tail.contains('void');
      my $signal-name = %proper-sig-name{ .<signal> };
      %signals{ $signal-name } = my %sig-data = (
        :$udm,
        # cw: This back and forth is hard to avoid.
        mn => $signal-name.subst('_', '-', :g),
        :$v,
        :$s-sig,
        rt    => .<rt>.&trimIt,
      ).Hash;
    }
  } else {
    say "Don't know how to handle '{ $control }'";
    exit 1;
  }

  # Output in-class handlers
  for %signals.pairs {

    given .value {
      say qq:to/METH/;
        # Is originally:
        # { .<s-sig>.join(', ') } --> { .<rt> }
        method { .<mn> } \{
          self.{ .<udm> ?? "connect({ .<v> }, '{ .<mn> }')"
                        !! "connect-{ .<mn> }({ .<v> })" };
        \}
      METH
    }

  }

  # Output role code
  # Handle return type!!
  for %signals.pairs {
    my %vars;
    my @p = .value<s-sig>.skip(1);
    my $cpp = False;
    # If this is processed lazily, the post-process step will not work.
    my $pp = @p.map({
      / (<[A..Za..z]>)+ %% [ <[a..z]>+ ] /;
      my $v = '$' ~ $/[0].map( *.Str.lc )[^(* - 1)].join('');
      # Collision handling.
      if %vars{$v}:exists {
        $cpp = True;
        if $v ~~ /^ (\w+)(\d+) $/ {
          $v = $0 ~ { $1.Int + 1};
        } else {
          $v ~= '2'
        }
      }
      %vars{$v} = 1;
      $v
    }).eager;
    # Collision handing post-process.
    if $cpp {
      for $pp.kv -> $k, $v {
        say "K: $k / V: $v";
        if $v.ends-with('2') {
          $pp[$k - 1] ~= '1';
        }
      }
    }
    $pp .= join(', ');

    my $rt = .value<rt> ne 'void' ?? " --> { .value<rt> }" !! '';
    my $name = $v.substr(2);

    my $emission;
    my $params = "self{ $pp ?? ', ' !! ''}{ $pp }";
    $params ~= ", \$ud" if $user-data;
    if $rt.defined && $rt.trim && $rt.trim ne 'void' {
      $emission = qq:to/NONVOID/.chomp;
                my \$r = ReturnedValue.new;
                𝒮.emit( [{ $params }, \$r] );
                \$r.r;
      NONVOID
    } else {
      $emission = qq:to/VOID/.chomp;
                𝒮.emit( [self, { $params }] );
      VOID
    }

    # We use 𝒮 as opposed to 's' to prevent a naming collision.
    # between the Supplier and the parameters in the pointy block.
    my $ud = $user-data ?? ', \$ud' !! '';
    say qq:to/METH/;
  # { @p.join(', ') }{ $rt }
  method connect-{ .value<mn> } (
    \$obj,
    \$signal = '{ .value<mn> }',
    \&handler?
  ) \{
    my \$hid;
    \%!signals-{ $name }\{\$signal\} //= do \{
      my \\𝒮 = Supplier.new;
      \$hid = g-connect-{ .value<mn> }(\$obj, \$signal,
        -> \${ $pp ?? ', ' !! ''}{ $pp }{ $ud } \{
          CATCH \{
            default \{ 𝒮.note(\$_) \}
          \}

{ $emission }
        \},
        Pointer, 0
      );
      [ 𝒮.Supply, \$obj, \$hid ];
    \};
    \%!signals-{ $name }\{\$signal\}[0].tap(\&handler) with \&handler;
    \%!signals-{ $name }\{\$signal\}[0];
  \}
METH

  }

  # Emit non-default nativecall defs
  for %signals.pairs {
    my $rt = .value<rt>.trim ne 'void' ?? " --> { .value<rt>.trim }" !! '';
    my @s-sig = .value<s-sig>.skip(1);
    my $c = +@s-sig ?? ', ' !! ' ';

    say qq:to/NC/;
# { .value<s-sig>.join(', ') }{ $rt }
sub g-connect-{ .value<mn> } (
  Pointer \$app,
  Str \$name,
  \&handler (Pointer{ $c }{ @s-sig.map({ ' ' ~ .split(' ')[1] }).join(',') }{
    $user-data ?? ($c ~ 'Pointer') !! '' }{ $rt }),
  Pointer \$data,
  uint32 \$flags
)
  returns uint64
  is native({ $lib })
  is symbol('g_signal_connect_object')
\{ \* \}
NC

  }

}
