#!/usr/bin/env perl

my $basedir = shift @ARGV || "fineract-provider";

sub parse_doc_jfile {
  my $path = shift;

#  print "Parsing Java file: $path\n";
  my $baseapi = undef;
  my $api = undef;
  my $method = undef;
  open(my $fh, $path);
  while (my $line = <$fh>) {
    if ($line =~ m/^\@Path\("(.*)"\)/) {
      $baseapi = $1;
    }
    if ($baseapi) {
      if ($line =~ m/\@Path\("(.*)"\)/) {
        $api = "$baseapi/$1";
        if ($method) {
          print "$method $api\n";
        } else {
          print "$api\n";
        }
      } elsif ($line =~ m/\@(GET|PUT|POST|DELETE)\>/) {
        $method = $1;
      }
    }
  }
  if ($baseapi) {
    $api = $baseapi unless $api;
    if ($method) {
      print "$method $api\n";
    }
  }
  close($fh);
}

sub cycle_dir {
  my $currdir = shift;
#  print "Scanning $currdir\n";

  opendir(my $dh, $currdir);
  while (my $file = readdir($dh)) {
    next if $file eq ".." or $file eq ".";
    my $currfile = "$currdir/$file";
    if (-d $currfile) {
      cycle_dir($currfile);
    } elsif (-f $currfile and $currfile =~ m/\.java$/) {
      parse_doc_jfile($currfile);
    }
  }
  closedir($dh);
}

cycle_dir($basedir);

