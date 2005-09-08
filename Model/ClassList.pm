# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClassList;
use strict;
$Freiker::Model::ClassList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::ClassList::VERSION;

=head1 NAME

Freiker::Model::ClassList - list of classes

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::ClassList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Freiker::Model::ClassList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Freiker::Model::ClassList>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
	order_by => [
	    'Class.class_grade',
	    'User.last_name',
	    'User.first_name',
	    'Class.class_size',
	    'User.gender',
	],
	other => [
	    {
		name => 'class_name',
		type => 'Name',
		constraint => 'NOT_NULL',
	    },
	    [qw(User.user_id RealmUser.user_id)],
	],
	primary_key => [[qw(Class.class_id RealmUser.realm_id)]],
	auth_id => [qw(Class.school_id)],
	where => [
	    'realm_user_t.role', '=',
	    Bivio::Auth::Role->TEACHER->as_sql_param,
	],
    });
}

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row) : boolean

Creates class_name.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{class_name} = join(' ',
	map($row->{$_}->get_short_desc, qw(Class.class_grade User.gender)),
	@$row{qw(User.first_name User.last_name)},
    );
    return 1;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
