#!/usr/bin/perl

# $Source: /git/github.com/fruumrol/asuka/bin/RCS/stardate.pl,v $
# $Date: 2023/05/18 04:36:36 $
# $Revision: 3.3 $

# envy.rb global set F1 /git/github.com/fruumrol/asuka/bin/stardate.pl
# ps /git/github.com/fruumrol/asuka/bin/stardate.pl
# copys5.py /git/github.com/fruumrol/asuka/bin/stardate.pl
# verse /git/github.com/fruumrol/asuka/bin/stardate.pl

use strict;
use warnings;

use DateTime;
use Getopt::Long;
use feature 'signatures';
no warnings 'experimental::signatures';

my %options = (
  diff        => 0,
  hyphen      => 0,
  interactive => 0,
  localtime   => 0,
  medium      => 0,
  mtime       => undef,
  nl          => 0,
  short       => 0,
  underscore  => 0,
);

GetOptions(
  \%options,
  "diff",
  "hyphen",
  "interactive",
  "localtime",
  "medium",
  "mtime=s",
  "nl",
  "short",
  "underscore",
);

sub promptme($prompt, $dflt) {
  print "$prompt ($dflt): ";
  my $x = <STDIN>;
  chomp($x);
  return $x if ($x ne "");
  return $dflt;
}

sub year2epoch($y0) {
  DateTime->new(
    year       => $y0,
    month      => 1,
    day        => 1,
    hour       => 0,
    minute     => 0,
    second     => 0,
    nanosecond => 0,
    time_zone  => "UTC"
  )->hires_epoch();
}

sub unfmt($sd1) {
  $sd1 =~ s/_/./g;
  $sd1 =~ s/-/./g;
  $sd1;
}

sub stardate2datetime($sd1) {
  $sd1 = unfmt($sd1);
  my $y0 = int($sd1);
  my $t0 = year2epoch($y0);
  my $t1 = year2epoch($y0 + 1);
  my $tx = $t0 + ($t1 - $t0) * ($sd1 - $y0);
  my $dx = DateTime->from_epoch(
    epoch     => $tx,
    time_zone => $ENV{"TZ"}
  );
  return $dx;
}

sub displaydiff($delta, $factor, $label) {
  if ($delta >= $factor) {
    print $delta / $factor . " $label\n";
    exit 0;
  }
}

my $tx;

my $datefmt = "yyyy-MM-dd HH:mm:ss (cccc, MMMM d, yyyy in zzzz ZZZZZ)\n";

if ($options{localtime}) {
  for my $x (@ARGV) {
    print stardate2datetime($x)->format_cldr($datefmt);
  }
  exit(0);
} elsif ($options{diff}) {
  my $delta = abs(unfmt($ARGV[1]) - unfmt($ARGV[0]));
  displaydiff($delta, 1.0, "years");
  displaydiff($delta, 0.08333333333333333, "months");
  displaydiff($delta, 0.019165349048919554, "weeks");
  displaydiff($delta, 0.002737907006988508, "days");
  displaydiff($delta, 0.00011407945862452115, "hours");
  displaydiff($delta, 1.901324310408686e-6, "minutes");
  displaydiff($delta, 3.168873850681143e-8, "seconds");
  print $delta / 3.168873850681143e-11 . " milliseconds\n";
  exit 0;
} elsif ($options{interactive}) {
  my $my_time_zone = $ENV{"TZ"};
  my $df1 = DateTime->now(time_zone => $my_time_zone);
  my $my_year =  $df1->year();
  my $my_month = $df1->month();
  my $my_day = $df1->day();
  my $my_hour = $df1->hour();
  my $my_minute = $df1->minute();
  my $my_second = $df1->second();

  do {
    $my_year = promptme("Year", $my_year);
    $my_month = promptme("Month", $my_month);
    $my_day = promptme("Day", $my_day);
    $my_hour = promptme("Hour", $my_hour);
    $my_minute = promptme("Minute", $my_minute);
    $my_second = promptme("Second", $my_second);
    $my_time_zone = promptme("Time Zone", $my_time_zone);

    eval {
      $tx = DateTime->new(
        year => $my_year,
        month => $my_month,
        day => $my_day,
        hour => $my_hour,
        minute => $my_minute,
        second => $my_second,
        time_zone => $my_time_zone
      );
      print $tx->format_cldr($datefmt);
    } or do {
      print "Invalid date [$@]?\n";
    }
  } while (!$tx);
} elsif ($options{mtime}) {
  my $mtime1 = (stat($options{mtime}))[9];
  die "Failed to get modification time of $options{mtime}\n" unless defined $mtime1;
  $tx = DateTime->from_epoch(epoch => $mtime1, time_zone => "UTC");
} else {
  $tx = DateTime->now(time_zone => "UTC");
}
my $y0 = $tx->year;
my $t0 = year2epoch($y0);
my $t1 = year2epoch($y0 + 1);
my $sd1 = $y0 + ($tx->hires_epoch() - $t0) / ($t1 - $t0);
my $fmt = "%.15f";
if ($options{short}) {
  $fmt = "%.3f";
} elsif ($options{medium}) {
  $fmt = "%.6f";
}
my $formatted_sd1 = sprintf($fmt, $sd1);

if ($options{underscore}) {
  $formatted_sd1 =~ s/\./_/g;
} elsif ($options{hyphen}) {
  $formatted_sd1 =~ s/\./-/g;
}

print $formatted_sd1;
print "\n" if $options{nl};

1;

# vim: set et ff=unix ft=perl nocp sts=2 sw=2 ts=2:
