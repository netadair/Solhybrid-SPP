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


my $line;

my $device=1;


# Reading device 1

$line = '>> Index:    185 02.04.2020 09:43:06 Typ: Fehler  ENr:40 FNr:35 LNr:2088 A4:003Ah/58ud/+58sd A5:001Dh/29ud/+29sd A6:0008h/8ud/+8sd A7:0001h/0ud/+0sd';

# Event! Typ:"Fehler"  A1:187d/00BBh/"Einschalthindernis"  A2:35d/0023h  A3:1268d/04F4h  A4:254d/00FEh  A5:59d/003Bh  A6:0d/0000h



{
	my $typ; my $enr; my $fnr; my $lnr; my $a4; my $a5; my $a6; my $a7;

	#if($line =~ m/Typ:\s+(\w+)\s+ENr:(\d+)\s+FNr:(\d+)\s+LNr:(\d+)\s*(?:A4:(\w{4})h)?(?:.*?A5:(\w{4})h)?(?:.*?A6:(\w{4})h)?(?:.*?A7:(\w{4})h)?/o ) {
	if($line =~ m/Typ:\s+(\w+)\s+ENr:(\d+)\s+FNr:(\d+)\s+LNr:(\d+)\s*(?:A4:(\w{4})h)?(?:.*?A5:(\w{4})h)?(?:.*?A6:(\w{4})h)?(?:.*?A7:(\w{4})h)?/o ) {

		$typ=$1, # Fehler oder Warnungen
		$enr=$2;
		$fnr=$3;
		$lnr=$4;
		$a4=hex($5||0);
		$a5=hex($6||0);
		$a6=hex($7||0);
		$a7=hex($8||0);
	}

	printf "Typ:%s ENr:%d FNr:%d LNr:%d A4:%04x/%d A5:%04x/%d A6:%04x/%d A7:%04x/%d\n", $typ, $enr, $fnr, $lnr, $a4,$a4, $a5,$a5, $a6,$a6, $a7,$a7;






};





# ------------------------


