#!/usr/bin/perl

#
# This file belongs to the Solhybrid-SPP package at https://github.com/netadair/Solhybrid-SPP
#
# SPP via TCP implementation to access Solhybrid inverters
# Please report back any change or improvement to me. TIA
#
# 20220103      Michael Rausch <mr@netadair.de>         Initial published version
#


use warnings; use strict;

use IO::Socket::INET;
use Data::Dump qw(pp);

use FindBin qw($Bin);
use lib "$Bin/.";
use solhybrid_spp_registers;
use solhybrid_spp;
use solhybrid_spp_output;

# auto-flush on socket
$| = 1;
 


our $peerhost='127.0.0.1';
our $socket;
our $serviceport=33348;

require 'connectionproperties.pl';


my $serial;

# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);

printf "%s DC\n", "-"x60;

#foreach my $recipient ( 1,2,3 ) {
foreach my $recipient ( 3 ) {
        foreach my $req_param ( (1..500) ) {
                next if !defined($registers->{$recipient}->{$req_param});

		readandoutput($recipient, $req_param);
        }
} # foreach recipient



# ------------------------


$socket->close();
