# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikerImportForm;
use strict;
use Bivio::Base 'Model.CSVImportForm';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_T) = b_use('FacadeComponent.Text');
my($_USZC) = b_use('Type.USZipCode');
my($_K) = b_use('Type.Kilometers');

sub COLUMNS {
    return [
	[qw(FirstName FreikerCodeForm.User.first_name)],
	[qw(MiddleName FreikerCodeForm.User.middle_name)],
	[qw(LastName FreikerCodeForm.User.last_name)],
	[qw(ZapTag FreikerCodeForm.FreikerCode.freiker_code)],
	[qw(Country FreikerCodeForm.Address.country)],
	[qw(PostalCode FreikerCodeForm.Address.zip)],
	[qw(Miles FreikerCodeForm.miles)],
	[qw(Kilometers FreikerCodeForm.kilometers)],
	[qw(Street1 FreikerCodeForm.Address.street1)],
	[qw(Street2 FreikerCodeForm.Address.street2)],
	[qw(City FreikerCodeForm.Address.city)],
	[qw(State FreikerCodeForm.Address.state)],
	[qw(BirthYear FreikerCodeForm.birth_year)],
	[qw(Gender FreikerCodeForm.User.gender)],
	[qw(Teacher RealmOwner.display_name NONE)],
    ];
}

sub EMPTY_CSV {
    my($proto) = @_;
    return
	join(
	    ',',
	    map($_->[0], @{$proto->COLUMNS}),
	)
	. "\n";
}

sub execute_empty_csv {
    my($proto, $req) = @_;
    $req->get('reply')
	->set_output_type('text/csv')
	->set_output(\($proto->EMPTY_CSV));
    return 1;
}

sub execute_ok {
    my($self) = @_;
    $self->[$_IDI] = {
	columns => {
	    map(
		{
		    my($n, $t) = @$_;
		    $t =~ s/^FreikerCodeForm\.//;
		    $t = 'SchoolClass.school_class_id' 
			if $n eq 'Teacher';
		    (lc($n) => $t);
		}
		@{$self->COLUMNS},
	    ),
	},
    };
    $self->new_other('SchoolClassList')->load_with_school_year;
    $self->new_other('FreikerCodeList')->load_all;
    return shift->SUPER::execute_ok(@_);
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        other => [
	    'Address.country',
	    'Address.zip',
	],
    });
}

sub process_record {
    my($self, $row, $row_count) = @_;
    my($fields) = $self->[$_IDI];
    my($columns) = $fields->{columns};
    _validate_distance($self, $row_count, $row);
    _validate_teacher($self, $row_count, $row);
    _validate_freiker_code($self, $row_count, $row);
    _validate_address($self, $row_count, $row);
    return
	if $self->in_error;
    $self->new_other('FreikerCodeForm')->process({
	map(
	    (
		defined($columns->{$_}) ? $columns->{$_} : $_,
		$row->{$_},
	    ),
	    keys(%$row),
	),
    });
    return;
}

sub _error {
    my($self, $count, $tag, $value) = @_;
    return $self->internal_source_error(
	$count,
	$value
	    ? ($value, ': ')
	    : (),
	$_T->get_value("FreikerImportForm.error.$tag", $self->req),
    );
}

sub _validate_address {
    my($self, $row_count, $row) = @_;
    my($fields) = $self->[$_IDI];
    return _error($self, $row_count, 'country_null')
	unless $row->{country} ||= $fields->{country};
    $fields->{country} = $row->{country};
    return
#TODO: Modularize
	unless $row->{country} eq 'US';
    my($v) = $_USZC->from_literal($row->{postalcode});
    return _error($self, $row_count, 'zip_invalid', $row->{postalcode})
	unless $v;
    $row->{postalcode} = $v;
    return;
}

sub _validate_distance {
    my($self, $row_count, $row) = @_;
    if ($row->{kilometers} && $row->{miles}) {
	_error($self, $row_count, 'both_kilometers_miles');
    }
    elsif (defined($row->{kilometers})) {
	$row->{miles} = $_K->to_miles($row->{kilometers});
    }
    elsif (defined($row->{miles})) {
	$row->{kilometers} = $_K->from_miles($row->{miles});
    }
    else {
	_error($self, $row_count, 'none_kilometers_miles');
    }
    return;
}

sub _validate_freiker_code {
    my($self, $row_count, $row) = @_;
    return
	unless my $code = $row->{'zaptag'};
    my($fcl) = $self->req('Model.FreikerCodeList');
    return _error($self, $row_count, 'freiker_code_not_found', $code)
	unless $fcl->find_row_by_code($code);
    my($addr) = $self->new_other('Address');
    return _error($self, $row_count, 'freiker_code_already_registered', $code)
	if $addr->unauth_load({realm_id => $fcl->get('FreikerCode.user_id')})
	&& $addr->get('zip');
    return;
}

sub _validate_teacher {
    my($self, $row_count, $row) = @_;
    return
	unless my $teacher = delete($row->{teacher});
    my($scl) = $self->req('Model.SchoolClassList');
    return _error($self, $row_count, 'teacher_not_found', $row->{teacher})
	unless $scl->find_by_teacher_name($teacher);
    $row->{'SchoolClass.school_class_id'} = $scl->get('SchoolClass.school_class_id');
    return;
}

1;
