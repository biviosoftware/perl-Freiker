# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';


our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = <<'EOF';
! ***** from common.css *****
body {
  background-color:#aaa; /* TMP */
  background-color:#45B00C;
  font-family:Verdana, Arial, Helvetica, sans-serif;
  width: 77em;
  margin-left: auto;
  margin-right: auto;
  margin-top: 0;
}

! ***** dock styles *****
.dock .b_task_menu li {
  border-color: white;
}
.dock .b_task_menu a {
  color: white;
}
.dock .b_dd_menu a {
  color: #33aa33;
  font-weight: normal;
  font-size: 100%;
}
.tools .b_dd_menu li a {
  display: block;
  padding: 0 0.2em;
}
.b_dd_menu a:hover,
.tools .b_dd_menu a:hover {
  color: white;
}

! ***** header styles *****
table.header {
  width: 100%;
}
table.header td.header_left {
  padding: .5em;
  width: 303px;
  vertical-align: middle;
}
table.header td.header_middle {
  text-align: center;
  vertical-align: bottom;
  padding: .5em;
  width:100%;
  background-image: url<(>'/bp/every_trip_counts.gif');
  background-repeat: no-repeat;
  background-position: 50% 15%;
}
table.header td.header_middle img {
  padding-bottom: 1em;
}
div.main_top div.tools .b_task_menu li {
  text-align: left;
}
.tools .b_dd_menu {
  border-color: #777;
}
.tools .b_task_menu a {
  font-size: 90%;
  color: #33aa33;
}
.tools .b_dd_menu li {
  display: block;
}
div.tools .dd_menu a {
  display: block;
}
! ***** top bmenu *****
table.header {
  margin-bottom: .5em;
}
table.header td.header_middle .b_rounded_box_body {
  background:#FFE401;
}
table.header td.header_middle .b_task_menu {
  text-align: center;
  margin: 0;
  padding: .6em 0;
}
table.header td.header_middle .b_task_menu li {
  padding: 1em .5em;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.2em;
  font-weight: bold;
  border: 0;
}
table.header td.header_middle .b_task_menu li a {
  font-weight: bold;
  color: #7A0913;
  text-decoration: none;
}
table.header td.header_middle .b_task_menu li a:hover {
  color: #45B00C;
}

! ***** white main oval *****
div.fr_main_rounded_box .b_rounded_box_body {
  background: #FFFFFF;
}

! ***** generic oval styles *****
span.b1f, span.b2f, span.b3f, span.b4f {font-size:1px; overflow:hidden; display:block;}
span.b1f {height:1px; margin:0 5px;}
span.b2f {height:1px; margin:0 3px;}
span.b3f {height:1px; margin:0 2px;}
span.b4f {height:2px; margin:0 1px;}

! ***** generic main table styles *****
table.main {
  background-color: #FFFFFF;
}
table.main .main_left {
  vertical-align:top;
}
table.main .main_middle {
  vertical-align:top;
  padding-left: 1.5em;
  padding-bottom: 1ex;
}
^/bp/Home table.main .main_middle {
  padding-left: 0;
}
.main_top .tools a {
  padding: 0 1ex;
}
.main_top .want_sep {
  border-left:1pt solid black;
}

! ***** footer *****
table.footer {
  border:0;
  margin-top: 1em;
}
td.footer_left, td.footer_right {
  width: 0;
}
table.footer .b_task_menu {
  text-align:center;
  margin-bottom: .3em;
}
table.footer tr td .b_task_menu li {
   padding: 0 1em;
   border-color: white;
}
table.footer .b_task_menu a {
  color: #FFFFFF;
  text-decoration:none;
}
table.footer .b_task_menu a:hover {
  color: #FCF67C;
}
table.footer div.legal {
  color: #FFFFFF;
  text-align:center;
}
table.footer div.legal span {
  color: #FFFFFFF;
  padding: 0 1em;
}
table.footer div.legal a {
  color: #FFFFFF;
  text-decoration:none;
}
table.footer div.legal a:hover {
   color: #FCF67C;
}

! ***** left navigation - blue rounded box with white separator lines *****
div.left_nav {

}
div.left_nav span.b_rounded_box_body {
  background: #3815EB
}
div.left_nav .b_task_menu {
  background-color: #3815EB;
  padding: 0;
  text-align: center;
  color:#FFFFFF;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.1em;
}
div.left_nav .b_task_menu li {
  display: block;
  padding: .75em 0;
  border-top: 1px solid white;
  border-left: 0;
}
div.left_nav .b_task_menu li.b_first {
  border-top: 0;
}
div.left_nav .b_task_menu a {
  color:#FFFFFF;
  font-weight: bold;
}
div.left_nav .b_task_menu li.b_selected a {
  color: yellow;
}

