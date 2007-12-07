# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = <<'EOF';
h2 {
  Font('title');
}
.main_top .byline {
  float: right;
}
td.header_left, td.header_right, td.main_left {
  width: 11em;
}
td.header_left {
  background-position: center center;
}
td.header_middle {
  width: auto;
}
td.header_middle div.donate {
  margin: 2ex 0 2ex 0;
  text-align: center;
}
td.header_middle div.donate div.msg {
  text-align: center;
  font-size: 120%;
  font-weight: bold;
  font-style: italic;
  Color('notice');
  text-decoration: underline;
}
td.main_left div.login {
  text-align: center;
  Color('left_login-background');
  padding-bottom: 2px;
  margin: auto;
  margin-bottom: 1ex;
}
td.main_left div.login .label,
td.main_left div.login .standard_submit {
  padding-top: .5ex;
  Color('main_left_text');
  text-align: center;
}
td.main_left div.login a.label {
  display: block;
}
td.main_left div.login input {
  margin: auto;
  display: block;
}
td.main_left div.task_menu a,
td.main_left div.left_nav a {
  background-image: none;
  display: list-item;
  padding: 0;
  margin: 0;
  list-style: none outside Icon('left_menu_sep');;
  margin-left: 20px;
  Font('nav');
}
td.main_left div.task_menu a:hover,
td.main_left div.left_nav a:hover {
  Font('a_hover');
}
td.main_middle {
  padding-left: 1em;
  padding-right: 1em;
}
div.main_body {
  float: none;
}
td.footer_middle div.task_menu {
  text-align: center;
}
a img, a:hover img {
  border: 1px solid;
  Color('a_img-border');
}
a:hover img {
  Color('a_hover_img-border');
}
div.topic {
  Font('topic');
  margin-bottom: 1ex;
}
.acknowledgement {
  margin-left: 0;
}
.notice {
  padding: .2em;
  width: 14em;
  text-align: right;
  text-transform: none;
  Color('notice');
}
.form_prose, .list_prose, table.prizes {
  width: 40em;
  text-align: left;
  padding: 1ex 0 1ex 0;
}
! IE Bug: If you set .prose, it'll work badly
.prose {
  width: auto;
}
.list .label {
  padding-top: .2em;
  padding-right: .5em;
  text-align: right;
  width: 50%;
}
.list .value {
  padding-top: .2em;
  width: 50%;
  padding-left: .5em;
  text-align: left;
}
form table.simple {
  text-align: left;
  margin: 0;
}
form .list th, form .list td {
  padding: 0 .5em 0 .5em;
}
table.radio_grid {
  margin-left: 0;
}
table.prizes tr.even {
  Color('prizes-background');
}
table.prizes tr.even img {
  float: right;
  margin-left: 1em;
}
table.prizes tr.odd img {
  float: left;
  margin-right: 1em;
}
table.prizes a:hover {
  Color('a_link');
}
table.prizes a:hover img {
  Color('prize_img-border');
}
table.prizes span.desc p.prose {
  display: inline;
}
table.prizes span.name, table.prizes span.rides {
  Font('strong');
}
EOF

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . $_SITE;
}

1;
