# Copyright (c) 2006-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
shell_util(TestData => ['reset_all_freikers']);
req()->set_realm(Freiker_Test()->SCHOOL_NAME);
class('Type.Date')->now;
