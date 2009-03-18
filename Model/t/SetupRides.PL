# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
req()->set_realm('bunit123456789');
shell_util(TestData => ['reset_freikers']);
class('Type.Date')->now;
