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
STDOUT->autoflush(1);
STDERR->autoflush(1);

our $peerhost='127.0.0.1';
our $socket;
our $serviceport=33350;

require 'connectionproperties.pl';

$solhybrid_spp_output::outputfh = *STDERR;

my $serial;
my $file;

# ------------------------

printf STDERR "%s ZE\n", "-"x60;

$serial = readandoutput(1, 148);


printf "%s\n", "-"x80;
$file = solhybrid_spp::fileread($socket, 3, 1); # ,{sp=>1}
print $file;

printf "%s\n", "-"x80;
$file = solhybrid_spp::fileread($socket, 3, 4); # ,{sp=>1}
print $file;

printf "%s\n", "-"x80;
$file = solhybrid_spp::fileread($socket, 3, 14); # ,{sp=>1}
print $file;

printf "%s\n", "-"x80;
$file = solhybrid_spp::fileread($socket, 3, 19); # ,{sp=>1}
print $file;

printf "%s\n", "-"x80;

# ------------------------

solhybrid_spp::close($socket);

