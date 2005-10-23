# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::ClassListForm;
use strict;
use base('Bivio::Biz::ExpandableListFormModel');
use Bivio::Util::RealmAdmin;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub MUST_BE_SPECIFIED_FIELDS {
    return [qw(
	Class.class_grade
	Class.class_size
	User.first_name
	User.gender
	User.last_name
    )];
}

sub ROW_INCREMENT {
    return 10;
}

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

sub validate_start {
    shift->[$_IDI] = {classes => {}};
    return;
}

1;
