#package Solutronic::Descriptions::Solhybrid;
package solhybrid_spp_registers;

#
# This file belongs to the Solhybrid-SPP package at https://github.com/netadair/Solhybrid-SPP
#
# SPP via TCP implementation to access Solhybrid inverters
# Please report back any change or improvement to me. TIA
#
# 20220103      Michael Rausch <mr@netadair.de>         Initial published version
#


use strict;
use warnings;
 
our $VERSION = "1.00";

use Data::Dump qw(pp);


sub get_register_descriptions() {
my $registers;

my $P='.';

foreach ( ['solhybrid.ze.parameters.txt', 1],
	  ['solhybrid.wr.parameters.txt', 2],
	  ['solhybrid.dcdc.parameters.txt', 3],
	  ['solhybrid.gm.parameters.txt', 4],
	  ['solhybrid.bms.parameters.txt', 5] ) {
	my $parmfile=$_->[0];
	my $Device=$_->[1];

open(F, "<${P}/${parmfile}") || die "Cannot open file ${P}/${parmfile}, $!";

my $heading = <F>; # skipped?

while(<F>) {

	next if m/^#|^$|^\s*$/o;

	chomp;

	my
	( $Kurzbezeichnung, $Text, $Hilfetext, $Nummer, $Typ, $Einstellwert, $Initial, $Minimum, $Maximum, $Variablen_Typ, $Passwort,
	 $Einheit, $Vorkomma, $Nachkomma, $Notlockedbyaccesscode, $NotdeletebyP66function, $Bitfield, $Non_Volatile, $FW_Kommentar );

	( $Kurzbezeichnung, $Text, $Hilfetext, $Nummer, $Typ, $Einstellwert, $Initial, $Minimum, $Maximum, $Variablen_Typ, $Passwort,
	 $Einheit, $Vorkomma, $Nachkomma, $NotdeletebyP66function, $Non_Volatile, $Bitfield, $FW_Kommentar ) =
	split("\t", $_) if($Device == 1 or $Device == 3 or $Device == 4 or $Device == 5);

	( $Kurzbezeichnung, $Text, $Hilfetext, $Nummer, $Typ, $Einstellwert, $Initial, $Minimum, $Maximum, $Variablen_Typ, $Passwort,
	 $Einheit, $Vorkomma, $Nachkomma, $Notlockedbyaccesscode, $NotdeletebyP66function, $Bitfield, $Non_Volatile, $FW_Kommentar ) =
	split("\t", $_) if($Device == 2);

	#print pp($_)."\n";

	$registers->{$Device}->{$Nummer} =
		{ Kurzbezeichnung => $Kurzbezeichnung, Text => $Text,
		  Variablen_Typ => $Variablen_Typ, Einheit => $Einheit, Vorkomma=>$Vorkomma, Nachkomma=>$Nachkomma, Bitfield=>$Bitfield,
		  Einstellwert => ($Einstellwert eq 'Einstellwert'?'sb':'is')
		};

	#printf "Register: %d, %s\n", $Nummer, $registers->{$Device}->{$Nummer}->{Kurzbezeichnung};

} # while F

close(F);

} # foreach parmfile, device

return $registers;
}

sub get_device_descriptions() {
	return {
		1=>'ZE',
		2=>'WR',
		3=>'DCDC',
		4=>'GM',
		5=>'BMS'
	       };
}


sub clear_fileio_registers(%) {

	$_=$_[0];

	undef $_->{1}->{251};
	undef $_->{1}->{252};
	undef $_->{1}->{260};
	undef $_->{1}->{261};
	undef $_->{1}->{262};
	undef $_->{1}->{263};
	undef $_->{1}->{264};
	undef $_->{1}->{270};
	undef $_->{1}->{297};

	undef $_->{2}->{251};
	undef $_->{2}->{252};
	undef $_->{2}->{260};
	undef $_->{2}->{261};
	undef $_->{2}->{262};
	undef $_->{2}->{263};
	undef $_->{2}->{264};
	undef $_->{2}->{270};
	undef $_->{2}->{297};

	undef $_->{3}->{251};
	undef $_->{3}->{252};
	undef $_->{3}->{260};
	undef $_->{3}->{261};
	undef $_->{3}->{262};
	undef $_->{3}->{263};
	undef $_->{3}->{264};
	undef $_->{3}->{270};
	undef $_->{3}->{297};

	undef $_->{4}->{251};
	undef $_->{4}->{252};
	undef $_->{4}->{260};
	undef $_->{4}->{261};
	undef $_->{4}->{262};
	undef $_->{4}->{263};
	undef $_->{4}->{264};
	undef $_->{4}->{270};
	undef $_->{4}->{297};

	return $_;
}


