#!/usr/bin/perl
#======================================================================
# Auteur : sgaudart@capensis.fr
# Date   : 19/02/2018
# But    : This script check canopsis installation
#
# INPUT :
#          2 config file : one for the hostname (mongo, rabbitmq...) + one for list of checks
# OUTPUT :
#          result of checks
#
#======================================================================
#   Date      Version    Auteur       Commentaires
# 22/02/2018  1          SGA          initial version
#======================================================================

use strict;
use warnings;
use Getopt::Long;

my ($verbose, $debug, $help, $line);
my $checkfile;
my $inventory="inventory.conf";
my ($cps_home,$amqp_vip,$amqp_port,$mongo_host1,$mongo_host2,$mongo_host3,$mongo_port,$influx_host,$influx_port);
our $mongo_hosts;
my @dataline;


GetOptions (
"checkfile=s" => \$checkfile, # string
"inventory=s" => \$inventory, # string
"verbose" => \$verbose, # flag
"debug" => \$debug, # flag
"help" => \$help) # flag
or die("Error in command line arguments\n");

# OPEN inventory file
print "[DEBUG] OPEN file $inventory\n" if $debug;
open (INVENTORY, "$inventory") or die "Can't open file  : $inventory\n" ; # reading
my $hostdata = join "", <INVENTORY>;
close INVENTORY;
eval $hostdata;
die "Couldn't interpret the configuration file ($inventory) that was given.\nError details follow: $@\n" if $@;


# OPEN checkfile
print "[DEBUG] OPEN file $checkfile\n" if $debug;
open (CHECKFD, "$checkfile") or die "Can't open file  : $checkfile\n" ; # reading
while (<CHECKFD>)
{
	$line=$_;
	chomp($line); # delete the carriage return
  print "[DEBUG] checkline=$line---\n" if $debug;
  if (($line ne "") && ($line !~/^#/))
  {
      (@dataline) = split(';', $line);
      check($dataline[0],$dataline[1],$dataline[2],$dataline[3]);
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
	# 1 ARG : metric id
    my(@args) = @_;
    my $subject = $args[0];
    my $label = $args[1];
    my $command = $args[2];
		my $command2;
    my $expected = $args[3]; # verifie si $output=$expect

    $command =~ s/(\$\w+)/$1/eeg;
		print "[DEBUG] command=$command\n" if $debug;
		#print "[DEBUG] mongo_hosts=$mongo_hosts\n" if $debug;
    my $output = `$command`;

		if ($expected eq "INFO")
		{
			 # AFFICHAGE SEULEMENT DU CHECK
			 printf("%-12s | %-35s %-10s\n",$subject,$label,$output);
		}
    else
		{
    	 if ($output =~ /$expected/)
    	 {
       	  printf("%-12s | %-35s %-10s\n",$subject,$label,"OK");
    	 }
    	 else
    	 {
       	  printf("%-12s | %-35s %-10s\n",$subject,$label,"KO");
    	 }
	  }
}
