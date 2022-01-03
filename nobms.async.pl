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
#use solhybrid_spp;
use solhybrid_spp_asynccache;
use solhybrid_spp_output;

# auto-flush on socket
$| = 1;
 

our $peerhost='127.0.0.1';
our $socket;
our $serviceport=33345; # TODO change....

require 'connectionproperties.pl';

solhybrid_spp::prep_async_cache();

my $serial;

my $reg1;
my $reg32;

# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);

readandoutput(1, 64);
foreach (277..294) { readandoutput(1, $_); }

printf "%s DCDC\n", "-"x60;

readandoutput(3, 2);
readandoutput(3, 26);

readandoutput(3, 54);
readandoutput(3, 55);

readandoutput(3, 64);
readandoutput(3, 108);
foreach (123..127) { readandoutput(3, $_); }
readandoutput(3, 176);
readandoutput(3, 185);
foreach (190..192) { readandoutput(3, $_); }
readandoutput(3, 199);
foreach (210..211) { readandoutput(3, $_); }
foreach (230..236) { readandoutput(3, $_); }
readandoutput(3, 243);
readandoutput(3, 253);
readandoutput(3, 258);
foreach (284..289) { readandoutput(3, $_); }








# ------------------------


$socket->close();