my $ze_soobstacles_by_obstacle = {
	  0 => "No obstacle",
	  7 => "UZK too small",
	  8 => "UAC too small",
	212 => "Battery voltage too low for DC link supply",
	214 => "Obstacle Inverter",
	215 => "Obstacle DCDC",
	216 => "Obstacle grid manager",
	217 => "Obstacle BMS",
	220 => "Charge conditions of the devices not met",
	221 => "Discharge conditions of the devices not met",
	224 => "Communication with WR failed",
	226 => "Communication with DCDC failed",
	227 => "Communication with GM failed",
	228 => "Communication with ZE failed",
	231 => "WR UZK Grid Loading voltage is not exceeded",
	232 => "DCDC UZK discharge voltage is not fallen below",
	233 => "No configuration for battery",
	234 => "DCDC UZK low voltage is not fallen below",
	235 => "WR UZK grid loading voltage is not fallen below",
	236 => "DCDC UZK discharge voltage is not exceeded",
	237 => "Waiting Time",
	238 => "Country Code not set",
	239 => "Battery voltage too low for discharge",
	245 => "Battery voltage too low for operation",
	246 => "switch on condition not satisfied",
	247 => "ZE not initialized",
	248 => "WR not initialized",
	249 => "DCDC not initialized",
	250 => "GM not initialized",
	253 => "BMS is not connected",
	254 => "Envorced idle",
	255 => "device class is not set correctly",
	256 => "Initialisation parameter are not actualized",
	261 => "DCDC charge state not reached",
	262 => "BMS is not in operating state",
	263 => "Minimum Battery State Of Charge Reached",
	265 => "Setup required",
	266 => "Battery State of Charge reached 0%",
	267 => "Minimum Grid Loading Switch On Voltage Not Reached",
	268 => "Battery State Of Charge of 100% is reached",
	270 => "Update In Progress",
	272 => "Inverter feed in operation not reached",
	273 => "DCDC discharge state not reached",
	279 => "Inverter Is In Error State",
	280 => "DCDC Is In Error State",
};

my $ze_soobstacles_by_bit = [
	  0,   7,   8, 212, 214, 215, 216, 217, 
	220, 221, 224, 226, 227, 228, 231, 232,
	233, 234, 235, 236, 237, 238, 239, 245,
	246, 247, 248, 249, 250, 253, 254, 255,
	256, 261, 262, 263, 265, 266, 267, 268, 
	270, 272, 273, 279, 280
	];

my $wr_soobstacles_by_obstacle = {
	  0 => "No obstacle",
	  6 => "UZK too large",
	  7 => "UZK too small",
	  8 => "UAC too small",
	  9 => "UAC too large",
	 16 => "over temperature",
	 17 => "frequency too small",
	 18 => "frequency too large",
	 19 => "earth fault DC",
	 22 => "insulation error DC",
	 23 => "mains L, change N",
	 24 => "internal RCD defect",
	 27 => "auxiliary supply stand-by",
	 33 => "offset failure",
	 38 => "Relay defective",
 	 42 => "Stop by external",
	100 => "HSS1 current",
	101 => "HSS2 current",
	171 => "Switch-off by SPI",
	200 => "UAC not connected",
	201 => "AC current too large",
	202 => "Power reduction 100%",
	205 => "Self-test failed",
	207 => "Device type NOK",
	208 => "Grid loading condition",
	210 => "Max. Power for grid load",
	211 => "no feed-in operation",
	222 => "Power range direct change",
	229 => "Standby-Mode",
	230 => "Heartbeat lost",
	237 => "Waiting Time",
	238 => "Country Code not set",
	244 => "under temperature",
	265 => "Setup required",
	269 => "Relaytest required"
};

