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
our $serviceport=33345;

my $fulloutput=$ARGV[1];
$serviceport=33343 if ($fulloutput);

require 'connectionproperties.pl';

solhybrid_spp::prep_async_cache();

my $serial;

my $reg1;
my $reg32;

# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);

# ------------------------

printf "%s BMS\n", "-"x60;

readandoutput(5, 148);
readandoutput(5, 147) if ($fulloutput);

readandoutput(5, 129);

$reg32 = solhybrid_spp::request($socket, 5,32);
output_answer(5,32, $reg32);
printf "%s\n", solhybrid_spp_registers::bms_status($reg32);

$reg1 = solhybrid_spp::request($socket, 5,152);
output_answer(5,152, $reg1);
if($reg32 == 5 or $reg32 == 6) {
printf "%s\n", solhybrid_spp_registers::bms_errorlevel($reg1);
} else {
printf "(stale: %s)\n", solhybrid_spp_registers::bms_errorlevel($reg1);
}

$reg1 = solhybrid_spp::request($socket, 5,146);
output_answer(5,146, $reg1);
if($reg32 == 5 or $reg32 == 6) {
printf "%s\n", solhybrid_spp_registers::bms_error($reg1);
} else {
printf "(stale: %s)\n", solhybrid_spp_registers::bms_error($reg1);
}

$reg1 = solhybrid_spp::request($socket, 5,157);
output_answer(5,157, $reg1);
printf "%s\n", solhybrid_spp_registers::bms_error($reg1);


if ($fulloutput) { foreach (1..16) { readandoutput(5, $_); } }

readandoutput(5, 17);
readandoutput(5, 18);
readandoutput(5, 20);

readandoutput(5, 38);
readandoutput(5, 39);
readandoutput(5, 40);
if ($fulloutput) { foreach (41..43,45..50,52..54) { readandoutput(5, $_); } }
readandoutput(5, 55);
readandoutput(5, 56);

readandoutput(5, 60);
readandoutput(5, 61);
# limit type 2="normal"?!
readandoutput(5, 62);

readandoutput(5, 67);
readandoutput(5, 68) if ($fulloutput);
readandoutput(5, 69) if ($fulloutput);

if (defined($fulloutput) and $fulloutput eq 'f2') { foreach (71..87) { readandoutput(5, $_); } }
elsif ($fulloutput) { foreach (71,86..87) { readandoutput(5, $_); } }
readandoutput(5, 58) if ($fulloutput);

#if ($fulloutput) { foreach (90..96) { readandoutput(5, $_); } }

readandoutput(5, 99);
readandoutput(5, 100);
readandoutput(5, 101);
#readandoutput(5, 103);
readandoutput(5, 104);
readandoutput(5, 105);
readandoutput(5, 106);

readandoutput(5, 107) if ($fulloutput);

$reg1 = solhybrid_spp::request($socket, 5,108);
output_answer_bitfields1(5,108, $reg1);
print solhybrid_spp_registers::bms_fug_flags1($reg1);

$reg1 = solhybrid_spp::request($socket, 5,109);
output_answer_bitfields1(5,109, $reg1);
print solhybrid_spp_registers::bms_fug_flags2($reg1);

readandoutput(5, 125);
readandoutput(5, 126); # attn: amphour ohne decimals
#readandoutput(5, 127);
readandoutput(5, 130);
readandoutput(5, 131) if ($fulloutput);
readandoutput(5, 132);
readandoutput(3, 419);

readandoutput(5, 201); # 13 dischard, 23 charge?
readandoutput(5, 202);

readandmap(5, 203, \&solhybrid_spp_registers::bms_socc_block );


readandoutput(5, 204);
readandoutput(5, 205);
readandoutput(5, 206);

if ($fulloutput) { foreach (208..211) { readandoutput(5, $_); } }

readandoutput(5, 212);
readandoutput(5, 213);

#readandoutput(5, 214);

readandmap(5, 248, \&solhybrid_spp_registers::bms_spec );




# ------------------------


$socket->close();
