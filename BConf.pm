# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::BConf;
use strict;
$Freiker::BConf::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::BConf::VERSION;

=head1 NAME

Freiker::BConf - default configuration

=head1 RELEASE SCOPE

RELEASE-SCOPE

=head1 SYNOPSIS

    use Freiker::BConf;

=cut

=head1 EXTENDS

L<Bivio::BConf>

=cut

use Bivio::BConf;
@Freiker::BConf::ISA = ('Bivio::BConf');

=head1 DESCRIPTION

Configuration.

=cut

#=IMPORTS
# NOTE: Only import the bare minimum, because this class must be
# initialized just after Bivio::IO::Config.

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="dev_overrides"></a>

=head2 dev_overrides(string pwd, string host, string user, int http_port) : hash_ref

Development environment configuration.

=cut

sub dev_overrides {
    my($proto, $pwd, $host, $user, $http_port) = @_;
    return {
    };
}

=for html <a name="merge_overrides"></a>

=head2 merge_overrides(string host) : hash_ref

Base configuration.

=cut

sub merge_overrides {
    my($proto, $host) = @_;
    return {
        $proto->default_merge_overrides(Freiker => fr => 'bivio Software, Inc.'),
        $proto->merge_class_loader({
            delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Agent::TaskId' => 'Freiker::Delegate::TaskId',
#TODO:	      	'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
#TODO:	      	'Bivio::Auth::RealmType' => 'Bivio::Delegate::RealmType',
		'Bivio::TypeError' => 'Freiker::Delegate::TypeError',
		'Bivio::UI::HTML::FormErrors' => 'Freiker::Delegate::FormErrors',
	    },
	    maps => {
#TODO:	      	Action => ['Freiker::Action'],
		Facade => ['Freiker::Facade'],
#TODO:	      	HTMLWidget => ['Freiker::HTMLWidget'],
#TODO:	      	Model => ['Freiker::Model'],
		TestLanguage => ['Freiker::Test'],
#TODO:	      	Type => ['Freiker::Type'],
	    },
        }),
        'Bivio::UI::Facade' => {
	    default => 'Freiker',
	    http_suffix => 'freiker.org',
	    mail_host => 'freiker.org',
        },
        $proto->merge_http_log({
            ignore_list => [
            ],
	    error_list => [
	    ],
	    critical_list => [
	    ],
        }),
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

opyright (c) 2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
