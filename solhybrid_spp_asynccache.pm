package solhybrid_spp;

#
# This file belongs to the Solhybrid-SPP package at https://github.com/netadair/Solhybrid-SPP  
# 
# SPP via TCP implementation to access Solhybrid inverters
# Please report back any change or improvement to me. TIA
#
# 20220103	Michael Rausch <mr@netadair.de>		Initial published version
#


use IO::Socket::INET;
use Socket;
use Socket qw(IPPROTO_TCP TCP_NODELAY TCP_KEEPIDLE TCP_KEEPINTVL TCP_KEEPCNT TCP_USER_TIMEOUT);

use solhybrid_spp_registers;

use strict;
use warnings;
 
our $VERSION = "1.00";

use Data::Dump qw(pp);
use File::Basename;
use IO::Handle;

our $microservice_enabled=0;


sub connect($;$) {
	my $peerhost = shift;
	my $port = shift||33330;

	# create a connecting socket
	my $socket = new IO::Socket::INET (
	    PeerHost => $peerhost,
	    PeerPort => $port,
	    Proto => 'tcp',
	);

	die "cannot connect to the server $!\n" unless $socket;

	setsockopt($socket, IPPROTO_TCP, TCP_NODELAY,1);

	setsockopt($socket, SOL_SOCKET, SO_KEEPALIVE, 1);

	setsockopt($socket, IPPROTO_TCP, TCP_KEEPIDLE, 20);
	setsockopt($socket, IPPROTO_TCP, TCP_KEEPINTVL, 3);
	setsockopt($socket, IPPROTO_TCP, TCP_KEEPCNT, 5);
	setsockopt($socket, IPPROTO_TCP, TCP_USER_TIMEOUT, 32);

	$microservice_enabled=0;

	printf STDERR "connected to the server at %s:%s\n", $peerhost, $port;
	return $socket;
}



sub listen_and_accept($) {
	my $port = shift || 33330;
	my $peerhost = shift ||'88.99.57.184';

	# create a connecting socket
	my $socket = new IO::Socket::INET (
	    LocalAddr => $peerhost,
	    LocalPort => $port,
	    Proto => 'tcp',
	    ReuseAddr => 1,
	    Listen => 1
	);

	die "cannot listen on server port $!\n" unless $socket;

	printf STDERR "listening for relay connections on %s:%s\n", $peerhost, $port;

	my $new_socket = $socket->accept(); 

        my $client_address = $new_socket->peerhost;
        my $client_port    = $new_socket->peerport;

        printf STDERR "relay connected from %s:%s\n", $client_address, $client_port;

	setsockopt($new_socket,IPPROTO_TCP,TCP_NODELAY,1);

	$microservice_enabled=1;

	return $new_socket;
}



sub close($) {
	my $socket = shift;
	$socket->close();
}


my $errorcodes = {
 0 => 'No/unknown error',
 1 => 'Parameter non-existent', # (for read and write commands)
 2 => 'Parameter password-protected', # (only for write commands)
 3 => 'Parameter value too large', # as transferred (higher than maximum) (for write commands only)
 4 => 'Parameter value too small', # as transferred (lower than minimum) (for write commands only)
 5 => 'Parameter cannot be changed', # (i.e. an actual value) (only for write commands)
 6 => 'Access code 1', # (parameter is protected by access code 1)
 7 => 'Access code 2', # (parameter is protected by access code 2)
 8 => 'No valid command', # (for example, neither read nor write specified)
 9 => 'Parameter value invalid', # (e.g. invalid date)
10 => 'No answer', # (to a protocol sent to another device)
11 => 'No valid firmware file',
12 => 'No CAN device/timeout',
};

my $asynccachedir="asynccache";
my $cachefile=undef;
my $cachecontent=undef;
my $cachepreput=undef;

sub prep_async_cache()
{
   return if( ! -d $asynccachedir );

   my $cachename=$asynccachedir."/".basename($0)."_".join('_', @ARGV);

   if( -e $cachename and open($cachefile, "<$cachename") ) {
	sysread($cachefile, $cachecontent,2000);
	CORE::close($cachefile);
	$cachepreput='';
   } else {
	   open($cachefile, ">$cachename") or die "Cannot open async cache file for writing, $!";
	   $cachefile->autoflush(0); 
	   binmode($cachefile);
   }
}



sub calc_crc($) {
        my $crc=0;
        map { $crc ^= ord($_); } split //, $_[0] if( ref($_[0]) ne 'ARRAY' );
        map { $crc ^= ord($_); } @{$_[0]} if( ref($_[0]) eq 'ARRAY' );
        return chr(${crc} & 0xff);
}



my %earlyresponses;


