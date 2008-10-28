# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::CSS;
use strict;
use Bivio::Base 'Bivio::UI::View::CSS';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_SITE) = <<'EOF';
/***** from common.css *****/
body {
  background-color:#aaa; /* TMP */
  background-color:#45B00C;
  font-family:Verdana, Arial, Helvetica, sans-serif;
  width: 77em;
  margin-left: auto;
  margin-right: auto;
  margin-top: 0;
}

/***** dock styles *****/
table.dock a {
  color:#FFFFFF;
}
table.dock span.want_sep, table.dock a.want_sep {
  background-image: none;
  border-left: white solid 1px;
}

/***** header styles *****/
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
  padding: .5em;
}
table.header td.header_middle img {
  padding-bottom: 1em;
}
/***** top bmenu *****/
table.header {
  margin-bottom: .5em;
}
table.header td.header_middle {
  width:100%;
  vertical-align: middle;
}
table.header td.header_middle .b_rounded_box_body {
  background:#FFE401;
}
table.header td.header_middle div.bmenu {
  text-align: center;
  margin: 0;
  padding: .6em 0;
}
table.header td.header_middle div.bmenu span {
  padding: 1em .5em;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.2em;
  font-weight: bold;
}
table.header td.header_middle div.bmenu span a {
  font-weight: bold;
}
table.header td.header_middle span a {
  color: #7A0913;
  text-decoration: none;
}
table.header td.header_middle span a:hover {
  color: #45B00C;
  text-decoration: none;
}

/***** white main oval *****/
div.fr_main_rounded_box .b_rounded_box_body {
  background: #FFFFFF;
}

/***** generic oval styles *****/
span.b1f, span.b2f, span.b3f, span.b4f {font-size:1px; overflow:hidden; display:block;}
span.b1f {height:1px; margin:0 5px;}
span.b2f {height:1px; margin:0 3px;}
span.b3f {height:1px; margin:0 2px;}
span.b4f {height:2px; margin:0 1px;}

/***** generic main table styles *****/
table.main {
  background-color: #FFFFFF;
}
table.main .main_left, table.main .main_middle{
   vertical-align:top;
}

/***** footer *****/
table.footer {
  border:0;
  margin-top: 1em;
}
td.footer_left, td.footer_right {
  width: 0;
}
table.footer div.bmenu {
  text-align:center;
  margin-bottom: .3em;
}
table.footer tr td div.bmenu span {
   padding: 0 1em;
}
table.footer div.bmenu a {
  color: #FFFFFF;
  text-decoration:none;
}
table.footer div.bmenu a:hover {
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

/***** NOTE:  may not be necessary - login box and registration box *****/
div.left_nav {

}
div.left_nav span.b_rounded_box_body {
  background: #3815EB
}
div.left_nav div.bmenu {
  background-color: #3815EB;
  padding: .75em .5em;
  text-align: center;
  color:#FFFFFF;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.1em;
}
div.left_nav div.bmenu a {
  color:#FFFFFF;
  font-weight: bold;
}
div.login_box label {
  font-family: Arial, Helvetica, sans-serif;
  display:block;
}
div.login_box input {
  margin-bottom: .5em;
  font-size: 1.0em;
}
div.login_box img {
  padding-bottom: .3em;
  margin: 0;
}
div.login_box form {
  margin: 0;
  padding: 0;
}
div.register {
  padding: 1em;
  background-color: #FFF6A6;
  border: 4px solid #FFB20E;
  margin: .5em .5em .5em 0;
  font-family: Arial, Helvetica, sans-serif;
  font-size: 1.1em;
  text-align: center;
}
div.register a {
  color: #2A6D06;
  text-decoration:none;
}

/***** main content styling *****/
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
  padding: 1em .5em;
  text-align: center;
}
div.rides_counted p {
  width: 12em;
  font-family:Arial, Helvetica, sans-serif;
  font-size: 2.5em;
  font-weight:bold;
  text-align:center;
  margin: .2em 0 .2em 0;
  color: #FFFFFF;
}
div.support_freiker {
  background-color: #026EE6;
  border: #082A4E solid 4px;
  margin-top: .5em;
  font-family:Arial, Helvetica, sans-serif;
  font-size: .9em;
  color: #FFFFFF;
  padding: .3em;
  height=100%;
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

/***** new *****/
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
  padding: 1em;
}

/***** internal pages *****/

div.wiki {
  margin: .5em 1em 1em 1em;
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

/***** dontate form styling *****/
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

/****** Misc for internal pages *****/
div.in_the_news p
{
  margin-top: .5em;
}
table.results {
  margin-top: 1em;
}
div.results_chart {
  margin-top: 2em;
  margin-left: 5em;
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

/***** remove title *****/
^/bp/.* div.main_top div.title {
  display:none;
  height:0;
}

EOF

sub internal_site_css {
    return shift->SUPER::internal_site_css(@_) . $_SITE;
}

1;
