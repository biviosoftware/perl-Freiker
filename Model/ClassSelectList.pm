# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClassSelectList;
use strict;
$Freiker::Model::ClassSelectList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::ClassSelectList::VERSION;

=head1 NAME

Freiker::Model::ClassSelectList - includes a "select" row with class_id undef

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::ClassSelectList;

=cut

=head1 EXTENDS

L<Freiker::Model::ClassList>

=cut

use Freiker::Model::ClassList;
@Freiker::Model::ClassSelectList::ISA = ('Freiker::Model::ClassList');

=head1 DESCRIPTION

C<Freiker::Model::ClassSelectList>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_load"></a>

=head2 internal_load()

Adds first row which is blank.

=cut

sub internal_load {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_load(@_);
    unshift(
	@{$self->internal_get_rows},
	{
	    map(($_ => undef), @{$self->get_keys}),
	    class_name => 'Select Class',
	    'Class.class_id' => $self->EMPTY_KEY_VALUE,
	},
    );
    return @res;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
