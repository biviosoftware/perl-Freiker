# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::School;
use strict;
$Freiker::Model::School::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::School::VERSION;

=head1 NAME

Freiker::Model::School - realm

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::School;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Freiker::Model::School::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Freiker::Model::School>

=cut

#=IMPORTS
use Freiker::Type::BarCode;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create_realm"></a>

=head2 create_realm(string school_name, string website) : self

Creates the School and RealmOwner models.  Sets the realm to the school.

=cut

sub create_realm {
    my($self, $school_name, $website) = @_;
    $self->get_request->set_realm(
	$self->new_other('RealmOwner')->create({
	    name => _next_bar_code($self),
	    display_name => $school_name,
	    realm_type => Bivio::Auth::RealmType->SCHOOL,
	    realm_id => $self->create({website => $website})->get('school_id'),
	}),
    );
    return $self;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return {
        version => 1,
	table_name => 'school_t',
	columns => {
            school_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    website => ['HTTPURI', 'NOT_NULL'],
        },
	auth_id => 'school_id',
    };
}

#=PRIVATE SUBROUTINES

# _next_bar_code() : string
#
# Returns the next bar code in the database.
#
sub _next_bar_code {
    my($self) = @_;
    my($res) = '';
    $self->new_other('RealmOwner')->do_iterate(
	sub {
	    my($m) = @_;
	    return 1 if $m->is_default;
	    # Sanity check
	    my($x) = Freiker::Type::BarCode->from_literal_or_die(
		$m->get('name'));
	    # Need to do this manually, because strings don't sort like numbers
	    $res = $x
		if length($x) > length($res)
		    || length($x) == length($res) && $x gt $res;
	    return 1;
	},
	unauth_iterate_start =>
	    'name desc',
	    {realm_type => Bivio::Auth::RealmType->SCHOOL},
    );
    return $res ? Freiker::Type::BarCode->next_school($res)
	: Freiker::Type::BarCode->get_min;
}

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
