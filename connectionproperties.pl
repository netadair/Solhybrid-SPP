 
#
# This file belongs to the Solhybrid-SPP package at https://github.com/netadair/Solhybrid-SPP
#
# SPP via TCP implementation to access Solhybrid inverters
# Please report back any change or improvement to me. TIA
#
# 20220103      Michael Rausch <mr@netadair.de>         Initial published version
#


#my $peerhost='127.0.0.1';

my $peerport=33330;

my $peerloc=$ARGV[0] || '';
$peerhost='1.2.3.4' if $peerloc eq 'yourlabelhere';
if ($peerloc eq 'x_yourlocation') { $peerhost='yourhostname'; $peerport=4711; }
$peerhost='127.0.0.'.(2-1+$1) if ($peerloc =~ m/^r(\d+)/);

die "No target ZE specified." if $peerhost eq '127.0.0.1';

#our $socket;
if($Bin =~ m/spp_microservice/) {
        $socket = solhybrid_spp::listen_and_accept($serviceport);
} else {
        $socket = solhybrid_spp::connect($peerhost,$peerport);
}

1;