my $wr_soobstacles_by_bit = [
	  0,   6,   7,   8,   9,  16,  17,  18,
	 19,  22,  23,  24,  27,  33,  38,  42,
	100, 101, 171, 200, 201, 202, 205, 207,
	208, 210, 211, 222, 229, 230, 237, 238,
	244, 265, 269 
	];


my $wr_warnings_by_bit = [
	  0,  1,  2,  3,  5,  6,  7,
	  8, 11, 12, 13, 16, 33, 34,
	 35, 36, 37, 47, 48, 49
        ];



my $dc_soobstacles_by_obstacle = {
	  0 => "No obstacle",
	  6 => "UZK too large",
	  7 => "UZK too small",
	  8 => "UAC too small",
	212 => "Battery voltage too low for DC link supply",
	213 => "Ubatt too large",
	229 => "Standby-Mode",
	230 => "Heartbeat lost",
	233 => "No configuration for battery",
	237 => "Waiting Time",
	239 => "Battery voltage too low for discharge",
	241 => "own supply check",
	242 => "main not reached",
	243 => "Residual current too large",
	244 => "under temperature",
	245 => "Battery voltage too low for operation",
	252 => "BMS state",
	253 => "BMS is not connected",
	255 => "device class is not set correctly",
	257 => "Offset failure DC-link current",
	258 => "Offset failure battery curent",
	262 => "BMS is not in operating state",
	266 => "Battery State of Charge reached 0%",
	268 => "Battery State Of Charge of 100% is reached",
	271 => "Battery Voltage exceeds Device Limit"
	};

my $dc_soobstacles_by_bit = [
	  0,   6,   7,   8, 212, 213, 229, 230,
	233, 237, 239, 241, 242, 243, 244, 245,
	252, 253, 255, 257, 258, 262, 266, 268,
	271,
	];


sub ze_obstacle($) {
	return $ze_soobstacles_by_obstacle->{$_[0]} || $wr_soobstacles_by_obstacle->{$_[0]} || $dc_soobstacles_by_obstacle->{$_[0]};
}


