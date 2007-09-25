# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::Model::FreikometerUploadList;
use strict;
use Bivio::Base 'Model.FreikometerFileBaseList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub FOLDER {
    return '/Upload';
}

1;
