package CDS::Utils;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw/get_credentials genpasswd date2iso jira_filter_issues grok_properties cmder/;

use strict;
use warnings;
use Carp;

our $VERSION = '0.05';

sub get_credentials {
    my ($userenv, $passenv, %opts) = @_;

    require Term::Prompt; Term::Prompt->import();

    $opts{prompt}      ||= '';
    $opts{userhelp}    ||= '';
    $opts{passhelp}    ||= '';
    $opts{userdefault} ||= $ENV{USER};

    my $user = $ENV{$userenv} || prompt('x', "$opts{prompt} Username: ", $opts{userhelp}, $opts{userdefault});
    my $pass = $ENV{$passenv};
    unless ($pass) {
	$pass = prompt('p', "$opts{prompt} Password: ", $opts{passhelp}, '');
	print "\n";
    }

    return ($user, $pass);
}

sub genpasswd {
    my $passwd = '';
    $passwd .= ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64] for 1 .. 8;
    return $passwd;
}

# This routine converts dates in the format NN/Aaa/NNNN into the ISO standard NNNN-NN-NN.
my %month_of = (Jan => 1, Feb => 2, Mar => 3, Apr => 4, May => 5, Jun => 6, Jul => 7, Aug => 8, Sep => 9, Oct => 10, Nov => 11, Dec => 12);
my %date_cache;
sub date2iso {
    my ($date) = @_;
    unless (exists $date_cache{$date}) {
	if (my ($day, $month, $year) = ($date =~ m@^(\d{2})/([A-Z][a-z]{2})/(\d{4})$@)) {
	    $month = $month_of{$month} or croak "Invalid month ($month)\n";
	    $date_cache{$date} = "$year-$month-$day";
	}
	else {
	    croak "Invalid date ($date)\n";
	}
    }
    return $date_cache{$date};
}

sub jira_filter_issues {
    my ($jira, $filter, $limit) = @_;

    $filter =~ s/^\s*"?//;
    $filter =~ s/"?\s*$//;

    my $issues = do {
	if ($filter =~ /^(?:[A-Z]+-\d+\s+)*[A-Z]+-\d+$/i) {
	    # space separated key list
	    [map {$jira->getIssue(uc $_)} split / /, $filter];
	} elsif ($filter =~ /^[\w-]+$/i) {
	    # saved filter
	    $jira->getIssuesFromFilterWithLimit($filter, 0, $limit || 1000);
	} else {
	    # JQL filter
	    $jira->getIssuesFromJqlSearch($filter, $limit || 1000);
	}
    };

    # Order the issues by project key and then by numeric value using
    # a Schwartzian transform.
    map  {$_->[2]}
	sort {$a->[0] cmp $b->[0] or $a->[1] <=> $b->[1]}
	    map  {my ($p, $n) = ($_->{key} =~ /([A-Z]+)-(\d+)/); [$p, $n, $_]} @$issues;
}

# http://en.wikipedia.org/wiki/.properties
# Does not deal with backslashes yet
sub grok_properties {
    my ($file) = @_;
    open my $fh, '<:encoding(iso-8859-1)', $file
	or croak "Can't open '$file' for reading: $!\n";
    my %prop;
    while (<$fh>) {
	next if /^\s*(?:[#!]|$)/; # skip comment and blank lines
	if (my ($key, $value) = (/^\d*([-.\w]+)\s*[=:]\s*(.*)/i)) {
	    $value =~ s/^"(.*)"$/$1/; # trim outer quotes
	    my $index = join('"}{"', split /\./, $key); # build up the hash index
	    eval "\$prop{\"$index\"} = \"\Q$value\E\"";
	} else {
	    carp "Ungrokable line: $.: $_";
	}
    }
    return \%prop;
}

sub cmder {
    my ($verbose, $dont) = @_;
    return sub {
	my @cmd = @_;
	warn "# cmd: '", join("' '", @cmd), "'\n" if $verbose;
	if ($dont) {
	    return 0;
	} else {
	    system(@cmd);
	}
    }
}

1;