my $errors = {
	  0 => "no error",
	  1 => "IACL too positive",
	  2 => "IACL too negative",
	  3 => "IACN too positive",
	  4 => "IACN too negative",
	  5 => "hardware trip DC",
	  6 => "UZK too large",
	  7 => "UZK too small",
	  8 => "UAC too small",
	  9 => "UAC too large",
	 10 => "overcurrent hardware AC",
	 11 => "auxiliary supply operation",
	 12 => "mains failure",
	 13 => "mains failure",
	 15 => "failure islanding",
	 16 => "over temperature",
	 17 => "frequency too small",
	 18 => "frequency too large",
	 19 => "earth fault DC",
	 21 => "AFI fault current pulse",
 	 22 => "insulation error DC",
 	 23 => "mains L, change N",
 	 24 => "internal RCD defect",
	 25 => "AFI fault current",
	 27 => "auxiliary supply stand-by",
	 29 => "error UAC high",
	 30 => "error UAC low",
	 31 => "error DC-operation",
	 33 => "offset failure",
	 34 => "error offset operation",
	 38 => "error relay defective",
	 39 => "error measured values",
	 40 => "internal error HW/SW",
	 42 => "external error",
	 96 => "trip fault fast",
	 97 => "trip fault slow",
	100 => "error HSS1",
	101 => "error HSS2",
	133 => "Error BGT-List",
	135 => "Error LCD",
	138 => "failure snubber-voltage too high fast",
	139 => "failure snubber-voltage too high slow",
	140 => "failure DC-link voltage too high slow",
	141 => "failure DC-link voltage too high fast",
	142 => "failure battery voltage too high slow",
	143 => "failure battery voltage too high fast",
	144 => "failure DC-link current too high slow",
	145 => "failure DC-link current too high fast",
	146 => "failure battery current too high slow",
	147 => "failure battery current too high fast",
	148 => "failure IZK too positive",
	149 => "failure IZK too negative",
	150 => "failure Ibatt too positive",
	151 => "failure Ibatt too negative",
	154 => "Error FRAM",
	155 => "Error RTC",
	156 => "Error I2C",
	157 => "Trip current DC-link",
	158 => "Trip current battery",
	160 => "DC-link voltage too small charge slow",
	161 => "DC-link voltage too small charge fast",
	162 => "DC-link voltage too small discharge slow",
	163 => "DC-link voltage too small discharge fast",
	164 => "TCP-Error",
	165 => "WDT-Error",
	166 => "isolation battery",
	169 => "SPI Error",
	170 => "Update Error",
	171 => "Switch-off by SPI",
	176 => "Feed in to Grid loading",
	177 => "Grid Loading to Feed in",
	178 => "Grid Loading",
	179 => "Mode Change",
	180 => "Error State Machine",
	181 => "Device not initialized",
	182 => "WR state",
	183 => "DCDC state",
	184 => "Heartbeat lost",
	185 => "Time Slice",
	186 => "Battery type changed",
	187 => "Feed-in hindrance",
	236 => "NTC Broken",
	238 => "DC link supply battery voltage minimum reached",
	239 => "DC link supply maximum time",
	240 => "ADC0 IDC in AC",
	241 => "ADC0 temperature",
	242 => "ADC0 UPV1",
	243 => "ADC0 UPV2",
	244 => "ADC0 IPV1",
	245 => "ADC0 IPV2",
	246 => "ADC1 UZKM",
	247 => "ADC1 IAFI",
	248 => "ADC1 UAC2",
	249 => "ADC1 UZK",
	250 => "ADC1 UAC",
	251 => "ADC1 IACN",
	252 => "ADC1 IACL",
	253 => "ADC0 wrong channel",
	254 => "ADC0 sequential conversion failed",
	255 => "ADC1 wrong channel",
	256 => "ADC0 Supply 12V",
	257 => "ADC0 Supply 5V",
	258 => "ADC0 Supply 3,3V",
	259 => "ADC0 Supply 5V reference",
	260 => "ADC0 Supply 24V DCDC battery",
	261 => "ADC0 Supply 25V DCDC UZK",
	262 => "ADC0 Supply 26V GM",
	263 => "ADC0 Supply 24V",
	264 => "ADC1 analog input 1",
	265 => "ADC1 analog input 2",
	266 => "ADC1 temperature radiation",
	267 => "ADC1 temperature PV",
	268 => "ADC1 temperature enviroment",
	269 => "ADC1 temperature extern 1",
	270 => "ADC1 temperature extern 2",
	271 => "ADC1 temperature extern 3",
	272 => "ADC1 radiation extern",
	273 => "ADC1 Conversion not ready yet",
	276 => "ADC0 Supply 2,5V",
	277 => "ADC0 Supply UZK",
	278 => "ADC0 battery current",
	279 => "ADC0 snubber voltage",
	280 => "ADC0 temperature 1",
	281 => "ADC0 temperature 2",
	284 => "ADC0 supply 15V",
	285 => "ADC0 parallel conversion failed",
	286 => "ADC1 DC link current",
	287 => "ADC1 battery voltage",
	288 => "ADC1 DC link voltage",
	289 => "ADC1 filtered DC link current",
	290 => "ADC1 filtered battery current",
	291 => "ADC1 insulation voltage",
	292 => "ADC1 DC link current Amp",
	293 => "ADC1 battery current Amp",
	294 => "under temperature",
	295 => "Discharge battery voltage minimum reached",
	296 => "operating battery voltage minimum reached",
	294 => "under temperature",
	314 => "Communication with Gridmanager failed",
	315 => "device class is not set correctly",
	316 => "BGT is frozen",
	317 => "Communication with BMS failed",
	319 => "Device not connected",
	320 => "BMS is not connected",
	321 => "BMS is not in operating state",
	322 => "Battery Voltage exceeds Device Limit",
	323 => "Battery State Of Charge of 100% is reached",
	324 => "Battery State of Charge reached 0%",
	325 => "CAN Bus Off active",
	329 => "Portal"
	};

