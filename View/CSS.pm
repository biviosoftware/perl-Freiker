# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';


our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = <<'EOF';
!BEBOP-9.61 BEGIN
.tools div.want_sep {
  CSS('menu_want_sep');
}
.tools div.dd_menu a,
div.dd_menu a,
.tools div.dd_menu a.want_sep,
div.dd_menu a.want_sep {
  background: none;
  margin-left: 0;
  padding: 0 .2em;
  border-left: none;
}
.tools div.dd_menu a,
div.dd_menu a {
  display: block;
  padding: 0 .2em;
  Font('dd_menu');
  Color('dd_menu-background');
  text-decoration: none;
  text-align: left;
  font-weight: normal;
}
div.dd_visible {
  visibility: visible;
}
div.dd_hidden {
  visibility: hidden;
}
.tools div.dd_menu a:hover,
div.dd_menu a:hover {
  Color('dd_menu_selected-background');
  Color('dd_menu_selected');
  text-decoration: none;
}
!BEBOP-9.61 END
body {
  Font('fr_body');
}
table.dock,
table.header,
table.main,
table.footer {
  border: none;
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
table.footer_bar {
  width: 100%;
  border: none;
  margin-top: 1ex;
  Color('fr_footer-background');
}
td.footer_bar_left {
  width: 50%;
}
td.footer_bar_left,
td.footer_bar_center,
td.footer_bar_right {
  height: 4em;
  vertical-align: middle;
  margin: auto 5em;
}
td.footer_bar_left a,
td.footer_bar_left div,
td.footer_bar_center a,
td.footer_bar_right a {
  display: block;
  vertical-align: bottom;
  Font('fr_footer');
}
td.footer_bar_left div {
  padding-left: 5em;
}
td.footer_bar_center {
  text-align: right;
  width: 40%;
}
td.footer_bar_center a {
  text-align: right;
  text-decoration: underline;
}
td.footer_bar_right {
  padding-left: .5em;
}
td.centered_cell {
  text-align: center;
}
th.narrow_heading {
  width: 1px;
}
div.footer_legal {
  padding-top: 2ex;
}
div.footer_legal a {
  text-decoration: underline;
}
tr.b_footer_row td {
  font-weight: bold;
}
EOF

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . $_SITE;
}

1;
