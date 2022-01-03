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
our $serviceport=33344;

require 'connectionproperties.pl';


my $serial;
my $gmserial;

# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);
readandoutput(1, 248);
readandoutput(1, 1);
readandoutput(1, 2);
readandoutput(1, 3);
readandoutput(1, 25);
readandoutput(1, 26);

printf "%s WR\n", "-"x60;

readandoutput(2, 131);
readandoutput(2, 132);
readandoutput(2, 133);
readandoutput(2, 134);
readandoutput(2, 135);
#readandoutput(2, 136);
readandoutput(2, 137);
readandoutput(2, 138);
readandoutput(2, 139);
readandoutput(2, 140);

#printf "%s DC\n", "-"x60;

printf "%s GM\n", "-"x60;

$gmserial = readandoutput(4, 148);
#readandoutput(4, 390);
#readandoutput(4, 391);
#readandoutput(4, 392);
readandoutput(4, 409);
readandoutput(4, 401);
readandoutput(4, 402);
readandoutput(4, 403);
readandoutput(4, 197);
readandoutput(4, 198);
readandoutput(4, 199);

readandoutput(4, 13);
readandoutput(4, 14);
readandoutput(4, 15);
readandoutput(4, 44);
readandoutput(4, 77);


#printf "%s BMS\n", "-"x60;

# ------------------------


$socket->close();
