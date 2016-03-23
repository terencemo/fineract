#!/usr/bin/env perl

use strict;
use warnings;
use JSON::XS;
use Term::ANSIColor;

my $basedir = $ARGV[0];
if ($basedir and -d $basedir) {
  shift @ARGV;
} else {
  $basedir = "fineract-provider";
}

my $method_verbs = {
  post => 'Create',
  put => 'Edit',
  delete => 'Delete',
  get => 'Get'
};

my $api_reg = {};
my $api_hash = {};

sub gprint {
  print color("green"), @_, color("reset");
}

sub add_api {
  my ($mod, $api, $label, $name, $method, $params) = @_;
  $api_reg->{$mod} ||= {};
  $api_reg->{$mod}->{$api} ||= {};
  if ($api_reg->{$mod}->{$api}->{$label}) {
    print color("red") . "\tREPEAT: $mod,$api,$label" . color("reset") . "\n";
  } else {
    $api_hash->{$mod} ||= { methods => {} };
    $api_hash->{$mod}->{methods}->{$label} ||= {
      name => $name,
      path => $api,
      httpMethod => $method,
      description => $name,
      parameters => $params
    };
    $api_reg->{$mod}->{$api}->{$label} = 1;
  }
}

sub process_api {
  my ($mod, $method, $api) = @_;
  my $verb = $method_verbs->{lc($method)};
  print join("", map { "\t$_" } ($method, $api));
  my @params = ($api =~ m/{(\w+)}/g);
  print ", PARAMS=" . join(",", @params) if @params;
  my $label = $verb;
  $label .= "One" if ($method =~ m/get/i and grep { m/id/i } @params);
  $label .= "Template" if ($api =~ m/template/);
  $label .= $mod;  
  print " => $label\n";
  my $name = $label;
  $name =~ s/(.)([A-Z])/\1 \2/g;
  my $params = {
    map {
      $_ => {
        type => "string",
        required => "true",
        default => "",
        description => $_
      }
    } @params
  };
  add_api($mod, $api, $label, $name, $method, $params);
}

sub parse_doc_jfile {
  my $path = shift;

  my $baseapi = undef;
  my $api = undef;
  my $method = undef;
  my $mod = undef;
  open(my $fh, $path);
  while (my $line = <$fh>) {
    if ($baseapi) {
      if ($line =~ m/\@Path\("(.*)"\)/) {
        $api = "$baseapi/$1";
        if ($method) {
          process_api($mod, $method, $api);
        }
        $api = undef;
      } elsif ($line =~ m/\@(GET|PUT|POST|DELETE)/) {
        if ($method) {
          $api ||= $baseapi;
          process_api($mod, $method, $api);
        }
        $method = $1;
      }
    }
    if ($line =~ m/^\@Path\("(.*)"\)/) {
      $baseapi = $1;
      ($mod) = ($path =~ m/\/(\w+?)(?:ApiResource|)\.java$/);
      gprint "$mod ($path)\n";
    }
  }
  close($fh);
}

sub cycle_dir {
  my $currdir = shift;

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

print color("green");
cycle_dir($basedir);
print color("reset");

my $data = {
  name => "Mifos X API Documents",
  description =>  "Mifos X API",
  protocol =>  "rest",
  basePath =>  "https://demo.openmf.org",
  publicPath =>  "/fineract-provider/api/v1",
  headers =>  {
    Accept =>  "application/json",
    Authorization =>  "Basic bWlmb3M6cGFzc3dvcmQ="
  },
};

my $path = $ARGV[0];
shift @ARGV;
print "Readfile argument: $path\n";
my $json = JSON::XS->new->pretty->canonical;
if ($path and -f $path) {
  open(my $fh, $path) or die "Can't find file $path\n";
  my $text = join("", <$fh>);      
  close($fh);
  $data = $json->decode($text);
}

$data->{resources} = $api_hash;

my $fh;
$path = $ARGV[0] || $path;
if ($path) {
  if (-f $path) {
    print "File $path exists. Overwrite? (y/n): ";
    my $op = <STDIN>;
    if ($op !~ m/^y/i) {
      print "Okay, exiting. Specify a new path and try again.\n";
      return;
    }
  }
  open($fh, ">$path");
} else {
  $fh = *STDOUT;
}
print $fh $json->encode($data);

