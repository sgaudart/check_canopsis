#!/usr/bin/perl
#======================================================================
# Auteur : sgaudart@capensis.fr
# Date   : 19/02/2018
# But    : this script allows you to check anything locally via system commands described in a conf file
#
# INPUT :
#          2 config file : one for the hostname+port + one for list of checks
# OUTPUT :
#          result of checks (OK|KO)
#
#======================================================================
#   Date      Version    Auteur       Commentaires
# 22/02/2018  1          SGA          initial version
#======================================================================

use strict;
use warnings;
use Getopt::Long;
use IO::Socket;

my ($verbose, $debug, $help, $line);
my $skip = "";
my $checkfile;
my $inventory="inventory.conf";
my ($cps_home,$amqp_vip,$amqp_port,$mongo_host1,$mongo_host2,$mongo_host3,$mongo_port,$influx_host,$influx_port);
our $mongo_hosts;
my @dataline;
my @datacheckport;


GetOptions (
"checkfile=s" => \$checkfile, # string
"inventory=s" => \$inventory, # string
"verbose" => \$verbose, # flag
"debug" => \$debug, # flag
"skip=s" => \$skip, # can skip specified checks
"help" => \$help) # flag
or die("Error in command line arguments\n");

###############################
# OPEN inventory file
###############################
print "[DEBUG] OPEN file $inventory\n" if $debug;
open (INVENTORY, "$inventory") or die "Can't open file  : $inventory\n" ; # reading
my $hostdata = join "", <INVENTORY>;
close INVENTORY;
eval $hostdata;
die "Couldn't interpret the configuration file ($inventory) that was given.\nError details follow: $@\n" if $@;

###############################
# OPEN checkfile
###############################
print "[DEBUG] OPEN file $checkfile\n" if $debug;
open (CHECKFD, "$checkfile") or die "Can't open file  : $checkfile\n" ; # reading
while (<CHECKFD>)
{
	$line=$_;
	chomp($line); # delete the carriage return
	if (($line ne "") && ($line !~/^#/)) # skip comment and empty line
  {
      (@dataline) = split(',', $line); # ";" => "," changed
			if (($skip eq "") || ($line !~ /$skip/))
			{
      	check($dataline[0],$dataline[1],$dataline[2],$dataline[3]);
			}
  }

}
close CHECKFD;


###############################
# FONCTIONS
###############################

# lance une commande et vérifier le resultat attendu
# du style : SUJET;LABEL;CMDE;OUTPUT à vérifier (c-a-d tu fais un regex dessus)
sub check
{
    my(@args) = @_;
    my $subject = $args[0];
    my $label = $args[1];
    my $command = $args[2];
    my $expected = $args[3]; # verifie si $output=$expect
		my $output;

		$command =~ s/(\$\w+)/$1/eeg; # eval variables
		print "[DEBUG] command=$command\n" if $debug;
    if ($command =~ /check_port/)
		{
      $command =~ s/check_port //; # on enleve check_port
			$output=check_port($command);
		}
		else
		{
    	$output = `$command`;
		}
		print "[DEBUG] output=$output\n" if $debug;

		if ($expected eq "INFO")
		{
			# AFFICHAGE SEULEMENT DU CHECK
			chomp($output); # delete the carriage return
			printf("%-12s | %-35s %-10s\n",$subject,$label,$output);
		}
    else
		{
    	 if ($output =~ /$expected/)
    	 {
       	  printf("%-12s | %-45s %-10s\n",$subject,$label,"OK") if $verbose;
    	 }
    	 else
    	 {
       	  printf("%-12s | %-45s %-10s\n",$subject,$label,"KO");
    	 }
	  }
}


sub check_port
{
	  my(@args) = @_;
    my @datacheckport;
		(@datacheckport) = split(' ', $args[0]);
		my $host = $datacheckport[0];
		my $port = $datacheckport[1];

		my $sock = IO::Socket::INET->new(
    	PeerAddr => $host,
    	PeerPort => $port,
    	Proto    => 'tcp',
    	Timeout  => 3
			);

		if($sock)
		{
    	return 1;
		}
		else
		{
			return 0;
		}
		close $sock or die "close: $!";
}