sub request($$$;$) {
	my $socket = shift;
	my $recipient = shift;
	my $req_param = shift;
	my $more = shift || {};

	my $sender=0; # always

	my $stx=chr(0x2);
	my $etx=chr(0x3);

my $req = '';

my $do_write=0;
my $do_read=1;
my $do_masterindirect=0;
my $do_filetransfer=0; # 128 bytes

my $value=0;

if(defined($more->{'write'})) {
	$do_read=0;
	$do_write=1;
	$value=$more->{'write'};
}

if(defined($more->{'longread'})) {
	$do_filetransfer=1;
}


my $parameter = $req_param;

$parameter |= 1<<15 if ($do_write);
$parameter |= 1<<14 if ($do_read);
$parameter |= 1<<13 if ($do_masterindirect);
#$parameter |= 1<<12 if ($do_error); # only in result
$parameter |= 1<<11 if ($do_filetransfer);
# $parameter |= 1<<10 if ($do_vdew); # master/slave networking


my $value128empty="\0"x128;

$req = pack('nnnN', $recipient, $sender, $parameter, $value);

#$req = pack('nnnc', $recipient, $sender, $parameter, $value128empty);


$req = "${stx}${req}".solhybrid_spp::calc_crc($req)."${etx}";

my $size;

#print pp($req)."\n";

if(defined($cachecontent)) {
	# write asynchronously once, however check cache consistency

	if(defined($cachepreput) and length($cachepreput) <= 13 * 10) {

		my $cachetosend='';

		my $preputlength = 13 * 10 - length($cachepreput);
		if($preputlength<=length($cachecontent)) {
			$cachetosend=substr($cachecontent,0, $preputlength );
			$cachepreput.=$cachetosend;
			$cachecontent=substr($cachecontent, $preputlength );
		} else {
			$cachetosend=$cachecontent;
			$cachepreput.=$cachetosend;
			$cachecontent='';
		}

		$size = $socket->send($cachetosend);
		#print "sent data of length $size\n";

	}

	$size=length($req);
	#if($req ne substr($cachecontent,0,$size) ) {
	if($req ne substr($cachepreput,0,$size) ) {
		#unlink($cachefile);
		print STDERR pp($req)."\n".pp(substr($cachepreput,0,$size))."\n";
		die "Inconsistent cache content, cleaning cache.";
	}
	$cachepreput=substr($cachepreput,$size);

} else {
	# write synchronously, fill the cache

	$size = $socket->send($req);
	#print "sent data of length $size\n";

	# cache the sent requests
	if(defined($cachefile)) { syswrite($cachefile, $req); }
}

 
my $req_address=sprintf "%d:%d", $recipient,$req_param;

# already delivered asynchronously before
if(defined($earlyresponses{$req_address})) {
	my $resp_value=$earlyresponses{$req_address};
	undef $earlyresponses{$req_address};
	return $resp_value;
}

my $resp_address;
do { # response loop

# receive a response of up to 1024 characters from server
my $response = '';

my $cnt=0;
while(not(length($response) == 13 or length($response) == 137)) {
	die "Socket read loop, only read ".length($response)." bytes so far." if($cnt>20);
	my $r2 = '';
	#$socket->recv($r2, 1024);
	$socket->recv($r2, 13-length($response));
	$response.=$r2;
	$cnt++;
}

#printf "Length %d\n", length($response);
#print pp($response)."\n";

die "Empty response\n" if (!defined($response) or $response eq '');

my @resp = split //, $response;


if( pop(@resp) ne $etx  or shift(@resp) ne $stx ) {
	print STDERR "Framing error\n";
	die;
}

my $resp_crc=pop(@resp); if( solhybrid_spp::calc_crc(\@resp) ne $resp_crc ) {
	print STDERR "CRC error\n";
	die;
}

my ($resp_recipient, $resp_sender, $resp_parameter,$resp_value ) = unpack('nnnN', join('', @resp) );
my $resp_value_s = unpack('l', pack('L', $resp_value));

my $resp_errorcode = $resp_value & 0xffff;

if($resp_parameter&(1<<12)) {
	printf STDERR "Response from %d:%d (%s), return %08x, error %d (%s)\n",
		$resp_sender, $resp_parameter&0x3ff,
		"-", #$registers->{$recipient}->{$resp_parameter&0x3ff}->{Kurzbezeichnung},
		$resp_value, $resp_errorcode, $errorcodes->{$resp_errorcode}||'Unknown';
	#die;
	#return 0xAAAA5555;
	$resp_value=0xAAAA5555;
}

if($resp_parameter&(1<<11)) {
	$resp_value = substr(join('', @resp),6,128);
	$resp_value=pack('L>[32]', unpack('L<[32]', $resp_value));
}


$resp_address=sprintf "%d:%d", $resp_sender,$resp_parameter & 0x3ff;


return $resp_value if($req_address eq $resp_address);


if($req_address ne $resp_address) {
	$earlyresponses{$resp_address}=$resp_value;
	#printf STDERR "Asynchronous error, received answer %s for requested %s .\n", $resp_address, $req_address;
}

} while(1);

}


