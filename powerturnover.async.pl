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
our $serviceport=33342;

require 'connectionproperties.pl';

solhybrid_spp::prep_async_cache();

my $serial;

# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);

readandoutput(1, 1);
readandoutput(1, 2);
readandoutput(1, 14);
readandoutput(1, 21);
readandoutput(1, 23);
readandoutput(1, 24);
readandoutput(1, 39);
readandoutput(1, 40);
readandoutput(1, 46);
readandoutput(1, 47);
readandoutput(1, 131);

printf "%s WR\n", "-"x60;

readandoutput(2, 1);
readandoutput(2, 2);
readandoutput(2, 5);
#readandoutput(2, 78);
#readandoutput(2, 79);
#readandoutput(2, 132);
#readandoutput(2, 138);
#readandoutput(2, 242);
#readandoutput(2, 243);
readandoutput(2, 343);

printf "%s DC\n", "-"x60;

readandoutput(3, 1);
readandoutput(3, 2);
readandoutput(3, 3);
readandoutput(3, 4);
readandoutput(3, 6);
readandoutput(3, 7);
readandoutput(3, 26);
readandoutput(3, 33);
readandoutput(3, 34);
readandoutput(3, 59);
readandoutput(3, 60);
readandoutput(3, 75);
#readandoutput(3, 77);
#readandoutput(3, 78);
#readandoutput(3, 79);
readandoutput(3, 125);
readandoutput(3, 210);
readandoutput(3, 211);
readandoutput(3, 254);
readandoutput(3, 255);
readandoutput(3, 256);

printf "%s BMS\n", "-"x60;

#readandoutput(5, 60);
#readandoutput(5, 61);
#readandoutput(5, 99);
#readandoutput(5, 100);
#readandoutput(5, 101);

# ------------------------


$socket->close();
