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

# create an output file
my $munge = strftime( "%d-%m-%Y-%H-%M-%S\.txt", localtime );
my $out_file = $path2->child( 'my_data', "$munge.txt" )->touchpath;
say "out_file is $out_file";

## populate hash
my %vars = (
  protaganist     => 'al debaran',
  trials          => 'adventures',
  ball            => 'toy',
  orientation     => 'left',
  dog             => 'my pretty pitty',
  num1            => '.7',
  activity        => 'stretching',
  non_orientation => 'undef',
  direction       => 'south to the fence',
);

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

my $data = [ [  'protaganist', 'al debaran', 'the narrator', 'JAPH', 'gilligan'],
  [ 'trials' ,'adventures', 'Bedraengnisse'],
  [ 'ball','toy', 'object'],
  [ 'orientation' , 'left', 'right'],
  [ 'dog' ,'my pretty pitty'],
  [ 'num1', '.7', '.3', '50 percent'],
  [ 'activity', 'stretching', 'swimming'],
  [ 'non_orientation', 'undef'],
  [ 'direction', 'south to the fence', 'west', 'yonder' ] ];

dd $data;

__END__
