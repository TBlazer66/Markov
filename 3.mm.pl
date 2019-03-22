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

## populate hash
my $data = [
  [ 'protaganist', 'al debaran', 'the narrator', 'JAPH', 'Dick Vitale' ],
  [ 'event', 'March Madness', 'the Big Dance', 'hoops, baby' ],
  [ 'region', 'east', 'west', 'south', 'midwest' ]
];

#dd $data;

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

  # stochastic input of appositives
  my %vars = map { $_->[0], $_->[ rand( $#{$_} ) + 1 ] } @{$data};
  my $rvars = \%vars;

  $rvars = pop_brackets($rvars);
  $rvars = calc_winners($rvars);
  dd $rvars;

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

}    # end while condition

sub pop_brackets {

  my $rvars = shift;
  my %vars  = %$rvars;

  my @east =
    qw(1.duke 16.ndST 8.vcu 9.ucf 5.msST 12.lib 4.vaTech 13.stlouis 6.maryland
    11.belmont 3.lsu 14.yale 7.louisville 10.mn 2.miST 15.bradley);
  $vars{ref_east} = \@east;

  return \%vars;
}

sub calc_winners {

  use 5.016;
  use warnings;

  my $rvars = shift;
  my %vars  = %$rvars;

  my $new_ref = $vars{ref_east};
  my @east    = @$new_ref;

  #say "east is @east";
  my @pairs;
  while (@east) {
    my $first = shift @east;
    my $next  = shift @east;
    push @pairs, "$first vs $next";
  }
  say "pairs are @pairs";
  my @winners = play_game(@pairs);

  return \%vars;    # end calc_winners
}

sub play_game {

  use 5.016;
  use warnings;

  my @pairs = shift;
  say "pairs are @pairs";

  my @winners;
  for my $line (@pairs) {
    if ( $line =~ /^(\d+)\.(\w+) vs (\d+)\.(\w+)$/ ) {
      say "matched";
      say "$1 $2 $3 $4";

      my $denominator   = $1 + $3;
      my $ratio         = $3 / $denominator;
      my $random_number = rand();
      if ( $random_number < $ratio ) {
        push @winners, "$1.$2";
      }
      else {
        push @winners, "$3.$4";
      }

    }

  }

  return @winners;
}    # end play_game
__END__
