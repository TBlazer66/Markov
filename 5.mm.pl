#!/usr/bin/perl -w
use 5.011;
use Path::Tiny;
use utf8;
use open OUT => ':utf8';
use Data::Dump;
use Text::Template;
use POSIX qw(strftime);
binmode STDOUT, 'utf8';

my ($sub_dir) = $ARGV[0];
say "sub_dir is $sub_dir";
my $path1 = Path::Tiny->cwd;
say "path1 is $path1";
my $path2 = path( $path1, $sub_dir );
say "path2 is $path2";

## populate hash for appositives
my $data = [
  [ 'protaganist', '{$content_provider}', 'JAPH',          'Dick Vitale' ],
  [ 'event',       'March Madness',       'the Big Dance', 'hoops, baby' ],
];

my @region = [ 'east', 'west', 'south', 'midwest' ];

#dd $data;
# unique point at which probability is assigned for teams.
my $ref_bracket = pop_brackets();
dd $ref_bracket;

## main loop
# set trials
my $trials = 2;
my $dummy  = 1;

while ( $trials > 0 ) {

  # create an output file
  my $first_second = strftime( "%d-%m-%Y-%H-%M-%S", localtime );
  my $out_file =
    $path2->child( 'my_data', "$first_second", "$first_second\.$dummy.txt" )
    ->touchpath;
  say "out_file is $out_file";


  for my $r (@region){

  my $ref_calc = calc_winners($ref_bracket);
  dd $ref_calc;

  # stochastic input of appositives for every "story"
  my %vars = map { $_->[0], $_->[ rand( $#{$_} ) + 1 ] } @{$data};
  my $rvars = \%vars;

  my @pfade = $path2->children(qr/\.txt$/);
  @pfade = sort @pfade;

  #say "paths are @pfade";

  for my $file (@pfade) {

    #say "default is $file";
    my $template = Text::Template->new(
      ENCODING => 'utf8',
      SOURCE   => $file,
    ) or die "Couldn't construct template: $!";

    my $result = $template->fill_in( HASH => $rvars );
    $out_file->append_utf8($result);
  }
  say "-------system out---------";
  system("cat $out_file");
  say "----------------";
  $trials -= 1;
  $dummy += 1;
} #end for loop

}    # end while condition


sub pop_brackets {

  use 5.016;
  use warnings;

  my %vars;
  my @east =
    qw(1.duke 16.ndST 8.vcu 9.ucf 5.msST 12.lib 4.vaTech 13.stlouis 6.maryland
    11.belmont 3.lsu 14.yale 7.louisville 10.mn 2.miST 15.bradley);

  my @west =
    qw(1.gonzaga 16.farleigh 8.syracuse 9.baylor 5.marquette 12.murrayST 4.flaST 13.vermont 6.buffalo
    11.azST 3.texTech 14.noKY 7.nevada 10.fla 2.miST 15.montana);

  my @south = qw(1.va 16.gardner 8.ms 9.ok 5.wi 12.or 4.ksST 13.UCirv 6.nova
    11.stmarys 3.purdue 14.olddominion 7.cincy 10.iowa 2.tn 15.colgate);

  my @midwest = qw(1.nc 16.iona 8.utST 9.wa 5.auburn 12.nmST 4.ks 13.ne 6.iowaST
    11.ohST 3.houston 14.gaST 7.wofford 10.setonhall 2.ky 15.abilene);

  $vars{east}    = \@east;
  $vars{west}    = \@west;
  $vars{south}   = \@south;
  $vars{midwest} = \@midwest;

  return \%vars;
}

sub calc_winners {

  use 5.016;
  use warnings;

  my $rvars = shift;
  my %vars  = %$rvars;


  my $new_ref = $vars{east};
  my @east    = @$new_ref;

  #say "east is @east";
  my @pairs;
  while (@east) {
    my $first = shift @east;
    my $next  = shift @east;
    push @pairs, "$first vs $next";
  }
  say "pairs are @pairs";
  my $ref_pairs = \@pairs;
  dd $ref_pairs;
  my $ref_winners = play_game($ref_pairs);

  return $ref_winners;    # end calc_winners
}

sub play_game {

  use 5.016;
  use warnings;

  my $ref_pairs = shift;
  my @pairs     = @$ref_pairs;
  say "in play_game";
  say "pairs are @pairs";
  my @winners;
  for my $line (@pairs) {
    if ( $line =~ /^(\d+)\.(\w+) vs (\d+)\.(\w+)$/ ) {
      say "matched";
      say "$1 $2 $3 $4";

      my $denominator = $1 + $3;
      my $ratio       = $3 / $denominator;
      say "ratio was $ratio";
      my $random_number = rand();
      if ( $random_number < $ratio ) {
        push @winners, "$1.$2";
      }
      else {
        push @winners, "$3.$4";
      }

    }

  }
  my $ref_winners = \@winners;

  return $ref_winners;
}    # end play_game
__END__