! ***** login box *****
div.login span.b_rounded_box_body {
  background:#4DBF0F;
}
div.login div.b_rounded_box_body {
  background-color: #4DBF0F;
  padding: 1em;
  text-align: center;
}
div.login div.b_rounded_box_body form {
  text-align: center;
}
div.login div.b_rounded_box_body div.label {
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.2em;
  color: #FFFFFF;
  display:block;
  text-align: center;
}
div.login div.b_rounded_box_body input {
  margin-bottom: .5em;
  font-size: 1.2em;
  text-align: left;
}
div.login div.b_rounded_box_body a {
  color: #FFFFFF;
  font-size: 1.1em;
}
! ***** main content styling *****
div.dark_green_oval span {
  background:#2A6D06;
}
div.green_box {
  background-color: #2A6D06;
  padding: .5em;
  color:#FFFFFF;
}
div.green_box p, div.green_box strong, div.green_box li {
  color:#FFFFFF;
  font-size:1.0em;
}
div.green_box li p {
  padding-top: 0;
}
div.green_box ul {
  margin-top:.5em;
}
div.green_box a {
  color: #FCF67C;
  text-decoration:none;
}
div.green_box table td {
  vertical-align: top;
  padding: .5em;
}
div.rides_counted {
  background-color: #FFA60E;
  border: #FF5D0E solid 4px;
  margin-top: .5em;
  margin-right: .5em;
  padding: 1em .5em .5em .5em;
  text-align: center;
}
div.wiki div.rides_counted span {
  width:9.5em;
!RJN: Is this needed?
  font-family: Verdana,Arial,Helvetica,sans-serif;
  font-size: 3em;
  font-weight: bold;
  text-align: center;
  margin: 0;
  padding: .2em 0 .2em 0;
  color: #FFFFFF;
  display: block;
}
div.wiki div.rides_counted a {
  color: #FFFFFF;
  font-size: 1.1em;
  font-weight: bold;
}
div.support_freiker {
  background-color: #026EE6;
  border: #082A4E solid 4px;
  margin-top: .5em;
  font-family:Arial, Helvetica, sans-serif;
  font-size: .9em;
  color: #FFFFFF;
  padding: .3em;
  height: 100%;
}
tr.rides_support {
  vertical-align: top;
}
div.support_text {
  padding-left: .7em;
  padding-bottom: .4em;
  padding-right: .5em;
  color: #FFFFFF;
  font-size: 1.1em;
}
div.support_link {
  text-align: center;
}
div.testimonials {
  font-family:Verdana, Arial, Helvetica, sans-serif;
  font-size: 0.8em;
  margin: .5em;
}
div.wiki div.testimonials h3 {
  font-size: 1.4em;
  padding-top: .5em;
}
div.wiki div.testimonials p {
  padding-bottom: .5em;
}

! ***** new *****
td.fr_h_leftnav {
  width: 8em;
  text-align: center;
  padding: 1em;
}
td.fr_h_content {
  padding: 0;
}
div.login_box form {
  text-align: center;
  margin:0;
  font-size: 1.1em;
}
.fr_label {
  font-family: Arial, Helvetica, sans-serif;
  color:#FFFFFF;
  display:block;
  font-size: 1.1em;
}
div.green_box p, div.green_box a {
  font-size: 1.1em;
}
td.main_left {
  width: 15em;
  text-align: center;
  padding: .75em 1em 1em 1em;
}
! ***** only put bike_kid image on wiki pages
^/bp/.* td.main_left {
  background-image: url<(>'/bp/bike_kid.jpg') ;
  background-repeat: no-repeat;
  background-position: 0 225px;
}
^.*/wiki/.* td.main_left {
  background-image: url<(>'/bp/bike_kid.jpg') ;
  background-repeat: no-repeat;
  background-position: 0 275px;
}

.learn_more {
  position: relative;
}
.learn_more .parents_button {
  position: absolute;
  top: 56px;
  left: 11px;
}
.learn_more .schools_button {
  position: absolute;
  top: 93px;
  left: 11px;
}
.learn_more .sponsors_button {
  position: absolute;
  top: 130px;
  left: 11px;
}

! ***** internal pages *****

div.wiki {
  margin: .5em 1em 1em 0;
}
div.wiki p {
  padding-top: .5em;
}
div.wiki img.fr_top_right {
  float:right;
  margin: 0 1em 1em 1em;
  border: #000000 solid 5px;
}

div.wiki h1 {
  font-size:1.6em;
  color: #000;
}
div.wiki h2 {
  font-size:1.2em;
}
div.wiki h3 {
  font-size:1.0em;
  color: #000;
}
div.main_body, table.main {
  margin-top: 0;
  margin-bottom: 0;
}

div.contact_form {
  margin-top: 1em;
}

! ***** dontate form styling *****
span.money {
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.5em;
}
div.donate input+input {
  margin-left: 1em;
  font-size: 1.2em;
}
div.donate input.money {
  margin-left: 5px;
  font-size: 1.2em;
}

! ****** Misc for internal pages *****
div.in_the_news p
{
  margin-top: .5em;
}
table.results {
  margin-top: 1em;
}
div.FAQ h3 {
  margin-top: 1.5em;
  margin-bottom: 0;
}
div.sponsors h2 {
  margin-top: 2em;
  font-size: 1.4em;
  margin-bottom: 1em;
}
div.sponsors img {
  margin: 30px; 
  position: relative;
  left: 30px;
}
div.wiki img.notice_right {
  float: right; 
  margin: .5ex 1em 1ex 1em; 
  border: 1px solid #000000;
}

! ***** remove title *****
^(/bp/.*|/my/wiki/.*) div.main_top div.title {
  display: block;
  height: auto;
  font-size:1.6em;
  color: #000;
  padding-top: .3em;
}
^(/bp/Home|/my/wiki/Home) div.main_top div.title {
  display: none;
  height: 0;
}
div.fr_changemakers_outer {
  margin-bottom: 2ex;
}
div.fr_changemakers_box .b_rounded_box_body {
  background: red;
}
div.fr_changemakers {
  text-align: center;
}
div.fr_changemakers a {
  color: white;
  font-weight: bold;
  font-size: 2.5em;
}
.center {
  width: 100%;
  text-align: center;
}
EOF

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . $_SITE;
}

1;
