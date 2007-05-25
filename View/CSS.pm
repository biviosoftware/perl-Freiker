# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = __PACKAGE__->internal_compress(<<'EOF');
td.header_left, td.header_right, td.main_left {
  width: 11em;
}
td.header_left {
  background-position: center center;
}
td.header_middle {
  width: auto;
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
td.main_left div.task_menu a {
  background-image: none;
  display: list-item;
  padding: 0;
  margin: 0;
  list-style: none outside Icon('left_menu_sep');;
  margin-left: 20px;
  Font('header_menu');
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
.header_middle .task_menu {
  text-transform: lowercase;
  border-bottom: 1px solid;
  Color('header_menu-border-bottom');
  Font('header_menu');
}
.header_middle .nav a {
  white-space: nowrap;
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
a.movie {
  display: block;
  float: left;
  margin: 0 1em 1em 0;
}
img.graph {
  display: block;
  float: right;
  margin: 1em 0 1em 1em;
}
.prose, .form_prose, .list_prose, div.press, table.prizes {
  width: 40em;
  text-align: left;
  padding: 1ex 0 1ex 0;
}
.prose, div.press {
  padding: 0;
}
.press dt {
  margin-top: 1.5ex;
}
.press dd {
  margin: .3ex 0 0 0;
}
.press h3 {
  margin-top: 2ex;
  margin-bottom: 2ex;
}
.press h4 {
  margin-top: 1ex;
  margin-bottom: 0;
}
.press div {
  margin-top: 1.5ex;
}
.press p {
  margin: 1.5ex 0 1.5ex 0;
  text-align: left;
}
.index_freiker, .index_wheel {
  height: 200px;
}
.index_freiker {
  float: left;
  clear: left;
  padding-right: 20px;
  background: Icon('index_freiker'); no-repeat;
  width: 95px;
}
.index_wheel {
  clear: right;
  margin-left: 20px;
  float: right;
  background: Icon('index_wheel'); no-repeat;
  width: 180px;
}
.index_winners {
  display: block;
  margin: auto;
  background: Icon('index_winners');no-repeat;
  width: 250px;
  height: 212px;
}
div.crest_view {
  margin: 1ex 0 1ex 0;
}
#gears div {
  text-align: center;
}
#gears .simple img {
  padding: 10px;
  vertical-align: middle;
}
#parents .list td {
  padding-top: .05em;
  padding-bottom: .05em;
}
#parents .list {
  margin-top: -1ex;
  margin-bottom: 1ex;
}
.learn_more {
  font-size: 80%;
  white-space: nowrap;
}
.prize_rides {
  font-weight: bold;
}
.prize_left {
  padding-right: 2em;
  clear: left;
  float: left;
}
.prize_right {
  padding-left: 2em;
  clear: right;
  float: right;
}
.prize_winners {
  padding-top: 20px;
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
.note {
  font-weight: bold;
  padding: .2em;
  margin-bottom: 1ex;
  border: 1px solid red;
  text-align: center;
}
.line {
  width: 40em;
  border: 0;
  border-top: 1px solid;
  Color('line-border-top');
  height: 2px;
  text-align: right;
}
.release .label {
  padding-top: 2ex;
  padding-bottom: 2ex;
  text-align: left;
}
table.radio_grid {
  margin-left: 0;
}
div.donate {
  margin: 2ex 0 2ex 0;
  text-align: center;
}
div.donate div.msg {
  text-align: center;
  font-size: 120%;
  font-weight: bold;
  font-style: italic;
  Color('notice');
  text-decoration: underline;
}
.money {
  font-size: 120%;
  font-weight: bold;
  Color('notice');
  margin-right: .5em;
}
.donate form div.field_err {
  display: inline;
  margin-right: .5em;
  font-weight: bold;
  font-size: 100%;
}
.thanks {
  text-align: center;
  padding: .5ex;
  font-size: 120%;
  font-weight: bold;
  Color('notice');
}
.address {
  font-size: 120%;
  font-weight: bold;
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
