package solhybrid_spp_output;

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

use Exporter qw(import);
our @EXPORT = qw(output_value output_answer output_answer_bitfields1 output_answer_bitfields2 readandoutput readandmap writeandoutput writenativeandoutput);
 
use Data::Dump qw(pp);

our $registers = $main::registers;

my $labelwidth=25;

our $outputfh = *STDOUT;

sub output_value($$$;$) {
	my $device = shift;
	my $parameter = shift;
	my $value1 = shift;
	my $what = shift || 'Response from';

	if($value1 == 0xAAAA5555) {
		return;
	}

	my $regdesc=$registers->{$device}->{$parameter};


	my $pattern='%d';
	$pattern='%0d' if (defined($regdesc->{Variablen_Typ}) and $regdesc->{Variablen_Typ} eq 'USHORT');
	$pattern="%.".$regdesc->{Nachkomma}."f" if (defined($regdesc->{Nachkomma}) and $regdesc->{Nachkomma} != 0);
	$pattern='0x%08x' if (defined($regdesc->{Bitfield}) and $regdesc->{Bitfield} eq 'Ja');

	my $issetting=$regdesc->{Einstellwert} || '-'; # Istwert oder Zahl

	my $isip=( ($device==1 and ($parameter>=105 and $parameter<=109)) or
		 ($device==2 and (($parameter>=103 and $parameter<=105) or $parameter==109 or $parameter==130)) or
		 ($device==3 and ($parameter==109)) or
		 ($device==4 and (($parameter>=106 and $parameter<=109) or $parameter==150)) );

	my $valuemod = $value1;
	$valuemod = unpack('s', pack('S', $value1)) if (defined($regdesc->{Variablen_Typ}) and $regdesc->{Variablen_Typ} eq 'SHORT');
	$valuemod = unpack('l', pack('L', $value1)) if (defined($regdesc->{Variablen_Typ}) and $regdesc->{Variablen_Typ} eq 'LONG');

	# 15 bit values...
	my $isfugvoltage = ( ($device==5 and ($parameter>=1 and $parameter<=18)) );
	$valuemod = ($valuemod>16384)?-32768+$valuemod:$valuemod if($isfugvoltage);

	$valuemod = $valuemod/(10 ** ($regdesc->{Nachkomma} || 0));

	if($isip) {
		$pattern = '%s';
		$valuemod = sprintf("%d.%d.%d.%d", ($value1>>24)&0xff, ($value1>>16)&0xff, ($value1>>8)&0xff, ($value1>>0)&0xff);
	}

	#my $labelwidth=25;
	#$labelwidth=25 if($device==5);


printf $outputfh "%-13s %d:%-3d (%-${labelwidth}s) is $pattern [%s] (nativ: %d) <%s>\n", $what, $device, $parameter,
	$regdesc->{Kurzbezeichnung} || '-',
	$valuemod, $regdesc->{Einheit} || '-', $value1,
	$issetting;

}

sub output_answer($$$) {
	my $device = shift;
	my $parameter = shift;
	my $value1 = shift;

	if($value1 == 0xAAAA5555) {
		return;
	}

printf "Response from %d:%-3d (%-${labelwidth}s) is %d\t", $device, $parameter,
	$registers->{$device}->{$parameter}->{Kurzbezeichnung},
	$value1;
}

sub output_answer_bitfields1($$$) {
        my $device = shift;
        my $parameter1 = shift;
        my $value1 = shift;

printf "Response from %d:%-3d (%-${labelwidth}s) is %08x\t:\n", $device, $parameter1,
        $registers->{$device}->{$parameter1}->{Kurzbezeichnung},
        $value1;
}

sub output_answer_bitfields2($$$$$) {
	my $device = shift;
	my $parameter1 = shift;
	my $parameter2 = shift;
	my $value1 = shift;
	my $value2 = shift;

	my $labelwidth21= int(($labelwidth-1)/2);
	my $labelwidth22= ($labelwidth-1)-$labelwidth21;

printf "Response from %d:%-3d,%-3d (%-${labelwidth21}s,%-${labelwidth22}s) is %08x %08x\t:\n", $device, $parameter1, $parameter2,
	$registers->{$device}->{$parameter1}->{Kurzbezeichnung}, $registers->{$device}->{$parameter2}->{Kurzbezeichnung},
	$value1, $value2;
}


sub readandoutput($$) {
        my $recipient = shift;
        my $req_param = shift;
        my $reg1;
	our $socket = $main::socket;

        $reg1 = solhybrid_spp::request($socket, $recipient, $req_param);
        output_value($recipient, $req_param, $reg1);

	return $reg1;
}


sub readandmap($$$) {
        my $recipient = shift;
        my $req_param = shift;
        my $mapfunc = shift;
        my $reg1;
	our $socket = $main::socket;

        $reg1 = solhybrid_spp::request($socket, $recipient, $req_param);
        output_answer($recipient, $req_param, $reg1);
	printf "%s\n", &$mapfunc($reg1);

	return $reg1;
}


sub writenativeandoutput($$$) {
        my $recipient = shift;
        my $req_param = shift;
	my $value = shift;
        my $reg1;
	our $socket = $main::socket;

        output_value($recipient, $req_param, $value, 'Writing to');
        $reg1 = solhybrid_spp::request($socket, $recipient, $req_param, {'write'=>$value});
        output_value($recipient, $req_param, $reg1, 'Written to');

	return $reg1;
}

sub writeandoutput($$$) {
        my $recipient = shift;
        my $req_param = shift;
	my $value = shift;
        my $reg1;
	our $socket = $main::socket;

	my $regdesc=$registers->{$recipient}->{$req_param};

	my $valuemod = $value*(10 ** $regdesc->{Nachkomma});

        output_value($recipient, $req_param, $valuemod, 'Writing to');
        $reg1 = solhybrid_spp::request($socket, $recipient, $req_param, {'write'=>$valuemod});
        output_value($recipient, $req_param, $reg1, 'Written to');

	return $reg1;
}




1;