my $filedescriptions = {
 0 => { desc=>'(File read reset)' },
 1 => { desc=>'Error memory' },
 2 => { desc=>'List of all parameters' },
 3 => { desc=>'List of error codes' },
 4 => { desc=>'List of error counters' },
 5 => { desc=>'List of all actual values' },
 6 => { desc=>'Data logger' },
 7 => { desc=>'Energy year logger (EYL)' },
 8 => { desc=>'Sensor energy year logger (SEYL)' },
 9 => { desc=>'Sensor and energy year logger (SEYL+EYL)' },
10 => { desc=>'Configuration data logger' },
11 => { desc=>'Left unassigned for future expansions' },
12 => { desc=>'Complete EEPROM (i.e. includes error memory, warning memory, EYL, SEYL, data logger, all configurable parameters.', bin=>1, len=>'32k' },
13 => { desc=>'Yield check list' },
14 => { desc=>'File warning' },
15 => { desc=>'DDU Datablock universal file', bin=>1 },
16 => { desc=>'List of error codes, short' },
17 => { desc=>'List of warnings' },
18 => { desc=>'EYL and SEYL-packed format (useful if all you want to do is read EYL and SEYL quickly)', bin=>1, len=>'12 bytes + 366 days x 4 bytes = 1476 bytes' },
19 => { desc=>'List of all parameters that deviate from standard values' },
20 => { desc=>'Virtual EYL/SEYL (like file 9 but with virtual values)' },
21 => { desc=>'Left unassigned for future expansions' },
22 => { desc=>'32 bit values of all parameters, binary', bin=>1, len=>'14 bytes + (3401 pars x 4 bytes)' },
23 => { desc=>'Binary EYL starting DDMMYY until today (energy year logger)', bin=>1, ddd=>1, len=>'14 bytes + 3 bytes DD, MM, YY + n days x 2 bytes' },
24 => { desc=>'Binary SEYL starting DDMMYY until today (sensor energy year logger)', bin=>1, ddd=>1, len=>'14 bytes + 3 bytes DD, MM, YY + n days x 2 bytes' },
25 => { desc=>'Binary STSP starting DDMMYY until today (error memory)', bin=>1, ddd=>1, len=>'14 bytes + 3 bytes DD, MM, YY + n entries x 6 bytes' },
26 => { desc=>'Binary WSP starting DDMMYY until today (warning memory)', bin=>1, ddd=>1, len=>'14 bytes + 3 bytes DD, MM, YY + n entries x 7 bytes' }, 
27 => { desc=>'Left unassigned for future expansions' },
28 => { desc=>'DCM logger, binary (SP300 only)', bin=>1, ddd=>0, len=>'32k' },
29 => { desc=>'DCM logger (SP300 only)' },
30 => { desc=>'DCM error memory (SP300 only)' },
31 => { desc=>'Device status, binary', bin=>1 },
};

sub fileread($$$;$) {
        my $socket = shift;
        my $device = shift;
        my $file = shift;
	my $sp = shift || 0;

	my $answer;
	my $numblocks; my $numreads;
	my $timeout;
	my $filecontents='';

	printf STDERR "Reading device %d file %d (%s).\n", $device, $file, $filedescriptions->{$file}->{desc} || 'Unknown';

	request($socket, $device, 260, {'write'=>0});
	sleep(2);
	$answer = request($socket, $device, 260, {'write'=>$file});
	die "Cannot read file" if($answer==0xAAAA5555);

	$timeout=0;
	$numblocks=0;
	do {
		die "Timeout while reading device $device file $file" if($timeout>120/5);
		sleep(5);
		$numblocks = request($socket, $device, 261);
		die "Cannot read file" if($numblocks==0xAAAA5555);
		$timeout++;
	} while( $numblocks == 0 );

	printf STDERR "About to read %d blocks/%d bytes\n", $numblocks, 4*$numblocks;
	sleep(1);

	request($socket, $device, 264, {'write'=>0});

	my $actualnumblocks = ($sp)?$numblocks:($numblocks+31)/32; 

	foreach (0 .. $actualnumblocks-1) {
		#printf STDERR "Reading block %d\n", $_;

		if($sp) {
			$answer = request($socket, $device, 262);
			die "Cannot read file" if($answer==0xAAAA5555);
			$filecontents.=pack('N', $answer);
		} else {
			$answer = request($socket, $device, 270);
			die "Cannot read file" if(length($answer)!=128);
			$filecontents.=$answer;
		}
	}
	$numreads = request($socket, $device, 264);

	# no error handing or retry ... would write block no to 264 again
	#die "File read block number error" if ($numreads != $numblocks);

	request($socket, $device, 260, {'write'=>0});
	sleep(2);

	$filecontents=substr($filecontents,0,$numblocks*4); # truncate zero-padding for 128 bytes transfer

	return $filecontents;
}

1;
