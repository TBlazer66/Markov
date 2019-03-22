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
my $data = [ [  'protaganist', 'al debaran', 'the narrator', 'JAPH', 'gilligan'],
  [ 'trials' ,'adventures', 'Bedraengnisse'],
  [ 'ball','toy', 'object'],
  [ 'orientation' , 'left', 'right'],
  [ 'dog' ,'my pretty pitty'],
  [ 'num1', '.7', '.3', '50 percent'],
  [ 'activity', 'stretching', 'swimming'],
  [ 'non_orientation', 'undef'],
  [ 'direction', 'south to the fence', 'west', 'yonder' ] ];

#dd $data;

## main loop
# set trials
my $trials = 30;
my $dummy = 1;

while ($trials > 0){

# create an output file
my $first_second = strftime( "%d-%m-%Y-%H-%M-%S", localtime );
my $out_file = $path2->child( 'my_data', "$first_second", "$first_second\.$dummy.txt")->touchpath;
say "out_file is $out_file";

my %vars = map { $_->[0],$_->[rand($#{$_}) + 1] } @{$data};
my $rvars = \%vars;

my @pfaden = $path2->children(qr/\.txt$/);
@pfaden = sort @pfaden;

#say "paths are @pfaden ";

for my $file (@pfaden) {

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

} # end while condition



__END__
