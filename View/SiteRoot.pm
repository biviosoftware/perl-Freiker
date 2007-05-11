# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Freiker::View::SiteRoot;
use strict;
use Bivio::Base 'Bivio::UI::View::SiteRoot';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub hm_donate {
    return shift->internal_body(DIV_prose(Prose(<<'EOF')));
<p>
Freiker, Inc. (EIN 56-2539016) is a 501(c)(3) non-profit whose main
source of funding is from a small company:
Link('bivio Software, Inc.', 'http://www.bivio.biz');
Your tax-deductible donation will help us expand this successful
program.
</p>
DIV_donate(Form(PayPalForm => Join([
    SPAN_money('$'),
    FormField('PayPalForm.amount', {class => 'money'}),
    FormButton('ok_button'),
])));
<p>
Or, if you prefer, please send a check to:
<blockquote class="address">
Freiker, Inc.<br />
2369 Spotswood Place<br />
Boulder, CO 80304-0994
</blockquote>
</p>
DIV_thanks('Thank you for supporting Freiker!');
EOF
}

sub hm_index {
    return shift->internal_body(DIV_prose(Prose(<<'EOF')));
Link(
    Image('freikometer', 'See the Freikometer movie'),
    '/m/freikometer.avi',
    'movie',
);
H3('Fried-o-whatsit?');
<p>
That's "Freikometer", and it adds a lot of fun to bike encouragement
programs.  Freiker's success is due to fantatical dedication to data.
Like many other bike programs, we started with punch cards.  The next
year we use barcodes and scanners.  2006-2007 is the year of the Freikometer:
an automatic device that counts riders and uploads the data securely to
freiker.org.  It's solar powered so you can put it right near the
bike racks at your school.
</p>
<p>
The Freikometer is currently under test at several
Link('Boulder Valley School District', 'http://www.bvsd.org');
schools.  The freikometers survived a very harsh winter -- for the
most part.  We're glad the winter's over, and they are operating very will in
our wet but warm spring.  We will be upgrading all Freikometers in the summer
of 2007 to operate better in extreme cold. We will be expanding outside the
Boulder area; it's a matter of time to prove out the technology, which so far
is going well.
</p>
<p>
The best way to understand how the Freikometer works is to see it in
action.  Link('View the movie (5mb).', '/m/freikometer.avi');
</p>
H3(Join([
'Freiker Doubles Ridership!',
Image('freiker-weather', 'Year on year comparison of Freikers vs. Weather',
    'graph'),
]));
<p>
Twice as many kids are riding to
Link('Crest View Elementary', 'http://schools.bvsd.org/crestview');
than were riding last year.  Why?  iPods.  It's that simple. Kids who ride
to Crest View (and other area schools) receive an iPod if they
ride their bikes 90% of the time to school.  At Crest View, that
means Freikers must ride 150 times this year. Last school year 12
hard-working Freikers completed this goal.
</p>
<p>
Freikers do not compete against each other for prizes.  There is no
best in class, school, or otherwise.  Every kid wins if they try.
Ride to school once, and you're a Freiker.  Ride to school the whole
week, and you are entered in a drawing to win
the SiteRoot('hm_prizes', {value => 'Green Gear'}); and $10.
That's an achievable goal for any kid, and it's the first step
towards a healthier, more self-reliant, more alert student.
</p>
EOF
}

