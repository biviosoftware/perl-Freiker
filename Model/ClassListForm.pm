# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClassListForm;
use strict;
$Freiker::Model::ClassListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Freiker::Model::ClassListForm::VERSION;

=head1 NAME

Freiker::Model::ClassListForm - edit classes

=head1 RELEASE SCOPE

Freiker

=head1 SYNOPSIS

    use Freiker::Model::ClassListForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::ExpandableListFormModel>

=cut

use Bivio::Biz::ExpandableListFormModel;
@Freiker::Model::ClassListForm::ISA = ('Bivio::Biz::ExpandableListFormModel');

=head1 DESCRIPTION

C<Freiker::Model::ClassListForm>

=cut


=head1 CONSTANTS

=cut

=for html <a name="MUST_BE_SPECIFIED_FIELDS"></a>

=head2 MUST_BE_SPECIFIED_FIELDS : array_ref

Fields we require.

=cut

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(
	Class.class_grade
	Class.class_size
	User.first_name
	User.gender
	User.last_name
    )];
}

=for html <a name="ROW_INCREMENT"></a>

=head2 ROW_INCREMENT : int

10 at a time

=cut

sub ROW_INCREMENT {
    return 10;
}

#=IMPORTS
use Bivio::Util::RealmAdmin;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 METHODS

=cut

=for html <a name="execute_ok_end"></a>

=head2 execute_ok_end(string button) : Bivio::Agent::TaskId

If I<button> is commit_and_add_rows, then redirect back to this page.

=cut

sub execute_ok_end {
    my($self, $button) = @_;
    Bivio::Biz::Action->get_instance('Acknowledgement')
        ->save_label('class_list', $self->get_request)
	unless $self->in_error;
    return $button eq 'commit_and_add_rows'
        ? $self->get_request->get('task_id')
        : undef;
}

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

=cut

sub execute_ok_row {
    my($self) = @_;
    my($lm) = $self->get_list_model;
    my($exists) = $lm->get('Class.class_id') ne $lm->EMPTY_KEY_VALUE;
    $self->internal_load_field('User.user_id')
	if $exists;
    if ($self->is_empty_row) {
	if ($exists) {
	    my($req) = $self->get_request;
	    my($old) = $req->get('auth_realm');
	    # This will blow up if there are students, because they'll
	    # be in the school realm as well
	    foreach my $m (qw(User Class)) {
		$req->set_realm($self->get("$m." . lc($m) . '_id'));
		$lm->get_model($m)->cascade_delete;
	    }
	    $req->set_realm($old);
	}
    }
    elsif ($exists) {
	foreach my $m (qw(User Class)) {
	    $self->get_model($m)->update($self->get_model_properties($m));
	}
    }
    else {
	$self->new_other('Class')->create_realm(
	    map({
		my($x) = $self->get_model_properties($_);
		delete($x->{lc($_) . '_id'});
		$x;
	    } qw(Class User)),
	);
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns model configuration.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	list_class => 'ClassList',
	visible => [
	    map({
		{
		    name => $_,
		    in_list => 1,
		    constraint => $_ eq 'User.gender'
			? 'NOT_ZERO_ENUM' : 'NOT_NULL',
		};
	    } @{$self->MUST_BE_SPECIFIED_FIELDS}),
	    {
		name => 'commit_and_add_rows',
		type => 'OKButton',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'User.user_id',
		in_list =>  1,
	    },
	],
	auth_id => 'Class.school_id',
	primary_key => ['Class.class_id'],
    });
}

=for html <a name="validate_row"></a>

=head2 validate_row()

Makes sure we have no duplicates.

=cut

sub validate_row {
    my($self) = shift;
    $self->SUPER::validate_row(@_);
    return if $self->is_empty_row;
    $self->internal_put_error('User.last_name' => 'EXISTS')
	if $self->[$_IDI]->{classes}->{
	    lc(join($;, map(
		defined($_) ? $_ : rand(),
		$self->get(
		    qw(Class.class_grade User.first_name User.last_name)
		))))}++;
    return;
}

=for html <a name="validate_start"></a>

=head2 validate_start()

Creates classes list for detecting duplicate.

=cut

sub validate_start {
    shift->[$_IDI] = {classes => {}};
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
