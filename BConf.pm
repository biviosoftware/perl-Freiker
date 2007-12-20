# Copyright (c) 2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Freiker::BConf;
use strict;
use base 'Bivio::BConf';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub dev_overrides {
    return {};
}

sub merge_overrides {
    my($proto, $host) = @_;
    return Bivio::IO::Config->merge_list({
        $proto->merge_class_loader({
            delegates => {
		'Bivio::Agent::HTTP::Cookie' => 'Bivio::Delegate::Cookie',
		'Bivio::Agent::TaskId' => 'Freiker::Delegate::TaskId',
	      	'Bivio::Auth::Support' => 'Bivio::Delegate::SimpleAuthSupport',
	      	'Bivio::Type::RealmName' => 'Freiker::Delegate::RealmName',
	      	'Bivio::Auth::Permission' => 'Freiker::Delegate::Permission',
	      	'Bivio::Auth::Role' => 'Freiker::Delegate::Role',
		'Bivio::Type::RowTagKey' => 'Freiker::Delegate::RowTagKey',
	    },
	    maps => {
		Action => ['Freiker::Action'],
		Facade => ['Freiker::Facade'],
		Delegate => ['Freiker::Delegate'],
		Model => ['Freiker::Model'],
		ShellUtil => ['Freiker::Util'],
		TestLanguage => ['Freiker::Test'],
		Type => ['Freiker::Type'],
		View => ['Freiker::View'],
		FacadeComponent => ['Freiker::FacadeComponent'],
	    },
        }),
	'Bivio::Biz::Model::MailReceiveDispatchForm' => {
	    ignore_dashes_in_recipient => 1,
	},
 	'Bivio::SQL::PropertySupport' => {
 	    unused_classes => [],
 	},
	'Bivio::Test::Language::HTTP' => {
	    deprecated_text_patterns => 0,
	},
        'Bivio::UI::Facade' => {
	    default => 'Freiker',
	    http_suffix => 'www.freiker.org',
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
	version => 3,
	root => 'Freiker',
	prefix => 'fr',
	owner => 'bivio Software, Inc.',
    }));
}

1;
