# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';


our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = <<'EOF';
#BEBOP-9.61
.tools div.want_sep {
  CSS('menu_want_sep');
}
body {
  Font('fr_body');
}
table.dock,
table.header,
table.main,
table.footer {
  width: 849px;
  margin: auto;
}
table.header {
  height: 80px;
  Color('fr_header-background');
  margin: 1ex auto;
}
table.main td.main_center {
  padding: .5em;
  border: 2px solid;
  Color('fr_main_center-border');
}
table.main {
  padding-bottom: 1ex;
}
td.header_right .logo_su a {
  margin-right: 30px;
}
table.footer {
  border: none;
  margin-top: 1ex;
  Color('fr_footer-background');
}
table.footer td.footer_left {
  width: 50%;
}
table.footer td.footer_left,
table.footer td.footer_center,
table.footer td.footer_right {
  height: 4em;
  vertical-align: middle;
  margin: auto 5em;
}
table.footer td.footer_left a,
table.footer td.footer_center a,
table.footer td.footer_right a {
  display: block;
  vertical-align: bottom;
  Font('fr_footer');
}
table.footer td.footer_left a {
  padding-left: 5em;
}
table.footer td.footer_center {
  text-align: right;
  width: 40%;
}
table.footer td.footer_center a {
  text-align: right;
  text-decoration: underline;
}
table.footer td.footer_right {
  padding-left: .5em;
}
EOF

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . $_SITE;
}

1;
