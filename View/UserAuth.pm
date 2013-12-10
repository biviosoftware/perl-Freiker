# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::UserAuth;
use strict;
use Bivio::Base 'View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub create {
    return shift->internal_body(vs_simple_form(UserRegisterForm => [
	qw{
	   UserRegisterForm.RealmOwner.display_name
	   UserRegisterForm.Email.email
	   UserRegisterForm.Address.zip
	   UserRegisterForm.Address.country
	   -optional_address
	   UserRegisterForm.Address.street1
	   UserRegisterForm.Address.street2
	   UserRegisterForm.Address.city
	   UserRegisterForm.Address.state
        },
    ]));
}

sub general_contact {
    return shift->internal_body(vs_simple_form(ContactForm => [
        'ContactForm.from',
	['ContactForm.SchoolContact.club_id', {
	    wf_class => 'Select',
	    choices => ['Model.SchoolContactList'],
	    list_id_field => 'SchoolContact.club_id',
	    list_display_field => 'email_display_name',
	    unknown_label => vs_text('SchoolContactList.unknown_label'),
	}],
	'ContactForm.subject',
	'ContactForm.text',
    ]));
}

sub general_contact_mail {
    my($self) = @_;
    return shift->internal_put_base_attr(
	from => [qw(Model.ContactForm from)],
	to => [qw(Model.ContactForm to)],
	subject => Join([
	    String([qw(Model.ContactForm school_display_name)]),
	    String([qw(Model.ContactForm subject)]),
	], {
	    join_separator => ': ',
	}),
	body => Join([
	    Prose(<<'EOF'),
String([qw(Model.ContactForm school_display_name)]);:

EOF
	    String([qw(Model.ContactForm text)]),
	]),
    );
}

sub internal_settings_form_extra_fields {
    return [qw(
        UserSettingsListForm.Address.zip
        UserSettingsListForm.Address.country
    )];
}

1;