sub hm_parents {
    return shift->internal_put_base_attr(
	title => 'For parents',
	body => Join([
	Tag('div', Prose(<<'EOF'), 'prose', {id => 'parents'}),
P(Link('Register your family here.', 'FAMILY_REGISTER'));
<p>
The Freiker Program encourages kids to ride their bikes to school.  The
program is
SiteRoot('hm_wheels', {value => 'run by volunteers'});
and supported with
SiteRoot('hm_sponsors', {value => 'donations from sponsors'});
as
well as parents.  Link('Please donate to Freiker!', 'SITE_DONATE');
</p>
H3('RFID tags');
<p>
To participate in the program, your child's helmet is marked with an
Radio Frequency Identifier (RFID) tag by a Freiker volunteer.
Every day your child must ride by the Freikometer
to be counted.  The Freikometer runs before and after school so if you are
late to school or are an afternoon kindergartner, don't worry, you'll be
counted.  The RFID tag does not identify your child.  This
is to help ensure you and your child's privacy.  The code is unique, which is
how our software knows your child has ridden that day.  We <b>do not require</b>
any information that would identify your child.
</p>
H3('Prizes');
<p>
Everybody can SiteRoot(hm_prizes => {value => 'win a prize'});.  Freiker is not a
competition between children, classes, or schools.  After ten rides, every
Freiker (program participant) is eligible for a prize.  At the end of the
year, there's a party for all Freikers, even if you have only ridden to
school one time!  You just need your Freiker helmet tag to get in.
</p>
<p>
Every Monday one child wins an extra prize called the
Green Gear along with $10 cash.  To be eligible for the Green Gear, a
child must ride every school day the prior week.  The Green Gear is
selected randomly from the children who rode the entire week.
</p>
<p>
Link('Parents must register', 'FAMILY_REGISTER'); with this website.
There's no charge, and we only require an email address, which helps
us avoid registrations by spambots and allows us to contact you when your
child wins a prize.
</p>
H3('Rides');
<p>
Your child must ride by the Freikometer in the morning or afternoon.  We
do our best to instruct your child, but it's up to parents to make sure
that they follow through.  Some small children need to be reminded, but
older kids get it right away.
</p>
<p>
Sometimes the Freikometer is broken, or it doesn't read an RFID tag properly.
In this case, you can login to the website and click on
the String(vs_text_as_prose('FAMILY_MANUAL_RIDE_FORM')); link.
</p>
H3('Cheating');
<p>
Each school's SiteRoot('hm_wheels'); decide what is cheating.  Some
schools include scooters.  Others don't allow them.  With an iPod at
stake, cheating is inevitable.  If your child is caught checking in with
the Freikometer, and she hasn't ridden to school that day, she will lose
all her rides up to that point.  Wheels audit from time to time, and it's
up to you to not let your child checkin without riding.  This is a guideline,
and you need to talk to your school's Wheels about what is and isn't allowed.
</p>
H3('Safety');
<p>
We are concerned about your child's safety.  Riding to school is a lot of fun,
and it is very safe.  The more kids that ride together, the more likely they
are to be seen.  Freiker encourages kids to ride safely.  We will supply
helmets to children who need and cannot afford them.  Your child must wear
a helmet to participate in the program.
</p>
<p>
B(q{Parents are responsible for their child's safety.});
Please teach your children about road safety.
We recommend you ride with your child until you are satisfied
your child can ride alone. There are many excellent resources that help
you understand bike safety, for example,
Link(Simple('KidsHealth&reg;'),
    'http://kidshealth.org/kid/watch/out/bike_safety.html');,
Link(Simple('BicycleSafe.com'), 'http://bicyclesafe.com/');,
Link('National Fire Prevention Association',
     'http://www.nfpa.org/riskwatch/parent_bike.html');,
and Link('Pedestrian and Bicycle Information Center',
    'http://www.bicyclinginfo.org/ee/ed_child_main.cfm');.
</p>
H3('Photos');
<p>
From time to time, we may take photographs of your child.  We may
put your child's picture on our website, in a brochure, or other
printed materials to show how much fun Freiker is.  If you do not
want your child's picture published, vs_wheel_contact();.
We understand and completely respect your desire
to maintain your family's privacy.
</p>
H3('Volunteers');
<p>
Your help would be greatly appreciated.  If you already have
a SiteRoot(hm_wheels => {value => 'wheel (lead volunteer)'});
at your school, just
go to your bike rack in the morning.  If you would like to bring
Freiker to your school, vs_gears_contact();, and we'll
get you a scanner, barcodes, and start up prizes.  If you are politically
inclined, please go to school board and/or city council meetings and
tell them about Freiker.  If you know how to write grants, we could
use your help, too.
</p>
H3('Donations');
<p>
We will gladly accept donations.
100% of individual donations goes towards prizes or other rewards.
Our program is entirely volunteer run, including the software and hardware
to run our website.  We need your help.
Link(B('Click here to learn how to donate to Freiker!'), 'SITE_DONATE');
It's tax-deductible!
</p>
H3('Feedback');
<p>
We encourage feedback so vs_gears_contact(); with your
questions, comments, and/or suggestions.
</p>
P(Link('Register your family here.', 'FAMILY_REGISTER'));
EOF
    ]));
}

sub hm_press {
    return shift->internal_put_base_attr(
	title => 'In the news',
	body => DIV_press(DL(Join([map((
	    DT(Join([
		"$_->[0] - ",
		SPAN_source(Link($_->[3], $_->[4])),
		" - $_->[5]",
	    ])),
	    DD(Link(B($_->[1]), $_->[2])),
	), [
	    '11/02/2006',
	    'Biking To School Becomes Popular Among Kids',
	    'http://www.thedenverchannel.com/video/10229138/detail.html',
	    'ABC News, Channel 7 Denver',
	    'http://www.thedenverchannel.com',
	    'TV (video stream)',
	], [
	    '08/04/2006',
	    'Freikometer Logs Student Bike Rides to School',
	    'http://bcbr.datajoe.com/app/ecom/pub_article_details.php?id=82403',
	    'Boulder County Business Report',
	    'http://www.bcbr.com',
	    'Article',
	], [
	    '06/08/2006',
	    'Kids at Crest View have been Biking to School in Record Numbers',
	    'http://www.kgnu.org/cgi-bin/programinfo.py?time=1149775200',
	    'KGNU Morning Magazine',
	    'http://www.kgnu.org',
	    'Radio (22 minutes into show)',
	], [
	    '05/06/2006',
	    'Freiker Bike Encouragement Program at Crest View Elementary School Celebrates Success - Freiker Receives Grant and Community Support',
	    '/hm/press/20060506',
	    'Boulder Valley School District',
	    'http://www.bvsd.org',
	    'Press Release',
	]),
    ]))));
}

sub hm_press_20060506 {
    return shift->internal_put_base_attr(
	title => '05/06/2006 - Freiker Receives Grant and Community Support',
	body => DIV_press(Prose(<<'EOF')),
<h3>News Release</h3>
<h3>Boulder Valley School District</h3>
<div>
<h3>For Immediate Release</h3>
May 26, 2006
</div>
<div>
<h3>Contacts:</h3>
Landon Hilliard<br />
<b>Transportation Department</b> - TO School Program<br />
Boulder Valley School District<br />
303-245-5931<br />
vs_email('landon.hilliard', 'bvsd.org');
</div>
<div>
Rob Nagler, President<br />
<b>Freiker, Inc</b><br />
303-417-0919 Ext.4<br />
vs_email('nagler');
</div>
<div>
<b>BVSD Communications</b><br />
303-245-5824
</div>
<div>
<b>Freiker Bike Encouragement Program at Crest View Elementary School
Celebrates Success - Freiker Receives Grant and Community Support</b>
</div>
<p>
BOULDER - Link(B('Freiker, Inc.'), '/');
a local non-profit will host a party for
student participants and parent volunteers to celebrate the wild success of the
cycling encouragement program this school year.  The event takes place
Link(B('Wednesday, June 7, 10:30&nbsp;a.m. - 1&nbsp;p.m.'),
'http://maps.google.com/maps?oi=map&q=1897+Sumac+80304');
</p>
<p>
The Freiker party will feature a presentation of "Extra Cool Prizes," the
dedication of new bike racks, and ice cream for all.  Recently, Freiker was
awarded a portion of just over $73K in grant money from the
Link('Colorado Safe Routes to School Program',
    'http://www.dot.state.co.us/BikePed/SafeRoutesToSchool.htm',
);
through the
Link('Colorado Department of Transportation (CDOT)',
    'http://www.dot.state.co.us',
);.
The grant will fund the expansion of the Freiker frequent biker
program to six BVSD schools through spring 2008.
</p>
<p>
Freiker (rhymes with "biker") has been a wild success at
Link('Crest View Elementary', 'http://schools.bvsd.org/crestview');.
More kids are riding their bikes to Crest View than ever before, and they are
riding more often.  The secret to Freiker's success is daily tracking and
weekly prizes.  Kids can track their rides and choose prizes on
Link('www.freiker.org', '/');.
</p>
<p>
Ned Levine, Crest View Elementary Principal, will be unveiling the much-needed
new bike racks.
</p>
<p>
"Our bike racks are overflowing.  Everybody at Crest View loves the Freiker
program and the extra encouragement it provides to students to bike to school,"
said Levine.
</p>
<p>
The Freiker party is scheduled for June 7 at
Crest View Elementary
Link('(view map)', 'http://maps.google.com/maps?oi=map&q=1897+Sumac+80304');
from 10:30&nbsp;a.m. - 1&nbsp;p.m.
Link('Wild Oats', 'http://www.wildoats.com');
and
Link('Hatton Creamery', 'http://www.hattoncreamery.com');
will supply lunch for the 150 kids
in the Freiker program at Crest View.  The kids will also receive cool prizes
donated by
Link('bivio Software, Inc.', 'http://www.bivio.biz');,
Link('Compass Bank', 'http://www.compassbank.com');,
Link('Dean Bikes', 'http://www.deanbikes.com');,
Link('Descente', 'http://www.descente.com');,
Link('Mirrycle', 'http://www.mirrycle.com');,
Link('University Bikes', 'http://www.ubikes.com');,
and Link('Vectra Bank', 'http://www.vectrabank.com');.
</p>                                                                            <p>
Like most encouragement programs, Freiker started with a volunteer-intensive
punch-card system.  In 2005-06, Freiker automated data collection through
optical barcode readers.  With this CDOT grant and generous support from
corporate sponsors such as Skyetek and bivio Software, daily tracking will be
fully automated with the development of the <b>Freikometer</b>,
a bike counting device
which is directly connected to
Link('freiker.org', '/');.
</p>
<p>
The Freikometer represents a huge step forward in bike/walk encouragement
programs.  With computers managing the repetitive and tedious tasks of ride
counting and prize tracking, volunteers are empowered to use their precious
time to encourage more children to bike or walk to school and to teach traffic
safety.
</p>
<p>
Freiker will also provide a support network for the volunteers who want to
trade advice.  Kids will come to Freiker.org to learn how to rank in their
class, grade, school, district, state, and country.
</p>
<p>
"Friendly competition managed by the Freikometer is a great way to get more
kids on bikes and walking to school," says Rob Nagler, president of the
non-profit Freiker program.
</p>
<p>
"Freiker empowers our wonderful volunteers to focus on what they love to do
most - help kids.  This is the first time we have applied for a district-wide
Safe Routes to School grant, and I'm pleased to say we received full funding to
be shared among six schools.  This is great news for walking and cycling
advocates here," said Landon Hilliard, BVSD Student Transportation Coordinator.
</p>
EOF
    );
}

sub hm_privacy {
    return shift->internal_put_base_attr(
	title => 'Privacy Statement',
	body => Join([
	    Tag('div', Prose(<<'EOF'), 'prose', {id => 'privacy'}),
<p>
This privacy statement was revised April 8, 2007.
</p>
<p>
Freiker, Inc. ("<dfn>Freiker</dfn>") respects your right to privacy.
We are committed to
protecting your privacy. Your continued use of our website and your
submission of any information to us indicate that you have read,
understand and agree to our Privacy Policy.
</p>
<h3>Information Collection</h3>
<p>
We receive and may keep information you gave us because you decided to register
on our website, or because you decided to
take part in Freiker or fill out any other form on our
website. This information may include your e-mail address, name, mailing
address, and phone number.
</p>
<p>
This information may also include any other personal information or
unique preference information you choose to provide us.
</p>
<h3>Automatic Information</h3>
<p>
We want you to be aware that certain tools exist to help us service and
recognize you. For your convenience, to help us personalize your experience
or better serve your needs, we may receive and store certain types of
information when you visit one of our websites. You may be familiar with
the term "cookies," which are unique alphanumeric identifiers. These cookies
are placed on your computer when your web browser accesses our websites.
We use this information to educate us on things such as how you navigate to
and around our website, product browsing, content accessing, and purchasing
data.
</p>
<p>
In order to verify your identity, cookies are required.
However, only an authentication code is stored in the cookie.
No personal information is stored.
</p>
<h3>Information Required by the Government</h3>
<p>
Freiker may be required to collect and submit certain information
required by the government, such as a completed IRS Form W-9. This
information, which may include your taxpayer identification number, will
not be used, shared, transferred, or sold for marketing purposes.
</p>
<h3>Sharing with Third Parties</h3>
<p>
We will share aggregated demographic information with our partners.
This is not linked to any personal information that
can identify any individual person. These companies do not retain, share,
store or use personally identifiable information for any secondary purposes.
</p>
<p>
We will cooperate with the appropriate legal authorities when presented
with a subpoena or other government order.
</p>
<h3>Site Security</h3>
<p>
This website takes every precaution to protect our users' information. When
you submit information via the website, your information is protected both
online and off-line.
</p>
<h3>Links to Other Sites</h3>
<p>
This website contains links to other sites. Please be aware that we
are not responsible for the privacy practices of such other sites. We
encourage our users to be aware when they leave our site and to read
the privacy statements of each and every website that collects personally
identifiable information. This privacy statement applies solely to
information collected by this website.
</p>
<h3>Surveys and Contests</h3>
<p>
From time-to-time our site may request information from users via surveys
or contests. Participation in these surveys or contests is completely
voluntary and the user therefore has a choice whether or not to disclose
this information. Information requested may include contact information
(such as name and address), and demographic information (such as zip code
or age). Contact information will be used to notify the winners and
award prizes. Survey information will be used for purposes of monitoring
or improving the use and satisfaction of this site.
</p>
<h3>Publicity</h3>
<p>
Except where prohibited, participation in Freiker constitutes consent
by the participant and participant's guardian or parent (in the case of minors)
to Freiker's use of your child's photograph for promotional
purposes in any media without further payment or consideration.
However, Freiker will publish a participant's photograph
without identifying information except the likeness of the participant
to ensure participant's privacy.
</p>
<h3>Choice/Opt-out</h3>
<p>
Our users are given the opportunity to opt-out of having their information
used for purposes not directly related to our site at the point where
we ask for the information.
</p>
<p>
Users who no longer wish to receive communications from us may opt-out
of receiving these communications by replying the communication
to unsubscribe in the subject line in the email, or
vs_gears_contact();.
</p>
<p>
Users of our site are always notified when their information is being
collected by any outside parties. We do this so our users can make an
informed choice as to whether they should proceed with services that
require an outside party, or not.
</p>
<h3>Notification of Changes</h3>
<p>
If we decide to change our privacy policy, we will prominently post those
changes so our users are always aware of what information we collect, how
we use it, and under circumstances, if any, we disclose it. If at any point
we decide to use personally identifiable information in a manner different
from that stated at the time it was collected, we will notify users by way
of an email. Users will have a choice as to whether or not we use their
information in this different manner. We will use information in accordance
with the privacy policy under which the information was collected.
</p>
<h3>Site Security</h3>
<p>
This website takes every precaution to protect our users' information. When
you submit information via the website, your information is protected both
online and off-line.
</p>
<h3>Offline Security</h3>
<p>
We also do everything in our power to protect user information off-line.
Only employees and contractors who need the information to perform a specific job
(for example, our customer service representatives) are granted
temporary access to personally identifiable information. All employees are
kept up-to-date on our security and privacy practices. Finally, the servers
that we store personally identifiable information on are kept in a
secure environment, inside a locked cabinet.
</p>
<p>
If you have any questions about the privacy or security of your data
on Freiker, vs_gears_contact();
or via postal mail at Freiker, Inc., 2369 Spotswood Place, Boulder, CO 80304.
</p>
EOF
    ]));
}

sub hm_prizes {
    return shift->internal_put_base_attr(
	title => 'Ride and win!',
	body => Join([
	vs_prose(<<'EOF'),
<p>
We have a great variety of prizes.  All prizes except the
SPAN_prize_rides('Green Gear'); are deducted from your ride
total.  We are working on prize management system, which will
show how many rides you may apply to prizes.  Prizes
will be ordered via your Family's account on this website, and picked up at
Link('Trail Kids', 'http://trail-kids.com/standard.php?id=79&pageID=2');
located at 2750 Glenwood Drive at 28th in North Boulder.
</p>
P(Link('Click here to donate prizes or money.', 'SITE_DONATE'));
<p>
Link(Image('green_gear', undef, {class => 'prize_right'}), 'http://www.resourcerevival.com');
Every Monday (or the first school day in the week), we award the Green Gear
to the top Freiker of the Week.  If several Freikers are tied, we choose one
at random.  The Freiker of the Week also wins $10.  Yes, TEN DOLLARS, just for
riding your bike to school every day the prior week.  This is an extra prize.
You get to use those same rides for any of the ride prizes below.  Special
thanks to Link('Resource Revival, Inc.', 'http://www.resourcerevival.com');
for supplying the gears and to
the Link('Boulder Bump Shop', 'http://www.boulderbumpshop.com'); for painting
them.
</p>
<p>
Link(Image('ipod_nano', undef, {class => 'prize_left'}), 'http://www.apple.com/ipodnano');
An iPod!  This is the piece de resistance for kids nowadays.  If you ride
90% of the year to school, you'll win one.  It's that simple -- well, not
really, but there are plenty of other prizes below.  This is just the
one everybody seems to want.  At Crest View, you have to ride
SPAN_prize_rides('150 times');, but schools which start Freiker part of the way
through the year will use a lower number of rides (90% of possible rides
during the partial year).
</p>
<p>
Link(Image('lance_poster', undef, {class => 'prize_right'}), 'http://www.grahamwatson.com');
Ooo La La! Link('Graham Watson', 'http://www.grahamwatson.com'); posters
of Lance Armstrong winning the 2005 Tour de France.  The color and
scenes are magnificent.  A great way to spice up any Freiker's bedroom
after only Tag(span => '20 rides', 'prize_rides');.
</p>
<p>
Link(Image('lance_calendar', undef, {class => 'prize_left'}), 'http://www.grahamwatson.com');
2007! Lance Armstrong calendars from
Link('Graham Watson', 'http://www.grahamwatson.com'); so you can
keep track of your Freiker rides, or your homework.  OK, scratch the homework
bit, you only need Tag(span => '40 rides', 'prize_rides'); for these
great looking calendars.
</p>
<p>
Link(Image('cateye_velo_5', undef, {class => 'prize_right'}), 'http://www.deanbikes.com');
Zoom! You can see how fast you are going with the Cateye Velo 5
Cyclocomputer, which was graciously donated by
Link('Dean Titanium Bicycles', 'http://www.deanbikes.com');
The cyclocomputer features an odometer set option,
pacer (average speed compared to current), velocity indicator,
auto start/stop, auto-power saving. Functions include current speed,
elapsed time, total distance, trip distance, average speed and
a clock (12/24hr).  It's yours after Tag(span => '50 rides', 'prize_rides');.
</p>
<p>
Link(Image('ubikes_water_bottle', undef, {class => 'prize_left'}), 'http://ubikes.com');
Slurp! Cool water bottles donated by
Link('University Bicycles', 'http://ubikes.com'); are just the thing
for hard-riding Freikers.  Stay hydrated when you ride.  Quench
your thirst with Tag(span => '10 rides', 'prize_rides');.
</p>
<p>
Link(Image('mirrycle_bells', undef, {class => 'prize_right'}), 'http://www.mirrycle.com');
Ring! We've got Jellibells, Candibells, and more types of bells than you
can imagine.  All of these bells were donated by
Link('Mirrycle Corporation', 'http://www.mirrycle.com');
maker of fine bells and mirrors.  You can make a racket after
just Tag(span => '10 rides', 'prize_rides');.
</p>
EOF
	vs_main_img('winners'),
    ]));
}

sub hm_sponsors {
    return shift->internal_put_base_attr(
	title => 'Support from our community',
	body => Join([
	    DIV_prose(Prose(<<'EOF'), 'prose', {id => 'gears'}),
<p>
Thanks for helping us out with Freiker.  Our goal is to help children
develop healthy transportion choices and habits through an incentive
program.  Kids earn credits towards prizes every time they ride their
bike to school.  Top freikers in a variety of categories (class,
grade, school, district, state, national) receive extra prizes.  The
better the prizes, the more riders we have.
</p>
<p>
You can sponsor us by giving us prizes or by donating money.  The prizes
need to be something elementary school kids would like.  Money goes a
long way, because we buy prizes in bulk, and merchants often give us
a discount.
</p>
<p>
If you would like donate prizes or money, vs_gears_contact();.
</p>
<div class="simple">
Link(Image('bivio', 'bivio Software, Inc.'), 'http://www.bivio.biz');
Link(Image('boulderbumpshop', 'Boulder Bump Shop'), 'http://www.boulderbumpshop.com');
Link(Image('bnjrt', 'Boulder Nordic Junior Racing Team'), 'http://www.bnjrt.com');
Link(Image('catacom', 'Catalyst Communication, Inc.'), 'http://www.catacom.com');
Link(Image('coloradoplastics', 'Colorado Plastic Products'), 'http://www.coloradoplastics.com');
Link(Image('colorlink', 'ColorLink, Inc.'), 'http://www.colorlink.com');
Link(Image('deanbikes', 'DEAN Titanium Bicycles, Inc.'), 'http://www.deanbikes.com');
Link(Image('faegre', 'Faegre & Benson LLP'), 'http://www.faegre.com');
Link(Image('grahamwatson', 'Graham Watson'), 'http://www.grahamwatson.com');
Link(Image('hirschmanndesign', 'Hirschmann Design'), 'http://www.hirschmann.com');
Link(Image('meltonconstruction', 'Melton Construction, Inc.'), 'http://www.meltonconstruction.com');
Link(Image('mirrycle', 'Mirrycle Corp.'), 'http://www.mirrycle.com');
Link(Image('resourcerevival', 'Resource Revival, Inc.'), 'http://www.resourcerevival.com');
Link(Image('saferoutesinfo', 'National Center for Safe Routes to School'), 'http://www.saferoutesinfo.org');
Link(Image('skyetek', 'Skyetek, Inc.'), 'http://www.skyetek.com');
Link(Image('sun', 'Sun Microsystems, Inc.'), 'http://www.sun.com');
Link(Image('trail-kids', 'Trail Kids'), 'http://www.trail-kids.com');
Link(Image('ubikes', 'University Bicycles'), 'http://www.ubikes.com');
</div>
EOF
#Link(Image('wildoats', 'Wild Oats Markets, Inc.'), 'http://www.wildoats.com');
    ]));
}

sub hm_wheels {
    return shift->internal_put_base_attr(
	title => 'Wheels roll around',
	body => Join([
	    vs_main_img('wheel'),
	    vs_prose(<<'EOF'),
<p>
Link('Register your school here.', 'FAMILY_REGISTER');
</p>
<p>
Wheels are our main contact with schools in our program.  We provide you
with barcodes and scanners.  We have found kids want to help.  They'll do
the scanning and sticking barcodes on the bikes.
</p>
<p>
What you need to do is
upload the barcodes daily (although some kids may be able to do this, too).
The software takes care of the rest.  You also have to hand out the
prizes, but that's a lot of fun.  Nothing like being in a sea
of smiling faces.
</p>
<p>
If you would like to learn more, vs_gears_contact();
</p>
<p>
Link('Register your school here.', 'FAMILY_REGISTER');
</p>
EOF
    ]));
}

1;