my $warnings = {
	 0 => "no warning",
	 1 => "Warning UAC",
	 2 => "Warning UDC too larg",
	 3 => "Warning: inverter hot",
	 5 => "Warn: yield slaves",
	 6 => "Warn: communication",
	 7 => "Warn: mains frequ.",
	 8 => "Warn: frequent err.",
	11 => "internal",
	12 => "Warning RTC reset",
	13 => "Firmwareupdate",
	16 => "EJL erased",
	33 => "LCD_Warning",
	34 => "Feed-in hindrance",
	35 => "Power Reduction by Frequency",
	36 => "SPI Frequency Limits active",
	37 => "Grid Loading",
	38 => "Gridfail detected",
	39 => "Grid return detected",
	40 => "Disconnect OFF-Grid",
	41 => "Connect ON-Grid",
	42 => "DCDC state",
	43 => "System Reset",
	44 => "BMS not connected",
	45 => "BMS connected",
	46 => "Conservation Charging is started",
	47 => "Heartbeat lost",
	48 => "Heartbeat detected",
	49 => "CAN Bus eliminated"
	};


sub error($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $errors->{$_[0]};
}

sub warning($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $warnings->{$_[0]};
}


my $stati={
	 0 => "Initialization",
	 1 => "Ready for Operation",
	 2 => "Switch on Test",
	 3 => "Feed-in Operation",
	 4 => "Warning",
	 5 => "Failure",
	 6 => "Waiting Time",
	 7 => "Night Operation",
	 8 => "Switch-on Guard",
	11 => "Self-Test",
	24 => "Step-up Converter Operation",
	25 => "Start Grid Loading",
	26 => "Grid Loading",
	27 => "Charge",
	28 => "Discharge",
	31 => "Communication with default setting",
	32 => "Operation with default IP",
	34 => "Step-up Converter without Grid",
	35 => "Start Grid Loading directly",
	36 => "Offgrid",
	37 => "DC Link Supply",
	40 => "Operating parallel to mains Ongrid",
	41 => "Operating on emergency power Offgrid",
	42 => "Gridfail detected switching blocked",
	43 => "Grid return detected switching blocked",
	44 => "Start Sequence",
	45 => "Start Sequence Handler",
	47 => "Self Test in progress",
	50 => "Initialization Handler",
	51 => "Check Slave Self Test",
	52 => "Initiate Slave Reset",
	53 => "Check Slave Firmware Update",
	54 => "Slave Firmware Update",
	56 => "Start Sequence successful",
	57 => "Start Sequence Error",
	58 => "Operation",
	59 => "Idle",
	63 => "Operation Error",
	66 => "Main Error",
	67 => "None",
	68 => "Not Initialized",
	69 => "Initialize Parameters",
	70 => "Self Configuration",
	71 => "Black-Start",
	72 => "Initiate Black-Start",
	73 => "Initiate Conservation Charging",
	74 => "Conservation Charging",
	75 => "Default Mode",
	76 => "Priority Discharge",
	77 => "Priority Charge"
	};

sub status($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $stati->{$_[0]};
}


sub wr_trinfo($) {
	my $reg23 = shift;

	my $text = '';

	$text.="0 1 Check grid loading\n" if ( ($reg23 & 0x01) != 0 );
	$text.="1 1 Start grid loading\n" if ( ($reg23 & 0x02) != 0 );
	$text.="2 1 Step up converter without grid\n" if ( ($reg23 & 0x04) != 0 );
	$text.="3 1 Standby\n"            if ( ($reg23 & 0x08) != 0 );
	$text.="4 1 -\n"                  if ( ($reg23 & 0x10) != 0 );
	$text.="5 1 -\n"                  if ( ($reg23 & 0x20) != 0 );
	$text.="6 1 -\n"                  if ( ($reg23 & 0x40) != 0 );
	$text.="7 1 -\n"                  if ( ($reg23 & 0x80) != 0 );
	$text.="8 1 Switch off relays if UZK falls below (UACPeak+6V), also if P444 is nonzero.\n" if ( ($reg23 & 0x100) != 0 );

	return $text;
}

sub dcdc_controlword($) {
	my $reg29 = shift;

	my $text = '';

	$text.="0 1 Power on\n" 		if ( ($reg29 & 0x01) != 0 );
	$text.="1 1 charge battery\n" 		if ( ($reg29 & 0x02) != 0 );
	$text.="2 1 discharge battery\n"	if ( ($reg29 & 0x04) != 0 );
	$text.="3 1 DC link supply\n"  		if ( ($reg29 & 0x08) != 0 );

	return $text;
}





