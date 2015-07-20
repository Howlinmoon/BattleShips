#!/usr/bin/perl

############################################
##                                        ##
##                 WebBBS                 ##
##           by Darryl Burgdorf           ##
##                                        ##
##           Configuration File           ##
##                                        ##
############################################

## (1) Define the location of your files:

require "/home/www/cgi-bin/webbbs.pl";

$dir = "/home/www/game/messages";
$cgiurl = "http://www.bigorc.com/cgi-bin/bbs.pl";

## (2) Tailor the appearance and functionality of your BBS:

$bodyspec = "BGCOLOR=\"#000000\" TEXT=\"ffffff\"";
#$bodyspec = "BGCOLOR=\"#ffffff\" TEXT=\"00ff00\" BACKGROUND=\"/game_design/bigmo_bw.jpg\"";
$HeadLinesFile = "";
$HeaderFile = "/home/www/game/footer.html";
$FooterFile = "/home/www/game/footer.html";
$MessageHeaderFile = "";
$MessageFooterFile = "";

$DefaultType = "";
$DefaultTime = "";

$boardname = "Let's Play A Game!";

$InputColumns = 80;
$InputRows = 15;

$HourOffset = 0;

$ArchiveOnly = 0;
$AllowHTML = 1;
$AutoQuote = 1;
$SingleLineBreaks = 0;

$UseCookies = 1;
require "/home/www/cgi-bin/cookie.lib";

$UseAdmin = 1;

$Max_Days = 9900;
$Max_Messages = 50000;

$ArchiveDir = "";

## (3) Define your visitors' capabilities:

$AllowUserDeletion = 0;
$AllowEmailNotices = 1;
$AllowPreview = 1;

$AllowURLs = 1;
$AllowPics = 1;

$NaughtyWords = "";

## (4) Define your e-mail notification features:

$mailprog = '/usr/bin/sendmail';
$maillist_address = "orcus\@neo.rr.com";
$email_list = 1;

$HeaderOnly = 0;
$AdminEmail = 0;

&WebBBS;

## (5) If necessary, set up the WebAdverts configuration subroutine

sub insertadvert {
	require "/full/path/to/ads_display.pl";
	$adverts_dir = "/full/path/to/ads";
	$display_cgi = "http://foo.com/ads/ads.pl";
	$advertzone = $_[0];
	$ADVshown = 0;
	$ADVUseLocking = 1;
	$ADVWrapCounter = 0;
	if ($advertzone eq "ShowAll") { &ADVshowall; }
	else { &ADVdisplayad; }
}

