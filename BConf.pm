# Copyright (c) 2005-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::BConf;
use strict;
use base 'Bivio::BConf';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dev_overrides {
    my(undef, undef, $host, undef, $http_port) = @_;
    return {
        'Bivio::Ext::DBI' => {
            derozap_global => {
                connection => 'Bivio::SQL::Connection::MySQL',
                database => 'derozap_global',
                user => 'nagler',
                password => 'nagler',
            },
        },
	'Bivio::Test::Language::HTTP' => {
#	    home_page_uri => "http://$host:$http_port/my-site",
	    server_startup_timeout => 60,
	},
    };
}

sub merge_overrides {
    my($proto, $host) = @_;
    return Bivio::IO::Config->merge_list({
	'Bivio::Biz::Model::MailReceiveDispatchForm' => {
	    filter_spam => 1,
	},
	'Bivio::UI::View::ThreePartPage' => {
	    center_replaces_middle => 1,
	},
        $proto->merge_class_loader({
            delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Agent::TaskId' => 'Freiker::Delegate::TaskId',
		'Bivio::Type::RowTagKey' => 'Freiker::Delegate::RowTagKey',
	      	'Bivio::Auth::Permission' => 'Freiker::Delegate::Permission',
	      	'Bivio::Auth::RealmType' => 'Freiker::Delegate::RealmType',
	      	'Bivio::Auth::Role' => 'Freiker::Delegate::Role',
	      	'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
	      	'Bivio::Type::RealmName' => 'Freiker::Delegate::RealmName',
	    },
	    maps => {
		Freiker => ['Freiker', 'Bivio'],
		Bivio => ['Freiker'],
		Action => ['Freiker::Action'],
		Facade => ['Freiker::Facade'],
		Delegate => ['Freiker::Delegate'],
		Model => ['Freiker::Model'],
		ShellUtil => ['Freiker::Util'],
		TestLanguage => ['Freiker::Test'],
		TestUnit => ['Freiker::TestUnit'],
		Type => ['Freiker::Type'],
		View => ['Freiker::View'],
		FacadeComponent => ['Freiker::FacadeComponent'],
		XHTMLWidget => ['Freiker::XHTMLWidget'],
	    },
        }),
        'Bivio::UI::Facade' => {
	    default => 'Freiker',
	    http_host => 'www.freiker.org',
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
	'Bivio::Test::HTMLParser::Forms' => {
	    error_color => 'error',
	},
    },
    $proto->default_merge_overrides({
	version => 10,
	root => 'Freiker',
	uri => 'boltage',
	prefix => 'fr',
	owner => 'bivio Software, Inc.',
    }));
}

1;