sub ze_switchon_hindrance($$$) {

	my $device=shift;
	my $reg222=shift;
	my $reg223=shift;

	my $by_bit;
	my $by_obstacle;

	($by_bit, $by_obstacle) = ( $ze_soobstacles_by_bit, $ze_soobstacles_by_obstacle) if ($device == 1);
	($by_bit, $by_obstacle) = ( $wr_soobstacles_by_bit, $wr_soobstacles_by_obstacle) if ($device == 2);
	($by_bit, $by_obstacle) = ( $wr_warnings_by_bit,    $warnings ) if ($device == 21);
	($by_bit, $by_obstacle) = ( $dc_soobstacles_by_bit, $dc_soobstacles_by_obstacle) if ($device == 3);

	my $obstacles_text='';

	foreach my $bitnum ( 0..63 ) {
		my $bitset0=1<<($bitnum); $bitset0=0 if ($bitnum>=32);
		my $bitset1=1<<($bitnum-32); $bitset1=0 if ($bitnum<32);

		if( (($reg222 & $bitset0) != 0) or (($reg223 & $bitset1) != 0 )) {

			my $obstacle=$by_bit->[$bitnum];
			my $obstacle_t = $by_obstacle->{$obstacle};

			$obstacles_text.=sprintf "%2d %d %3d %s\n", $bitnum, 1, $obstacle, $obstacle_t;

		} else {
			#$obstacles_text.=sprintf "%2d %d 0 -\n", $bitnum, 0;
		}


		$bitnum++;
	}

	return $obstacles_text;
}


my $bms_stati = {
	0 => "Initializing",
	1 => "Initialisation_Done",
	2 => "Ready",
	3 => "Operating",
	4 => "Relais_Test",
	5 => "Error",
	6 => "Fatal_Error"
	};

sub bms_status($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $bms_stati->{$_[0]};
}

my $bms_errorlevels = {
	0 => "Ok", # ?
	1 => "Warning",
	2 => "Error (self-recoverable)",
	3 => "Fatal Error (not self-recoverable)"
	};

sub bms_errorlevel($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $bms_errorlevels->{$_[0]};
}

my $bms_errorwarnings = {
	 0=>"NO_Error",
	 1=>"Initialisation_Error",
	 2=>"Initialisation_Error_LTC",
	 3=>"Initialisation_Error_FRAM", 
	 4=>"No_Valid_Communication",
	 5=>"Communication_Error_CAN",
	 6=>"Error_LTC",
	 7=>"Error_Overcurrent",
	 8=>"Error_Cell_Temperature",
	 9=>"Error_Cell_Voltage_Warn",
	10=>"Error_Cell_Voltage_ECHG",
	11=>"Error_Cell_Voltage_High_Error",
	12=>"Error_Cell_Voltage_Low_Error",
	13=>"Error_Cell_Voltage_High_Fatal",
	14=>"Error_Cell_Voltage_Low_Fatal",
	15=>"Error_Balancing_TEMP",
	16=>"Error_Supply",
	17=>"Error_Fuse",
	18=>"Error_Relais",
	19=>"Error_No_factor", # unused ! (Für Shift und Mult, die rausgeflogen sind...
	20=>"Error_No_DevClass_defd",
	21=>"Error_suspect_Tmpr",
	22=>"Error_BMS_Data_missing",
	23=>"Error_MainLoop_slow",
	24=>"Error_Suspicious_Tempr",
	25=>"Error_FRAM_Queue_full",
	26=>"Error_FRAM_Wait_TiOut",
	27=>"Error_FRAM_Read_Error",
	28=>"Error_FRAM_Write_Error",
	29=>"Error_No_valid_QBat",
	30=>"Error_Can_not_calc_self_discharge"
	};

sub bms_error($) {
	return '' if ($_[0] == 0xAAAA5555);
	return $bms_errorwarnings->{$_[0]};
}


sub stringifbitset($$$) {
	my $reg = shift;
	my $bitnum = shift;
	my $string = shift;
	
	return sprintf("%2d %s\n", $bitnum, $string) if ( ($reg & (1<<$bitnum)) != 0);
	return '';
}

