# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Util::Prize2006;
use strict;
use Bivio::Base 'Bivio.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create_coupons {
    my($self) = @_;
    $self->initialize_ui;
    my($map) = {
	'Jellibells, Candibells' => 'BL',
	'Water Bottle' => 'WB',
	'Hoodie' => 'HD',
	'Small Poster' => 'SP',
	'Large Poster' => 'LP',
	'Velo 5 Cyclocomputer' => 'VC',
	'Canon PowerShot A460 5.0MP Digital Camera' => 'DC',
	'iPod nano 2GB' => 'IP',
    };
    my($prize) = {@{
	$self->model('AvailablePrizeList')->map_iterate(sub {
	    my($n, $i) = shift->get(qw(Prize.name Prize.prize_id));
	    return ($map->{$n} || 'xx') => $i;
	}),
    }};
    my($fc) = $self->model('FreikerCode');
    foreach my $line (split(/\n/, $self->internal_data_section)) {
	next unless $line;
	my($c, $abbrev) = split(/,/, $line);
	my($id) = $self->unauth_model(FreikerCode => {freiker_code => $c})
	    ->get('user_id');
	foreach my $p (split(' ', $abbrev)) {
	    $self->req->put(query => {
		this => $prize->{$p} || die($p, ': not found'),
		parent_id => $id,
	    });
	    $self->model(ClubPrizeConfirmForm => {});
	}
    }
    return;
}

1;

__DATA__
64237,IP
3378,SP
3508,IP
7365,IP
10512,HD
14305,DC
15967,WB
16854,VC
21641,IP
23517,DC
24603,IP
24746,IP
26276,IP
38026,DC
40393,IP
40650,IP
41649,IP
46809,HD
50634,IP
53766,IP
59177,IP
60714,DC
1788,DC
2641,HD WB
5549,WB SP
5626,IP
5787,WB
5916,IP SP
6642,WB
6867,IP WB
9267,BL
12705,VC SP
14669,IP
17177,LP
17394,BL WB
18914,HD
19604,IP WB
21384,WB SP
22501,HD
23141,SP
23336,WB LP
23937,IP
24224,WB BL
24970,IP WB
27185,WB
27228,IP
28890,IP SP
29328,IP WB
31624,WB BL
32015,BL
32145,SP
33382,IP LB WB
34253,WB
34766,VC WB
34942,IP
36025,VC
36074,WB
36299,WB
36850,IP
37013,WB LP
38766,LP WB
42065,IP
43749,IP
43778,IP BL
44625,IP
45231,BL
46292,HD WB
46791,IP
47686,SP
48270,WB WB
50143,WB SP
52493,IP WB
53902,IP
55304,IP BL
57055,WB LP
57266,WB
57373,IP WB
59601,SP
59618,IP WB
61597,WB
62514,SP WB
64637,IP SP
