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
our $serviceport=33341;

require 'connectionproperties.pl';

solhybrid_spp::prep_async_cache();

my $serial;

my $reg1;
my $reg2;
my $reg23;
my $reg29;
my $reg32;
my $reg74;
my $reg88;
my $reg222;
my $reg223;
my $reg146;
my $reg420;




# ------------------------

printf "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);

# ------------------------

$reg32 = solhybrid_spp::request($socket, 1,32);
output_answer(1,32, $reg32);
printf "%s\n", solhybrid_spp_registers::status($reg32);

# ------------------------

$reg88 = solhybrid_spp::request($socket, 1,88);
output_answer(1,88, $reg88);
printf "%s\n", solhybrid_spp_registers::ze_obstacle($reg88);

# ------------------------

$reg420 = solhybrid_spp::request($socket, 1,420);
output_answer(1,420, $reg420);
printf "%s\n", solhybrid_spp_registers::error($reg420);

# ------------------------

$reg222 = solhybrid_spp::request($socket, 1,222);
$reg223 = solhybrid_spp::request($socket, 1,223);
output_answer_bitfields2(1,222,223, $reg222,$reg223);
print solhybrid_spp_registers::ze_switchon_hindrance(1, $reg222, $reg223);

# ------------------------

#$reg1 = solhybrid_spp::request($socket, 1,18);
#output_answer_bitfields1(1,18, $reg1);
#printf "%s", solhybrid_spp_registers::ze_stinfo($reg1);

# ------------------------

$reg32 = solhybrid_spp::request($socket, 1,31);
output_answer(1,31, $reg32);
printf "%s\n", solhybrid_spp_registers::status($reg32);

# ---

readandoutput(1, 14);
readandoutput(1, 38);

# ------------------------

printf "%s WR\n", "-"x60;

# ------------------------

$reg23 = solhybrid_spp::request($socket, 2,23);
output_answer_bitfields1(2,23, $reg23);
printf "%s", solhybrid_spp_registers::wr_trinfo($reg23);

# ------------------------

$reg32 = solhybrid_spp::request($socket, 2,32);
output_answer(2,32, $reg32);
printf "%s\n", solhybrid_spp_registers::status($reg32);

# ------------------------

$reg88 = solhybrid_spp::request($socket, 2,88);
output_answer(2,88, $reg88);
printf "%s\n", solhybrid_spp_registers::ze_obstacle($reg88);

# ------------------------

$reg146 = solhybrid_spp::request($socket, 2,146);
output_answer(2,146, $reg146);
printf "%s\n", solhybrid_spp_registers::error($reg146);

# ------------------------

$reg420 = solhybrid_spp::request($socket, 2,420);
output_answer(2,420, $reg420);
printf "%s\n", solhybrid_spp_registers::error($reg420);

# ------------------------

$reg222 = solhybrid_spp::request($socket, 2,222);
output_answer_bitfields1(2,222, $reg222);
print solhybrid_spp_registers::ze_switchon_hindrance(2, $reg222, 0);

$reg223 = solhybrid_spp::request($socket, 2,223);
output_answer_bitfields1(2,223, $reg223);
print solhybrid_spp_registers::ze_switchon_hindrance(21, $reg223, 0);

# ------------------------

#$reg1 = solhybrid_spp::request($socket, 2,18);
#output_answer_bitfields1(2,18, $reg1);
#printf "%s", solhybrid_spp_registers::ze_stinfo($reg1);

# ------------------------

printf "%s DCDC\n", "-"x60;

# ------------------------

$reg29 = solhybrid_spp::request($socket, 3,29);
output_answer_bitfields1(3,29, $reg29);
printf "%s", solhybrid_spp_registers::dcdc_controlword($reg29);

# ------------------------

$reg32 = solhybrid_spp::request($socket, 3,32);
output_answer(3,32, $reg32);
printf "%s\n", solhybrid_spp_registers::status($reg32);

# ------------------------

$reg88 = solhybrid_spp::request($socket, 3,88);
output_answer(3,88, $reg88);
printf "%s\n", solhybrid_spp_registers::ze_obstacle($reg88);

# ------------------------

$reg146 = solhybrid_spp::request($socket, 3,146);
output_answer(3,146, $reg146);
printf "%s\n", solhybrid_spp_registers::error($reg146);

# ------------------------

$reg420 = solhybrid_spp::request($socket, 3,420);
output_answer(3,420, $reg420);
printf "%s\n", solhybrid_spp_registers::error($reg420);

# ------------------------

$reg74 = solhybrid_spp::request($socket, 3,74);
output_answer_bitfields1(3,74, $reg74);
print solhybrid_spp_registers::ze_switchon_hindrance(3, $reg74, 0);

# ------------------------

printf "%s GM\n", "-"x60;

# ------------------------

$reg32 = solhybrid_spp::request($socket, 4,32);

output_answer(4,32, $reg32);

printf "%s\n", solhybrid_spp_registers::status($reg32);

# ------------------------

$reg146 = solhybrid_spp::request($socket, 4,146);

output_answer(4,146, $reg146);

printf "%s\n", solhybrid_spp_registers::error($reg146);

# ------------------------

$reg420 = solhybrid_spp::request($socket, 4,420);

output_answer(4,420, $reg420);

printf "%s\n", solhybrid_spp_registers::error($reg420);

# ------------------------

printf "%s BMS\n", "-"x60;

# ------------------------

$reg32 = solhybrid_spp::request($socket, 5,32);

output_answer(5,32, $reg32);

printf "%s\n", solhybrid_spp_registers::bms_status($reg32);

# ------------------------

$reg1 = solhybrid_spp::request($socket, 5,152);

output_answer(5,152, $reg1);

if($reg32 == 5 or $reg32 == 6) {
printf "%s\n", solhybrid_spp_registers::bms_errorlevel($reg1);
} else {
printf "(stale: %s)\n", solhybrid_spp_registers::bms_errorlevel($reg1);
}

# ------------------------

$reg1 = solhybrid_spp::request($socket, 5,146);

output_answer(5,146, $reg1);

if($reg32 == 5 or $reg32 == 6) {
printf "%s\n", solhybrid_spp_registers::bms_error($reg1);
} else {
printf "(stale: %s)\n", solhybrid_spp_registers::bms_error($reg1);
}

# ------------------------

$reg1 = solhybrid_spp::request($socket, 5,157);

output_answer(5,157, $reg1);

printf "%s\n", solhybrid_spp_registers::bms_error($reg1);


# ------------------------

solhybrid_spp::close($socket);