sub ze_stinfo($) {
	my $reg = shift;
	my $text = '';
	foreach (
		[  8, "UAC within switch on thresholds" ],
		[  9, "UAC within maximum thresholds" ],
		[ 10, "Grid Frequency ok" ],
		[ 11, "Inverter is working" ],
		[ 12, "IAC ramp 12 percent" ],
		[ 13, "IAC ramp 25 percent" ],
		[ 14, "IAC ramp 50 percent" ],
		[ 15, "Grid Loading ready" ],
		[ 16, "Grid Loading active" ],
		[ 17, "Frequency within switch on thresholds" ],
		[ 18, "-" ],
	 	[ 19, "-" ],
		[ 20, "-" ],
		[ 21, "Communication with grid manager failed" ]
		) {
			$text.=stringifbitset( $reg, $_->[0], $_->[1]);
		}
	return $text;
}

sub bms_socc_block($) {
	my $reg = shift;
	my $text = '';
#	foreach (
#		#[  0, "SOCC blocks neither charging nor discharging" ],
#		[  0, "SOCC blocks discharging" ],
#		[  7, "SOCC blocks charging" ]
#		) {
#			$text.=stringifbitset( $reg, $_->[0], $_->[1]);
#		}

	$text="unknown SOCC blocking state";
	$text="SOCC blocks neither charging nor discharging" if($reg==0);
	$text="SOCC blocks discharging" if($reg==1);
	$text="SOCC blocks charging" if($reg==80); # hex/dec type in BMS?!?

	return "$text";
}

sub bms_spec($) {
	my $reg = shift;
	my $text = '';
	foreach (
		[  0, "balancing on manually" ],
		[  1, "SOCC disabled, SOC 50% always" ],
		[  7, "Power off" ]
		) {
			$text.=stringifbitset( $reg, $_->[0], $_->[1]);
		}

	return "$text";
}

sub bms_fug_flags1($) {
	my $reg = shift;
	my $text = '';
	foreach (
		[  0, "DSG Discharging" ],
		[  1, "SOCF SoC threshold final reached" ],
		[  2, "SOC1 SoC threshold 1 reached " ],
		[  3, "RSVD" ],
		[  4, "CF Gauge needs update cycle" ],
		[  5, "RSVD" ], # [  5, "TDD Tab disconnect" ],
		[  6, "RSVD" ], # [  6, "ISD Internal short" ],
		[  7, "OGVTAKEN OCV measurement in relax mode" ],
		[  8, "CHG (Fast) charging allowed" ],
		[  9, "FC Full charge" ],
		[ 10, "XCHG Charging not allowed" ],
		[ 11, "CHG_INH Charge inhibit, unable to charge" ],
		[ 12, "BATLOW low voltage condition" ],
		[ 13, "BATHIGH high voltage condition" ],
		[ 14, "OTD Over-temperature in Discharge" ],
		[ 15, "OTC Over-temperature in Charge" ],
		) {
			$text.=stringifbitset( $reg, $_->[0] , $_->[1]); # ^ 8 shhh LE systems...
		}

	return "$text";
}

sub bms_fug_flags2($) {
	my $reg = shift;
	my $text = '';
	foreach (
		[  0, "RSVD" ],
		[  1, "RSVD" ],
		[  2, "RSVD" ],
		[  3, "RSVD" ],
		[  4, "RSVD" ],
		[  5, "RSVD" ],
		[  6, "RSVD" ],
		[  7, "RSVD" ],
		[  8, "RSVD" ],
		[  9, "DTCR RemCap changed due to temp" ],
		[ 10, "DODEOC DOD at EOC is updated" ],
		[ 11, "RSVD" ],
		[ 12, "RSVD" ],
		[ 13, "FIRSTDOD Relax mode entered" ],
		[ 14, "LIFE LiFePO4 relax mode enabled" ],
		[ 15, "SOH calculation active" ],
		) {
			$text.=stringifbitset( $reg, $_->[0], $_->[1]); # ^8 shhh LE systems...
		}

	return "$text";
}

# -----------------

our $registers = solhybrid_spp_registers::clear_fileio_registers( solhybrid_spp_registers::get_register_descriptions() );

use parent 'Exporter'; # imports and subclasses Exporter
our @EXPORT = qw($registers);  # EXPORT_OK


1;
