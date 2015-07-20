############################################
##                                        ##
##                 WebBBS                 ##
##           by Darryl Burgdorf           ##
##       (e-mail burgdorf@awsd.com)       ##
##                                        ##
##         last modified: 8/18/97         ##
##           copyright (c) 1997           ##
##                                        ##
##    latest version is available from    ##
##        http://awsd.com/scripts/        ##
##                                        ##
############################################

# COPYRIGHT NOTICE:
#
# Copyright 1997 Darryl C. Burgdorf.  All Rights Reserved.
#
# This program may be used and modified free of charge by anyone, so
# long as this copyright notice and the header above remain intact.  By
# using this program you agree to indemnify Darryl C. Burgdorf from any
# liability.
#
# Selling the code for this program without prior written consent is
# expressly forbidden.  Obtain permission before redistributing this
# program over the Internet or in any other medium.  In all cases
# copyright and header must remain intact.

# VERSION HISTORY:
#
# 2.24  08/17/97  Squashed bug in previous/next links
#                 Fixed "header only" function
# 2.23  08/16/97  Squashed subscription list add/delete bug
#                 Corrected new message count to ignore temp/deleted
# 2.22  08/09/97  Fixed typo bug in preview confirmation
#                 Allowed subscriptions to "archive only" boards
# 2.21  08/09/97  Added "harvester" option
#                 Improved "context awareness" of censoring routine
#                 Rewrote "not posted" message for better clarity
#                 Added "compressed listing" index option
#                 Corrected URL parsing to allow commas and ampersands
#                 Added IP address info (as comment tag) to messages
#                 Made "preview" capability optional
#                 Added ability to post directly from preview screen
#                 Allowed administrator to post to archive-only boards
#                 Added ability to define HEAD tag header info
#                 Restructured header/footer subroutines for simplicity
#                 Revised header/footer handling of WebAdverts inserts
#                 Fixed bug in various "selective" index displays
#                 Revised display of search results indexes
#                 Added ability to e-mail notices only to administrator
#                 Added "header only" e-mail notification option
#                 Simplified & sped up e-mail word-wrap function
# 2.20  07/11/97  Revised message displays to thread responses
#                 Added "trapping" of IP addresses in message files
#                 Added ability to preview messages before posting
#                 Added ability to "censor" naughty words in posts
#                 Made allowing user deletion of messages optional
#                 Made allowing e-mail notifications optional
#                 Made allowing of URL input optional
#                 Added optional ability to allow pics with messages
#                 Added optional headers & footers on admin pages
#                 Incorporated "reaper" script functionality
#                 Added configuration option for external digest script
#                 Improved handling of banner placements
#                 Improved "structure" of index & message pages
#                 Improved parsing of e-mail addresses for validity
#                   (Regex borrowed from Matt Wright)
#                 "Cleaned up" configuration variables & BBS setup
# 2.14  05/28/97  Allowed for parsing, display or purging of HTML
#                 Added support for WebAdverts banner displays
#                 Added optional headers & footers on message pages
#                 Allowed easy disabling of all e-mail functions
#                 Simplified word-wrap of quoted message text
#                 Added word-wrap to e-mail notifications
#                 Corrected style of password input boxes
#                 Finally fixed message sorting so it's numeric
#                 Fixed bug in message deletion with admin password
#                 Fixed bug in display of author search results
#                 A lot of minor "tweaks" and format alterations
# 2.13  04/06/97  Added $HourOffset
#                 Added $InputColumns and $InputRows
#                 Set $DefaultTime="archive" to index all posts
#                 Incorporated formerly-separate admin script
#                 Added passwords to allow deletions by authors
#                 Added "reversed threaded" listing option
#                 Added timestamp to avoid "constant" cookie updates
#                 Added number of new messages to welcome blurb
#                 Added "X of Y Messages Displayed" to index page
#                 Added "return to index" links to error messages
#                 "Optionalized" e-mail notification of responses
#                 Closed security hole allowing SSI in messages
#                 Fixed minor bug in file locking
#                 Miscellaneous minor "clean-up" revisions
# 2.12  02/26/97  Added "previous" and "next" message links
#                 Added file locking to prevent dup message IDs
#                 Added configurable default settings
#                 Corrected bug in "archive only" display options
# 2.11  02/14/97  Temporary fix for cookie domain bug
# 2.10  02/11/97  Added optional support for cookies
#                 Eliminated need for initial "setup" page
#                 Added "archive only" option
#                 Added "single line breaks" option
#                 Added ability to search by author's name
#                 Finally tracked down and squashed "new post" bug
# 2.01  02/02/97  Name changed from "WebBoard" to "WebBBS"
#                 Added automatic quoting of previous message
#                 Removed sometimes-problematic "location" call
#                 Eliminated redundant e-mail notifications
#                 Corrected bug with $name variable
# 2.00  01/19/97  Complete "from the ground up" rewrite
#                   (Major change: Use of dynamic page generation)
# 1.01  01/04/97  Added option to allow embedded HTML in messages
#                 Minor bug fixes and format alterations
# 1.00  12/22/96  Initial "public" release
#                   (Had been in use privately for months)

sub WebBBS {
	$version = "2.24";
	$UseLocking = 1;
	%MonthToNumber=
	  ('Jan','00','Feb','01','Mar','02',
	  'Apr','03','May','04','Jun','05',
	  'Jul','06','Aug','07','Sep','08',
	  'Oct','09','Nov','10','Dec','11');
	require "timelocal.pl";
	if ($UseCookies) {
		$Cookie_Exp_Date = "Fri, 31-Dec-2009 00:00:00 GMT";
		if ($cgiurl =~ m#^http://([\w-\.]+):?(\d*)/(.+)/#o) {
			$Cookie_Path = "/$3/";
		}
		&GetCompressedCookies($boardname);
	}
	unless ($InputColumns) { $InputColumns = 80; }
	if ($InputColumns < 25) { $InputColumns = 25; }
	unless ($InputRows) { $InputRows = 15; }
	if ($InputRows < 5) { $InputRows = 5; }
	$InputLength = int($InputColumns/2);
	&Parse_Form;
	&Get_Date;
	print "Content-type: text/html\n";
	if ($ENV{'QUERY_STRING'} =~ /read=(\d+)/i) {
		&DisplayMessage($1);
	}
	elsif ($ENV{'QUERY_STRING'} =~ /post/i) {
		&PostMessage;
	}
	elsif ($ENV{'QUERY_STRING'} =~ /addresslist/i) {
		&UpdateAddressList;
	}
	elsif ($ENV{'QUERY_STRING'} =~ /reconfigure/i) {
		&Reconfigure;
	}
	elsif ($ENV{'QUERY_STRING'} =~ /delete/i) {
		&Delete;
	}
	elsif ($ENV{'QUERY_STRING'} =~ /admin/i) {
		if ($UseAdmin) {
			$AdminDisplay=1;
		}
		&DisplayIndex;
	}
	elsif ($ENV{'QUERY_STRING'} =~ /newpass/i) {
		&newpass;
	}
	else {
		&DisplayIndex;
	}
}

sub Parse_Form {
	if ($NaughtyWords) {
		@naughtywords = split(/ /,$NaughtyWords);
	}
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
	@pairs = split(/&/, $buffer);
	foreach $pair (@pairs){
		($val1, $val2) = split(/=/, $pair);
		$val1 =~ tr/+/ /;
		$val1 =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		$val2 =~ tr/+/ /;
		$val2 =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
		unless (($AllowHTML > 1) && ($val1 eq "body")) {
			$val2 =~ s/<!--([^>]|\n)*-->/ /g;
		}
		if (($AllowHTML < 1) || ($val1 ne "body")) {
			$val2 =~ s/<([^>]|\n)*>/ /g;
		}
		unless (($AllowHTML eq "1") && ($val1 eq "body")) {
			$val2 =~ s/\&/\&amp\;/g;
			$val2 =~ s/"/\&quot\;/g;
			$val2 =~ s/</\&lt\;/g;
			$val2 =~ s/>/\&gt\;/g;
		}
		$val2 =~ s/\cM\n/<BR>/g;
		$val2 =~ s/\n\cM/<BR>/g;
		$val2 =~ s/\cM/<BR>/g;
		$val2 =~ s/\n/<BR>/g;
		$val2 =~ s/<BR>\s\s\s+/<BR><BR>/g;
		$val2 =~ s/<BR>\t/<BR><BR>/g;
		$val2 =~ s/\s+/ /g;
		$val2 =~ s/<BR>\s/<BR>/g;
		$val2 =~ s/\s<BR>/<BR>/g;
		$val2 =~ s/<BR><BR>/<P>/g;
		$val2 =~ s/<P><BR>/<P>/g;
		$val2 =~ s/<P>>/<P>&gt;/g;
		$val2 =~ s/<BR>>/<BR>&gt;/g;
		unless ($SingleLineBreaks) {
			$val2 =~ s/<BR>&gt;/<BRR>/g;
			$val2 =~ s/<BR>/ /g;
			$val2 =~ s/<BRR>/<BR>&gt;/g;
		}
		$val2 =~ s/\s+/ /g;
		$val2 =~ s/^\s+//g;
		$val2 =~ s/\s+$//g;
		foreach $naughtyword (@naughtywords) {
			$val2 =~ s/([\W\d])$naughtyword([\W\d])/$1#####$2/ig;
		}
		$val2 =~ s/<P>/\n<P>/g;
		$val2 =~ s/<BR>/\n<BR>/g;
		$val2 =~ s/<P>\n/\n/g;
		$val2 =~ s/<BR>\n/\n/g;
		if ($FORM{$val1}) {
			$FORM{$val1} = "$FORM{$val1}, $val2";
		}
		else {
			$FORM{$val1} = $val2;
		}
	}
}

sub DisplayMessage {
	$messagenumber = $1;
	opendir(MESSAGES,$dir) || &Error_File($dir);
	@messages = readdir(MESSAGES);
	@sortedmessages = sort {$a<=>$b} @messages;
	closedir(MESSAGES);
	foreach $message (@sortedmessages) {
		unless (($message =~ /\.tmp$/) || ($message == 0)) {
			if ($message < $messagenumber) {
				$prevmessage = $message;
			}
			elsif ($message > $messagenumber) {
				$nextmessage = $message;
				last;
			}
		}
	}
	open(FILE,"$dir/$messagenumber") || &Error_NoMessage;
	@message = <FILE>;
	close(FILE);
	foreach $line (@message) {
		if ($line =~ /^SUBJECT>(.*)/i) { $subject = $1; }
		elsif ($line =~ /^POSTER>(.*)/i) { $poster = $1; }
		elsif ($line =~ /^EMAIL>(.*)/i) { $email = $1; }
		elsif ($line =~ /^DATE>(.*)/i) { $date = $1; }
		elsif ($line =~ /^EMAILNOTICES>/i) { next; }
		elsif ($line =~ /^IP_ADDRESS>(.*)/i) { $ipaddress = $1; }
		elsif ($line =~ /^PASSWORD>(.*)/i) { $oldpassword = $1; }
		elsif ($line =~ /^PREVIOUS>(.*)/i) { $previous = $1; }
		elsif ($line =~ /^NEXT>(.*)/i) { $next = $1; }
		elsif ($line =~ /^IMAGE>(.*)/i) { $image_url = $1; }
		elsif ($line =~ /^LINKNAME>(.*)/i) { $linkname = $1; }
		elsif ($line =~ /^LINKURL>(.*)/i) { $linkurl = $1; }
		elsif (!$startup) {
			$startup = 1;
			&Header($subject,$MessageHeaderFile);
			print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
			print "$boardname</STRONG></BIG></BIG></BIG>\n";
			print "<P ALIGN=CENTER>[ <A HREF=\"#Responses\">";
			print "Read Responses</A> | ";
			unless ($ArchiveOnly) {
				print "<A HREF=\"#PostResponse\">";
				print "Post a New Response</A> | ";
			}
			print "<A HREF=\"$cgiurl\">";
			print "Return to the Index</A> ]\n";
			print "<BR>[ ";
			if ($prevmessage > 0) {
				$tracker = 1;
				print "<A HREF=\"$cgiurl?read=$prevmessage\">";
				print "Previous</A>";
			}
			if ($previous > 0) {
				if (-e "$dir/$previous") {
					if ($tracker > 0) { print " | "; }
					$tracker = 1;
					print "<A HREF=\"$cgiurl?";
					print "read=$previous\">";
					print "Previous in Thread</A>";
				}
			}
			if ($next) {
				@responses = split(/ /,$next);
				foreach $response (@responses) {
					if ((-e "$dir/$response")
					  && ($response >0)) {
						if ($tracker > 0) { print " | "; }
						$tracker = 1;
						print "<A HREF=\"$cgiurl?";
						print "read=$response\">";
						print "Next in Thread</A>";
						last;
					}
				}
			}
			if ($nextmessage > 0) {
				if ($tracker > 0) { print " | "; }
				print "<A HREF=\"$cgiurl?read=$nextmessage\">";
				print "Next</A>";
			}
			print " ]</P><HR>\n";
			print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
			print "$subject</STRONG></BIG></BIG></BIG>\n";
			print "<P ALIGN=CENTER><EM>Posted by <STRONG>";
			if ($email) {
				print "<A HREF=\"mailto:$email\">$poster</A>";
			}
			else { print "$poster"; }
			print "</STRONG> on <STRONG>$date</STRONG>";
			if (length($previous) > 25) {
				print ", in response to $previous.";
			}
			elsif ($previous > 0) {
				&GetMessageDesc($previous);
				if ($subject{$previous}) {
					print ", in response to ";
					print "<A HREF=\"$cgiurl?";
					print "read=$previous\">";
					print "$subject{$previous}</A>, ";
					print "posted by ";
					print "$poster{$previous} on ";
					print "$date{$previous}";
				}
			}
			print "</EM></P>\n";
			print "<!--$ipaddress-->\n";
			print $line;
		}
		else { print $line; }
	}
	print "</P>\n";
	if ($image_url) {
		print "<P ALIGN=CENTER>";
		print "<IMG SRC=\"$image_url\"></P>\n";
	}
	if ($linkurl) {
		print "<P ALIGN=CENTER>";
		print "<EM><A HREF=\"$linkurl\">";
		print "$linkname</A></EM></P>\n";
	}
	print "<A NAME=\"Responses\"><HR></A>";
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Responses</STRONG></BIG></BIG>\n";
	print "<P><UL>";
	$ListType = $Cookies{'listtype'};
	if (!$ListType) { $ListType = $DefaultType; }
	@responses = split(/ /,$next);
	$responsecount = 0;
	if ($ListType eq "Chronologically") {
		@sortedresponses = reverse(@responses);
		foreach $response (@sortedresponses) {
			&GetMessageDesc($response);
			if ($subject{$response}) {
				&PrintMessageDesc($response);
				$responsecount ++;
			}
		}
	}
	else {
		foreach $response (@responses) {
			&GetMessageDesc($response);
			if ($subject{$response}) {
				&ThreadList($response);
				$responsecount ++;
			}
		}
	}
	if ($responsecount eq 0) {
		print "(No responses to this message have been posted.)";
	}
	print "</UL></P>\n";
	unless ($ArchiveOnly) {
		print "<A NAME=\"PostResponse\"><HR></A>";
		print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
		print "Post a New Response</STRONG></BIG></BIG>\n";
		&Print_Form($messagenumber);
	}
	if ($AllowUserDeletion) {
		print "<HR><P><CENTER>\n",
		  "<FORM METHOD=POST ACTION=\"$cgiurl?delete\">\n",
		  "<INPUT TYPE=HIDDEN NAME=\"password\" ",
		  "VALUE=\"$oldpassword\">\n",
		  "<INPUT TYPE=HIDDEN NAME=\"message\" ",
		  "VALUE=\"$messagenumber\">\n",
		  "<INPUT TYPE=SUBMIT VALUE=\"Delete Message\"> ",
		  "Password: <INPUT TYPE=PASSWORD NAME=\"newpassword\" ",
		  "SIZE=15>\n</FORM></CENTER></P>\n";
	}
	&Footer($MessageFooterFile,"credits");
}

sub Delete {
	$PassCheck = 0;
	unless ($FORM{'newpassword'}) { &Error_Password; }
	$newpassword = crypt($FORM{'newpassword'},aa);
	if ($FORM{'password'}) {
		if ($newpassword eq $FORM{'password'}) {
			$PassCheck = 1;
		}
	}
	unless ($PassCheck == 1) {
		if (!$UseAdmin) {
			&Error_Password;
		}
		open (PASSWORD, "$dir/password.txt");
		$password = <PASSWORD>;
		close (PASSWORD);
		chop ($password) if ($password =~ /\n$/);
		if (!$password) { &newpass; }
		unless ($newpassword eq $password) { &Error_Password; }
	}
	@messages = split(/, /,$FORM{'message'});
	foreach $message (@messages) { unlink "$dir/$message"; }
	&Header("Message(s) Deleted!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>Your Message(s) ",
	  "Have Been Deleted!</STRONG></BIG></BIG>\n",
	  "<P>The designated message(s) are no longer on the board. ",
	  "If you have any questions, please send a note to ",
	  "<A HREF=\"mailto:$maillist_address\">",
	  "$maillist_address</A>. Thanks!</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Error_Password {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Invalid Password!</STRONG></BIG></BIG>\n";
	print "<P ALIGN=CENTER>Either your password was incorrect ";
	print "or no password was entered!</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub GetMessageDesc {
	open(FILE,"$dir/$_[0]");
	@lines = <FILE>;
	close(FILE);
	foreach $line (@lines) {
		if ($line =~ /^SUBJECT>(.*)/i) {
			$subject{$_[0]} = $1;
		}
		elsif ($line =~ /^POSTER>(.*)/i) {
			$poster{$_[0]} = $1;
		}
		elsif ($line =~ /^DATE>(.*)/i) {
			$date{$_[0]} = $1;
		}
		elsif ($line =~ /^PREVIOUS>(.*)/i) {
			$previous{$_[0]} = $1;
		}
		elsif ($line =~ /^NEXT>(.*)/i) {
			$next{$_[0]} = $1; last;
		}
	}
}

sub PrintMessageDesc {
	print "<LI>";
	if ($AdminDisplay) {
		print "<INPUT TYPE=CHECKBOX ";
		print "NAME=\"message\" VALUE=\"$_[0]\"> ";
	}
	print "<STRONG>";
	if ($Cookies{'lastmessage'}
	  && ($Cookies{'lastmessage'} < $_[0])) {
		print "<EM>NEW:</EM> ";
	}
	print "<A HREF=\"$cgiurl?read=$_[0]\">";
	print "$subject{$_[0]}</A></STRONG><BR>";
	print "$poster{$_[0]} -- <EM>$date{$_[0]}</EM>\n";
}

sub Print_Form {
	print "<P><FORM METHOD=POST ACTION=\"$cgiurl?post\">\n";
	if ($ArchiveOnly) {
		print "<P><CENTER><STRONG>Password:</STRONG> ",
		  "<INPUT TYPE=PASSWORD NAME=\"newpassword\" ",
		  "SIZE=30></CENTER>\n";
	}
	if ($_[0]) {
		print "<INPUT TYPE=HIDDEN NAME=\"followup\" ";
		print "VALUE=\"$_[0]\">\n";
	}
	print "<P><CENTER><TABLE><TR>\n";
	print "<TD ALIGN=RIGHT><P><STRONG>Your Name:</STRONG>";
	print "</TD><TD><INPUT TYPE=TEXT NAME=\"name\" SIZE=$InputLength";
	if ($Cookies{'name'}) {
		print " VALUE=\"$Cookies{'name'}\"";
	}
	print "></TD></TR><TR>\n";
	print "<TD ALIGN=RIGHT><P><STRONG>E-Mail Address:</STRONG>";
	print "</TD><TD><INPUT TYPE=TEXT NAME=\"email\" ";
	print "SIZE=$InputLength";
	if ($Cookies{'email'}) {
		print " VALUE=\"$Cookies{'email'}\"";
	}
	print "></TD></TR><TR>\n";
	print "<TD ALIGN=RIGHT><P><STRONG>Subject:</STRONG>";
	print "</TD><TD><INPUT TYPE=TEXT NAME=\"subject\" ";
	print "SIZE=$InputLength";
	if ($_[0]) {
		print " VALUE=\"";
		unless ($subject =~ /^Re:/) { print "Re: "; }
		print "$subject\"";
	}
	print "></TD></TR><TR>\n";
	print "<TD COLSPAN=2 ALIGN=CENTER>";
	print "<P><STRONG>Message:</STRONG>";
	print "<BR><TEXTAREA COLS=$InputColumns ROWS=$InputRows ";
	print "NAME=\"body\" WRAP=VIRTUAL>\n";
	if ($_[0] && $AutoQuote) {
		$quotedtext = "";
		foreach $line (@message) {
			unless (($line =~ /^SUBJECT>/i)
			  || ($line =~ /^POSTER>/i)
			  || ($line =~ /^EMAIL>/i)
			  || ($line =~ /^DATE>/i)
			  || ($line =~ /^EMAILNOTICES>/i)
			  || ($line =~ /^IP_ADDRESS>/i)
			  || ($line =~ /^PASSWORD>/i)
			  || ($line =~ /^PREVIOUS>/i)
			  || ($line =~ /^NEXT>/i)
			  || ($line =~ /^IMAGE>/i)
			  || ($line =~ /^LINKNAME>/i)
			  || ($line =~ /^LINKURL>/i)
			  || ($line =~ /^<([^>])*>&gt;/i)
			  || ($line =~ /^<([^>])*>>/i)
			  || (length($line) < 2)) {
				$quotedtext = $quotedtext.$line;
			}
		}
		$quotedtext =~ s/\n/ /g;
		$quotedtext =~ s/<P>/\n\n\&gt\; /g;
		$quotedtext =~ s/<BR>/\n\&gt\; /g;
		$quotedtext =~ s/<([^>]|\n)*>/ /g;
		$quotedtext =~ s/\& /\&amp\; /g;
		$quotedtext =~ s/"/\&quot\;/g;
		$quotedtext =~ s/</\&lt\;/g;
		$quotedtext =~ s/>/\&gt\;/g;
		$length = length($quotedtext)-1;
		$wrapcount = 0;
		foreach $key (0..$length) {
			$char = substr($quotedtext,$key,1);
			$wrapcount++;
			if (($wrapcount > ($InputColumns-15))
			  && ($char eq " ")) {
				$char = "\n&gt; ";
			}
			print "$char";
			if ($char =~ /\n/) {
				$wrapcount = 0;
			}
		}
		print "\n";
	}
	print "</TEXTAREA></TD></TR><TR>\n";
	if ($AllowURLs) {
		print "<TD COLSPAN=2 ALIGN=CENTER><HR WIDTH=50%>",
		  "<P><SMALL>If you'd like to include ",
		  "a link to another page with your message,",
		  "<BR>please provide both the URL address ",
		  "and the title of the page:</SMALL>",
		  "</TD></TR><TR>\n",
		  "<TD ALIGN=RIGHT><P><STRONG>Optional Link ",
		  "URL:</STRONG></TD><TD><INPUT TYPE=TEXT ",
		  "NAME=\"url\" SIZE=$InputLength VALUE=\"http://\">",
		  "</TD></TR><TR>\n",
		  "<TD ALIGN=RIGHT><P><STRONG>Optional Link ",
		  "Title:</STRONG></TD><TD><INPUT TYPE=TEXT ",
		  "NAME=\"url_title\" SIZE=$InputLength></TD></TR><TR>\n";
	}
	if ($AllowPics) {
		print "<TD COLSPAN=2 ALIGN=CENTER><HR WIDTH=50%>",
		  "<P><SMALL>If you'd like to include ",
		  "an image (picture) with your message,",
		  "<BR>please provide the URL address ",
		  "of the image file:</SMALL>",
		  "</TD></TR><TR>\n",
		  "<TD ALIGN=RIGHT><P><STRONG>Optional Image ",
		  "URL:</STRONG></TD><TD><INPUT TYPE=TEXT ",
		  "NAME=\"imageurl\" SIZE=$InputLength VALUE=\"http://\">",
		  "</TD></TR><TR>\n";
	}
	if ($AllowUserDeletion) {
		print "<TD COLSPAN=2 ALIGN=CENTER><HR WIDTH=50%>",
		  "<P><SMALL>If you'd like to have the option ",
		  "of deleting your post later, <BR>please provide ",
		  "a password (CASE SENSITIVE!):</SMALL>",
		  "</TD></TR><TR>\n",
		  "<TD ALIGN=RIGHT><P><STRONG>Password:</STRONG>",
		  "</TD><TD><INPUT TYPE=PASSWORD NAME=\"password\" ",
		  "SIZE=$InputLength></TD></TR><TR>\n";
	}
	if ($mailprog && $AllowEmailNotices) {
		print "<TD COLSPAN=2 ALIGN=CENTER><HR WIDTH=50%>";
		print "<P><SMALL>If you'd like e-mail notification ";
		print "of responses, please check this box:</SMALL> ";
		print "<INPUT TYPE=CHECKBOX NAME=\"wantnotice\"";
		unless ($Cookies{'wantnotice'} eq "no") {
			print " CHECKED";
		}
		print " VALUE=\"yes\"></TD></TR><TR>\n";
	}
	print "<TH COLSPAN=2><HR WIDTH=50%><P>";
	if ($AllowPreview) {
		print "<INPUT TYPE=SUBMIT NAME=\"Preview\" ";
		print "VALUE=\"Preview Message\"> ";
	}
	print "<INPUT TYPE=SUBMIT NAME=\"Post\" ";
	print "VALUE=\"Post Message\"></TH>";
	print "</TR></TABLE></CENTER></P></FORM>\n";
}

sub newpass {
	if (!$UseAdmin) {
		&DisplayIndex;
	}
	$newpassword = crypt($FORM{'newpassword'},aa);
	open (PASSWORD, "$dir/password.txt");
	$password = <PASSWORD>;
	close (PASSWORD);
	chop ($password) if ($password =~ /\n$/);
	if (!$password) {
		unless ($FORM{'changeto'}) {
			$FORM{'changeto'} = $FORM{'newpassword'};
		}
	}
	else {
		unless ($newpassword eq $password) { &Error_Password; }
	}
	$newpassword = crypt($FORM{'changeto'},aa);
	open (PASSWORD, ">$dir/password.txt")
	  || &Error_File("$dir/password.txt");
	$lockerror = &LockFile(PASSWORD);
	if ($lockerror) {
		close (PASSWORD);
		&Header("Password Not Changed",$MessageHeaderFile);
		print "<P ALIGN=CENTER>The script was unable to access ";
		print "the &quot;password.txt&quot; file.</P>\n";
		&Footer($MessageFooterFile,"return");
	}
	print PASSWORD "$newpassword";
	&UnlockFile(PASSWORD);
	close (PASSWORD);
	&Header("Password Changed",$MessageHeaderFile);
	print "<P ALIGN=CENTER>The new administrative password is ";
	print "<STRONG>$FORM{'changeto'}</STRONG>.</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub DisplayIndex {
	opendir(MESSAGES,$dir) || &Error_File($dir);
	@messages = readdir(MESSAGES);
	closedir(MESSAGES);
	@sortedmessages = sort {$a<=>$b} @messages;
	$TotalMessages = @sortedmessages;
	$DisplayedMessages = 0;
	$lastmessage = 0;
	foreach $message (@sortedmessages) {
		if (($message =~ /\.tmp$/) || ($message == 0)) {
			$TotalMessages --;
		}
		else {
			if ($message > $lastmessage) {
				$lastmessage = $message;
			}
		}
	}
	if ($UseCookies) {
		if (($FORM{'ListCriteria'} eq "Recent")
		  && ($FORM{'KeySearch'} eq "No")) {
			$listtype = $FORM{'ListType'};
			$listtime = $FORM{'ListTime'};
		}
		if (!($FORM{'ListType'})) {
			$FORM{'ListType'} = $Cookies{'listtype'};
		}
		if (!($FORM{'ListTime'})) {
			$FORM{'ListTime'} = $Cookies{'listtime'};
		}
		&Send_Cookie;
	}
	if (!($FORM{'ListType'})) { $FORM{'ListType'} = $DefaultType; }
	if (!($FORM{'ListTime'})) { $FORM{'ListTime'} = $DefaultTime; }
	&Header("$boardname Message Index",$HeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
	print "$boardname</STRONG></BIG></BIG></BIG>\n";
	print "<P ALIGN=CENTER>[ ";
	unless ($ArchiveOnly && !$AdminDisplay) {
		print "<A HREF=\"#PostMessage\">Post ";
		print "a New Message</A> | ";
	}
	if ($mailprog && $email_list) {
		print "<A HREF=\"#Subscribe\">Subscribe</A> | ";
	}
	print "<A HREF=\"$cgiurl?reconfigure\">Search / ";
	print "Personalize Display</A> ]</P>\n";
	unless ($FORM{'KeySearch'}) {
		$FORM{'KeySearch'} = "No";
	}
	if ($FORM{'KeySearch'} ne "No") {
		$FORM{'ListType'} = "Chronologically";
		print "<P ALIGN=CENTER><STRONG>";
		print "Search Results</STRONG></P>\n";
	}
	elsif ($Cookies{'lastvisit'}) {
		print "<P ALIGN=CENTER><STRONG>Welcome back";
		if ($Cookies{'name'}) { print ", $Cookies{'name'}"; }
		print "!<EM><BR>Your last visit began ";
		print "on $Cookies{'lastvisit'}</EM>\n";
		if ($Cookies{'lastmessage'} < $lastmessage) {
			$NewCount = 0;
			$startcount = $Cookies{'lastmessage'}+1;
			foreach $messagecount ($startcount..$lastmessage) {
				if (-e "$dir/$messagecount") { $NewCount++; }
			}
			print "<BR>Since then, $NewCount new message";
			if ($NewCount > 1) { print "s have"; }
			else { print " has"; }
		}
		else {
			print "<BR>Since then, no new messages have";
		}
		print " been posted!</STRONG></P>\n";
	}
	elsif ($Cookies{'lastmessage'}) {
		print "<P ALIGN=CENTER><STRONG>Welcome";
		if ($Cookies{'name'}) { print ", $Cookies{'name'}"; }
		print "!\n";
		if ($Cookies{'lastmessage'} < $lastmessage) {
			$NewCount = $lastmessage - $Cookies{'lastmessage'};
			print "<BR>$NewCount new message";
			if ($NewCount > 1) { print "s have"; }
			else { print " has"; }
			print " been posted!";
		}
		print "</STRONG></P>\n";
	}
	else {
		print "<P ALIGN=CENTER><STRONG>";
		print "Welcome!</STRONG></P>\n";
	}
	print "<HR>\n";
	if ($AdminDisplay) {
		print "<P ALIGN=CENTER><BIG><BIG><STRONG>",
		  "<EM>Administrative Display</EM></STRONG></BIG></BIG>\n",
		  "<P><BLOCKQUOTE><EM>From this display, ",
		  "you have the option to delete any or all ",
		  "messages. Simply select those you wish to delete, ",
		  "then press the &quot;Delete Messages&quot; button.",
		  "</EM></BLOCKQUOTE>\n",
		  "<FORM METHOD=POST ACTION=\"$cgiurl?delete\">\n",
		  "<P><CENTER><STRONG>Password:</STRONG> ",
		  "<INPUT TYPE=PASSWORD NAME=\"newpassword\" ",
		  "SIZE=30></CENTER><HR>\n";
		$FORM{'ListTime'} = "Archive";
	}
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Message Index</STRONG></BIG></BIG>\n";
	if ($FORM{'ListCriteria'} eq "Archive") {
		print "<P ALIGN=CENTER>Messages Posted or Last Modified ";
		$starttime =
		  $FORM{'StartYear'}.$MonthToNumber{$FORM{'StartMonth'}};
		$endtime =
		  $FORM{'EndYear'}.$MonthToNumber{$FORM{'EndMonth'}};
		if ($endtime < $starttime) {
			print "Between $FORM{'EndMonth'} $FORM{'EndYear'} ";
			print "and $FORM{'StartMonth'} $FORM{'StartYear'}\n";
			$StartYear = $FORM{'EndYear'}-1900;
			$EndYear = $FORM{'StartYear'}-1900;
			$StartMonth = $MonthToNumber{$FORM{'EndMonth'}};
			$EndMonth = $MonthToNumber{$FORM{'StartMonth'}}+1;
		}
		else {
			if ($starttime eq $endtime) {
				print "During $FORM{'StartMonth'} ";
				print "$FORM{'StartYear'}\n";
			}
			else {
				print "Between $FORM{'StartMonth'} ";
				print "$FORM{'StartYear'} ";
				print "and $FORM{'EndMonth'} ";
				print "$FORM{'EndYear'}\n";
			}
			$StartYear = $FORM{'StartYear'}-1900;
			$EndYear = $FORM{'EndYear'}-1900;
			$StartMonth = $MonthToNumber{$FORM{'StartMonth'}};
			$EndMonth = $MonthToNumber{$FORM{'EndMonth'}}+1;
		}
		if ($EndMonth > 11) {
			$EndMonth = 0; $EndYear = $EndYear+1;
		}
		$startday = &timelocal(0,0,0,1,$StartMonth,$StartYear);
		$endday = &timelocal(0,0,0,1,$EndMonth,$EndYear);
		$startday = (($time-$startday)/86400);
		$endday = (($time-$endday)/86400);
	}
	else {
		$endday = -1;
		unless ($FORM{'ListTime'}) { $FORM{'ListTime'} = "Week"; }
		if ($FORM{'ListTime'} eq "Day") { $startday = 1; }
		elsif ($FORM{'ListTime'} eq "Two Days") { $startday = 2; }
		elsif ($FORM{'ListTime'} eq "Week") { $startday = 7; }
		elsif ($FORM{'ListTime'} eq "Two Weeks") { $startday = 14; }
		elsif ($FORM{'ListTime'} eq "Month") { $startday = 30; }
		else { $startday = 10000; }
		if ($ArchiveOnly || ($startday eq 10000)) {
			if ($FORM{'KeySearch'} eq "No") {
				print "<P ALIGN=CENTER>All Messages\n";
			}
			else {
				print "<P ALIGN=CENTER>Messages of Any Age\n";
			}
		}
		else {
			print "<P ALIGN=CENTER>Messages Posted or Modified ";
			print "Within the Last $FORM{'ListTime'}\n";
		}
	}
	if ($FORM{'KeySearch'} eq "Yes") {
		$FORM{'Keywords'} =~ s/\W/ /g;
		@keywords = split(/\s+/, $FORM{'Keywords'});
		print "<P ALIGN=CENTER>Containing ";
		print "<STRONG>$FORM{'Boolean'}</STRONG> ";
		print "of the Keywords:<BR>";
		foreach $keyword (@keywords) {
			print "<STRONG>$keyword</STRONG>";
			$i++;
			if (length($keyword) < 3) { print " (ignored)"; }
			if (!($i == @keywords)) { print ", "; }
			else { print "\n"; }
		}
		foreach $message (@sortedmessages) {
			open (FILE,"$dir/$message");
			@LINES = <FILE>;
			close (FILE);
			$string = join(' ',@LINES);
			$string =~ s/\n//g;
			$value = 0;
			if ($FORM{'Boolean'} eq 'All') {
				foreach $term (@keywords) {
					unless (length($term) < 3) {
						$test = ($string =~ s/$term//ig);
						if ($test < 1) {
							$value = 0;
							last;
						}
						else {
							$value = $value+$test;
						}
					}
				}
			}
			elsif ($FORM{'Boolean'} eq 'Any') {
				foreach $term (@keywords) {
					unless (length($term) < 3) {
						$test = ($string =~ s/$term//ig);
						$value = $value+$test;
					}
				}
			}
			if ($value > 0) {
				push (@keywordmatches, $message);
			}
			else {
				$DontUse{$message} = 1;
			}
		}
		@sortedmessages = @keywordmatches;
	}
	elsif ($FORM{'KeySearch'} eq "Author") {
		print "<P ALIGN=CENTER>Posted By ";
		print "<STRONG>&quot;$FORM{'Author'}&quot;</STRONG>\n";
		foreach $message (@sortedmessages) {
			$value = 0;
			&GetMessageDesc($message);
			$subject{$message} = "";
			if ($poster{$message} =~ /$FORM{'Author'}/i) {
				$value = 1;
			}
			if ($value > 0) {
				push (@keywordmatches, $message);
			}
			else {
				$DontUse{$message} = 1;
			}
		}
		@sortedmessages = @keywordmatches;
	}
	foreach $message (@sortedmessages) {
		&GetMessageDesc($message);
		if ($message =~ /\.tmp$/) {
			$DontUse{$message} = 1;
		}
		elsif (((-M "$dir/$message") <= $startday)
		  && ((-M "$dir/$message") > $endday)) {
			if ($subject{$message}) {
				$DisplayedMessages ++;
			}
		}
		else {
			$DontUse{$message} = 1;
		}
	}
	print "<P ALIGN=CENTER><EM>";
	unless ($FORM{'ListType'}) {
		$FORM{'ListType'} = "Chronologically";
	}
	unless ($FORM{'ListType'} eq "Compressed") {
		print "$DisplayedMessages of ";
		print "$TotalMessages Messages Displayed<BR>";
	}
	if ($FORM{'KeySearch'} eq "No") {
		if ($FORM{'ListType'} eq "Chronologically") {
			print "(Chronological Listing)";
		}
		elsif ($FORM{'ListType'} eq "Compressed") {
			print "(Compressed &quot;Threads Only&quot; Listing)";
		}
		elsif ($FORM{'ListType'} eq "By Threads, Reversed") {
			print "(Reversed Threaded Listing)";
		}
		else { print "(Threaded Listing)"; }
	}
	print "</EM></P>\n";
	$messagecount = 0;
	print "<P><UL>\n";
	if ($FORM{'ListType'} eq "Chronologically") {
		@messages = reverse(@sortedmessages);
		foreach $message (@messages) {
			if ($subject{$message} && !$DontUse{$message}) {
				&PrintMessageDesc($message);
				$messagecount ++;
			}
		}
	}
	elsif ($FORM{'ListType'} eq "Compressed") {
		undef (@messages);
		foreach $message (@sortedmessages) {
			if ($subject{$message} && !$already{$message}) {
				$respcount = -1;
				$showthread = 0;
				$newcount = 0;
				if ($Cookies{'lastmessage'}
				  && ($Cookies{'lastmessage'} < $message)) {
					$newcount--;
				}
				&CompressList($message);
				if ($showthread > 0) {
					push (@messages,$message);
					$messagecount ++;
					$respcount{$message} = $respcount;
					$newcount{$message} = $newcount;
				}
			}
		}
		@sortedmessages = reverse(@messages);
		foreach $message (@sortedmessages) {
			&PrintMessageDesc($message);
			print "<BR><STRONG>$respcount{$message} response";
			unless ($respcount{$message} == 1) {
				print "s";
			}
			if ($newcount{$message} > 0) {
				print " ($newcount{$message} new)";
			}
			print "</STRONG>\n";
		}
	}
	elsif ($FORM{'ListType'} eq "By Threads") {
		foreach $message (@sortedmessages) {
			if ($subject{$message} && !$already{$message}
			  && !$DontUse{$message}) {
				&ThreadList($message);
				$messagecount ++;
			}
		}
	}
	else {
		@reversedmessages = reverse(@sortedmessages);
		foreach $message (@reversedmessages) {
			if ($subject{$message} && !$already{$message}
			  && !$DontUse{$message}) {
				unless ($subject{$previous{$message}}
				  && !$DontUse{$previous{$message}}) {
					&ThreadList($message);
					$messagecount ++;
				}
			}
		}
	}
	print "</UL></P>\n";
	if ($messagecount < 1) {
		print "<P ALIGN=CENTER><STRONG>No messages ";
		print "matched your search criteria! ";
		print "Please try again....</STRONG></P>\n";
	}
	if ($AdminDisplay) {
		print "<P><CENTER><INPUT TYPE=SUBMIT VALUE=\"Delete ",
		  "Messages\"></CENTER></P></FORM>\n",
		  "<HR><FORM METHOD=POST ACTION=\"$cgiurl?newpass\">\n",
		  "<P ALIGN=CENTER><STRONG>Old Password:</STRONG> ",
		  "<INPUT TYPE=TEXT NAME=\"newpassword\" SIZE=30>\n",
		  "<BR><STRONG>New Password:</STRONG> ",
		  "<INPUT TYPE=TEXT NAME=\"changeto\" SIZE=30>\n",
		  "<P><CENTER><INPUT TYPE=SUBMIT VALUE=\"Change ",
		  "Administrative Password\"></CENTER></P></FORM>\n";
	}
	unless ($ArchiveOnly && !$AdminDisplay) {
		print "<A NAME=\"PostMessage\"><HR></A>";
		print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
		print "Post a New Message</STRONG></BIG></BIG>\n";
		&Print_Form;
	}
	if ($mailprog && $email_list) {
		print "<A NAME=\"Subscribe\"><HR></A>",
		  "<P ALIGN=CENTER><BIG><BIG><STRONG>",
		  "Subscribe</STRONG></BIG></BIG>\n",
		  "<P ALIGN=CENTER><EM>If you'd like to, ",
		  "you can receive ";
		if ($email_list == 1) {
			print "automatic e-mail ",
			  "notification of new posts!\n";
		}
		else {
			print "regular e-mail digests ",
			  "of all new posts!\n";
		}
		print "<BR>Simply provide your ",
		  "e-mail address below!</EM>\n",
		  "<FORM METHOD=POST ",
		  "ACTION=\"$cgiurl?addresslist\">\n",
		  "<P><CENTER>Your E-Mail Address: ",
		  "<INPUT TYPE=TEXT ",
		  "NAME=\"email\" SIZE=30";
		if ($Cookies{'email'}) {
			print " VALUE=\"$Cookies{'email'}\"";
		}
		print "> <INPUT TYPE=SUBMIT ",
		  "VALUE=\"Send Address\">\n",
		  "<BR><INPUT TYPE=RADIO NAME=\"action\" ",
		  "VALUE=\"add\" CHECKED> Add Address ",
		  "to List <INPUT TYPE=RADIO ",
		  "NAME=\"action\" VALUE=\"delete\"> ",
		  "Delete Address from List",
		  "</CENTER></P></FORM>\n";
	}
	&Footer($FooterFile,"credits");
}

sub CompressList {
	local(@threadresponses);
	$respcount++;
	unless ($DontUse{$_[0]}) { $showthread = 1; }
	if ($Cookies{'lastmessage'}
	  && ($Cookies{'lastmessage'} < $_[0])) {
		$newcount++;
	}
	@threadresponses = split(/ /,$next{$_[0]});
	foreach $threadresponse (@threadresponses) {
		unless ($subject{$threadresponse}) {
			&GetMessageDesc($threadresponse);
		}
		if ($subject{$threadresponse}) {
			&CompressList($threadresponse);
		}
	}
	$already{$_[0]} = 1;
}

sub ThreadList {
	local(@threadresponses);
	&PrintMessageDesc($_[0]);
	print "<UL>\n";
	@threadresponses = split(/ /,$next{$_[0]});
	foreach $threadresponse (@threadresponses) {
		unless ($subject{$threadresponse}
		  && !$DontUse{$threadresponse}) {
			&GetMessageDesc($threadresponse);
		}
		if ($subject{$threadresponse}
		  && !$DontUse{$threadresponse}) {
			&ThreadList($threadresponse);
		}
	}
	print "</UL>\n";
	$already{$_[0]} = 1;
}

sub PostMessage {
	if ($ArchiveOnly && !$FORM{'PrevConfirm'}) {
		unless ($FORM{'newpassword'}) { &Error_Password; }
		$newpassword = crypt($FORM{'newpassword'},aa);
		if (!$UseAdmin) { &Error_Password; }
		open (PASSWORD, "$dir/password.txt");
		$password = <PASSWORD>;
		close (PASSWORD);
		chop ($password) if ($password =~ /\n$/);
		if (!$password) { &newpass; }
		unless ($newpassword eq $password) { &Error_Password; }
	}
	if ($FORM{'PrevConfirm'}) {
		$num = $FORM{'PrevConfirm'};
		rename ("$dir/$num.tmp","$dir/$num");
		open(FILE,"$dir/$num")
		  || &Error_NoMessage;
		@message = <FILE>;
		close(FILE);
		foreach $line (@message) {
			if ($line =~ /^SUBJECT>(.*)/i) {
				$FORM{'subject'} = $1;
			}
			elsif ($line =~ /^POSTER>(.*)/i) {
				$FORM{'name'} = $1;
			}
			elsif ($line =~ /^EMAIL>(.*)/i) { $email = $1; }
			elsif ($line =~ /^DATE>(.*)/i) { $todaydate = $1; }
			elsif ($line =~ /^PREVIOUS>(.*)/i) { $followup = $1; }
			unless (($line =~ /^SUBJECT>/i)
			  || ($line =~ /^POSTER>/i)
			  || ($line =~ /^EMAIL>/i)
			  || ($line =~ /^DATE>/i)
			  || ($line =~ /^EMAILNOTICES>/i)
			  || ($line =~ /^IP_ADDRESS>/i)
			  || ($line =~ /^PASSWORD>/i)
			  || ($line =~ /^PREVIOUS>/i)
			  || ($line =~ /^NEXT>/i)
			  || ($line =~ /^IMAGE>/i)
			  || ($line =~ /^LINKNAME>/i)
			  || ($line =~ /^LINKURL>/i)) {
				$FORM{'body'} = $FORM{'body'} . $line;
			}
		}
		&PublishPost;
	}
	$FORM{'email'} =~ s/\s//g;
	unless ($FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)/
	  || $FORM{'email'} !~
	  /^.+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,3}|[0-9]{1,3})(\]?)$/)
	  {
		$email = "$FORM{'email'}";
	}
	$FORM{'url'} =~ s/\&amp\;/\&/g;
	$FORM{'url'} =~ s/\&quot\;/"/g;
	$FORM{'url'} =~ s/\s//g;
	$FORM{'imageurl'} =~ s/\&amp\;/\&/g;
	$FORM{'imageurl'} =~ s/\&quot\;/"/g;
	$FORM{'imageurl'} =~ s/\s//g;
	unless ($FORM{'url'} =~ /;|\*|@|(\.\.)|(^\.)|(\/\/\.)/ ||
	  $FORM{'url'} !~ /.*\:\/\/.*\..*/ ||
	  !($FORM{'url_title'})) {
		$message_url = "$FORM{'url'}";
		$message_url_title = "$FORM{'url_title'}";
	}
	unless ($FORM{'imageurl'} =~ /;|\*|@|(\.\.)|(^\.)|(\/\/\.)/ ||
	  $FORM{'imageurl'} !~ /.*\:\/\/.*\..*/) {
		$image_url = "$FORM{'imageurl'}";
	}
	if ($FORM{'followup'}) { $followup = "$FORM{'followup'}"; }
	if ($FORM{'name'}) { $name = "$FORM{'name'}"; }
	if ($FORM{'subject'}) { $subject = "$FORM{'subject'}"; }
	if ($FORM{'body'}) { $body = "$FORM{'body'}"; }
	unless ($name && $subject && $body) { &Error_Incomplete; }
	$new_body = $body;
	$new_body =~ s/\n/ /g;
	unless (-w "$dir") { &Error_File("$dir"); }
	open (DUPEDATA,"$dir/dupecheck.txt");
	$last_body = <DUPEDATA>;
	close (DUPEDATA);
# hack to disable dupe checking
#	if ($last_body eq $new_body) { &Error_Duplicate; }
#	else {
#		open (DUPEDATA,">$dir/dupecheck.txt");
#		print DUPEDATA "$new_body";
#		close (DUPEDATA);
#	}
	unless (-e "$dir/data.txt") {
		open (NUMBER,">$dir/data.txt");
		print NUMBER "0";
		close (NUMBER);
	}
	open (NUMBER,"+<$dir/data.txt");
	$lockerror = &LockFile(NUMBER);
	if ($lockerror) {
		close (NUMBER);
		&Header("Message Not Posted",$MessageHeaderFile);
		print "<P ALIGN=CENTER><BIG><BIG><STRONG>Your Message ",
		  "Was Not Posted!</STRONG></BIG></BIG>\n",
		  "<P>The script was unable to lock the ";
		  "&quot;data.txt&quot; file. Please use the ",
		  "&quot;Back&quot; button on your browser to ",
		  "return and try again. If the problem persists, ";
		  "please contact the board's administrator at ",
		  "<A HREF=\"mailto:$maillist_address\">",
		  "$maillist_address</A>. Thanks!</P>\n";
		&Footer($MessageFooterFile,"return");
	}
	$num = <NUMBER>;
	$num++;
	seek(NUMBER, 0, 0);
	print NUMBER "$num";
	&UnlockFile(NUMBER);
	close (NUMBER);
	if ($FORM{'Preview'}) {
		open (MESSAGE,">$dir/$num.tmp")
		  || &Error_File("$dir/$num.tmp");
	}
	else {
		open (MESSAGE,">$dir/$num")
		  || &Error_File("$dir/$num");
	}
	print MESSAGE "SUBJECT>$subject\n";
	print MESSAGE "POSTER>$name\n";
	print MESSAGE "EMAIL>$email\n";
	print MESSAGE "DATE>$todaydate\n";
	if (!$FORM{'wantnotice'}) {
		print MESSAGE "EMAILNOTICES>no\n";
		$Cookies{'wantnotice'} = "no";
	}
	else { $Cookies{'wantnotice'} = ""; }
	print MESSAGE "IP_ADDRESS> ";
	print MESSAGE "REMOTE_HOST: $ENV{'REMOTE_HOST'}; ";
	print MESSAGE "REMOTE_ADDR: $ENV{'REMOTE_ADDR'}\n";
	if ($FORM{'password'}) {
		$password = crypt($FORM{'password'},aa);
		print MESSAGE "PASSWORD>$password\n";
	}
	if ($FORM{'source_title'} && $FORM{'source_url'}) {
		print MESSAGE "PREVIOUS><A HREF=\"$FORM{'source_url'}\">";
		print MESSAGE "$FORM{'source_title'}</A>\n";
	}
	else { print MESSAGE "PREVIOUS>$followup\n"; }
	print MESSAGE "NEXT>\n";
	print MESSAGE "IMAGE>$image_url\n";
	print MESSAGE "LINKNAME>$message_url_title\n";
	print MESSAGE "LINKURL>$message_url\n";
	print MESSAGE "<P>$body\n";
	close (MESSAGE);
	if ($FORM{'Preview'}) {
		&Header("Message Preview",$MessageHeaderFile);
		print "<P ALIGN=CENTER><BIG><BIG><STRONG>",
		  "Message Preview</STRONG></BIG></BIG>\n",
		  "<P>Below, you can see how your message will look. ",
		  "<STRONG>The message has <EM>not</EM> ",
		  "been posted yet!</STRONG> This is merely a ",
		  "preview screen. If everything looks as you intended, ",
		  "hit the &quot;Confirm&quot; button below. Otherwise, ",
		  "use the &quot;Back&quot; button on your browser ",
		  "to return to the input form.\n";
		print "<P><CENTER><FORM METHOD=POST ";
		print "ACTION=\"$cgiurl?post\">\n";
		print "<INPUT TYPE=HIDDEN NAME=PrevConfirm VALUE=$num>\n";
		print "<INPUT TYPE=SUBMIT VALUE=Confirm>\n";
		print "</FORM></CENTER></P>\n";
		print "<HR WIDTH=50%>\n";
		print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
		print "$subject</STRONG></BIG></BIG></BIG>\n";
		print "<P ALIGN=CENTER><EM>Posted by <STRONG>";
		if ($email) {
			print "<A HREF=\"mailto:$email\">$name</A>";
		}
		else { print "$name"; }
		print "</STRONG> on <STRONG>$todaydate</STRONG>";
		if ($FORM{'source_title'} && $FORM{'source_url'}) {
			print ", in response to ";
			print "<A HREF=\"$FORM{'source_url'}\">";
			print "$FORM{'source_title'}</A>.";
		}
		elsif ($followup > 0) {
			&GetMessageDesc($followup);
			if ($subject{$followup}) {
				print ", in response to ";
				print "<A HREF=\"$cgiurl?";
				print "read=$followup\">";
				print "$subject{$followup}</A>, ";
				print "posted by ";
				print "$poster{$followup} on ";
				print "$date{$followup}";
			}
		}
		print "</EM></P>\n";
		print "<P>$body</P>\n";
		if ($image_url) {
			print "<P ALIGN=CENTER>";
			print "<IMG SRC=\"$image_url\"></P>\n";
		}
		if ($message_url) {
			print "<P ALIGN=CENTER>";
			print "<EM><A HREF=\"$message_url\">";
			print "$message_url_title</A></EM></P>\n";
		}
		&Footer($MessageFooterFile,"credits");
	}
	&PublishPost;
}

sub PublishPost {
	if ($followup) {
		open (FOLLOWUP,"$dir/$followup");
		@followup_lines = <FOLLOWUP>;
		close (FOLLOWUP);
		open (FOLLOWUP,">$dir/$followup");
		foreach $line (@followup_lines) {
			if ($line =~ /^SUBJECT>(.*)/i) {
				$subject{$followup} = $1;
			}
			elsif ($line =~ /^POSTER>(.*)/i) {
				$poster{$followup} = $1;
			}
			elsif ($line =~ /^DATE>(.*)/i) {
				$date{$followup} = $1;
			}
			elsif ($line =~ /^EMAIL>(.*)/i) {
				$email{$followup} = $1;
			}
			elsif ($line =~ /^EMAILNOTICES>/i) {
				$wantnotice{$followup} = "no";
			}
			if ($line =~ /^NEXT>/) {
				$line =~ s/\n//g;
				print FOLLOWUP "$line $num\n";
			}
			else {
				print FOLLOWUP "$line";
			}
		}
		close(FOLLOWUP);
	}
	if ($mailprog) {
		$FORM{'subject'} = &UnWebify($FORM{'subject'});
		$FORM{'name'} = &UnWebify($FORM{'name'});
		$FORM{'body'} = &UnWebify($FORM{'body'});
		$subject{$followup} = &UnWebify($subject{$followup});
		$poster{$followup} = &UnWebify($poster{$followup});
		$open1 = "A new message, \"$FORM{'subject'},\" ";
		$open1 = $open1."was posted on the $boardname";
		$open1 = $open1." <$cgiurl> by $FORM{'name'} on $todaydate";
		$open2 = $open1;
		if ($subject{$followup}) {
			$open1 = $open1."  It is a response to ";
			$open1 = $open1."\"$subject{$followup},\" posted by";
			$open1 = $open1." $poster{$followup} on ";
			$open1 = $open1."$date{$followup}";
			$open2 = $open2."  It is a response to your post, ";
			$open2 = $open2."\"$subject{$followup},\"";
			$open2 = $open2." of $date{$followup}";
		}
		$open1 = $open1."\n\n";
		$open2 = $open2."\n\n";
		$body = "";
		unless ($HeaderOnly) {
			$body = "The message reads as follows:\n\n";
			$body = $body."                      ";
			$body = $body."-------------------------\n\n";
			$body = $body.$FORM{'body'}."\n\n";
		}
		$body = $body."                      ";
		$body = $body."-------------------------\n\n";
		$close1 = "This is an automatically-generated notice.  ";
		$close1 = $close1."If you'd like to be removed from the ";
		$close1 = $close1."mailing list, please visit the ";
		$close1 = $close1."$boardname at <$cgiurl>, or send your ";
		$close1 = $close1."request to $maillist_address.  If ";
		$close1 = $close1."you wish to respond to this message, ";
		$close1 = $close1."please post your response directly ";
		$close1 = $close1."to the board.  Thank you!\n\n";
		$close2 = "This is an automatically-generated notice.  ";
		$close2 = $close2."If you wish to respond to this ";
		$close2 = $close2."message, please post your response ";
		$close2 = $close2."directly to the $boardname at ";
		$close2 = $close2."<$cgiurl>.  Thank you!\n\n";
		$open1 = &WordWrap($open1);
		$open2 = &WordWrap($open2);
		$body = &WordWrap($body);
		$close1 = &WordWrap($close1);
		$close2 = &WordWrap($close2);
	}
	if ($mailprog && $AdminEmail) {
		open (MAIL, "|$mailprog -t")
		  || &Error_File($mailprog);
		print MAIL "To: $maillist_address\n",
		  "From: maillist\@SEE.MESSAGE.FOR.ADDRESS\n",
		  "Subject: New $boardname Post\n\n",
		  "$open1",
		  "$body",
		  "$close1";
		close (MAIL);
	}
	if ($mailprog && ($email_list == 1)
	  && (-e "$dir/addresses.txt")) {
		open (ADDRESSES,"$dir/addresses.txt")
		  || &Error_File("$dir/addresses.txt");
		@addresses = <ADDRESSES>;
		close (ADDRESSES);
		foreach $address (@addresses) {
			unless ((length($address) < 5)
			  || ($email && ($address =~ /$email/i))
			  || ($email{$followup}
			  && ($address =~ /$email{$followup}/i))) {
				open (MAIL, "|$mailprog -t")
				  || &Error_File($mailprog);
				print MAIL "To: $address",
				  "From: maillist\@SEE.MESSAGE.FOR.ADDRESS\n",
				  "Subject: New $boardname Post\n\n",
				  "$open1",
				  "$body",
				  "$close1";
				close (MAIL);
			}
			if ($email{$followup}
			  && ($address =~ /$email{$followup}/i)) {
				$onrecipientlist = 1;
			}
		}
	}
	if ($mailprog && $email{$followup}) {
		unless ((($wantnotice{$followup} eq "no")
		  && !$onrecipientlist)
		  || ($email{$followup} eq $email)) {
			open (MAIL, "|$mailprog -t")
			  || &Error_File($mailprog);
			print MAIL "To: $email{$followup}\n",
			  "From: maillist\@SEE.MESSAGE.FOR.ADDRESS\n",
			  "Subject: Response to Your $boardname Post\n\n",
			  "$open2",
			  "$body",
			  "$close2";
			close (MAIL);
		}
	}
	if ($AllowPreview || ($Max_Days > 0) || ($Max_Messages > 0)) {
		opendir (FILES,$dir);
		@files = readdir(FILES);
		closedir (FILES);
	}
	if ($AllowPreview) {
		foreach $file (@files) {
			if (((-M "$dir/$file") > 1) && ($file =~ /\.tmp$/)) {
				unlink ("$dir/$file");
			}
		}
	}
	if ($Max_Days > 0) {
		foreach $file (@files) {
			if (((-M "$dir/$file") > $Max_Days) && ($file > 0)) {
				if ($ArchiveDir) {
					rename ("$dir/$file","$ArchiveDir/$file");
				}
				else {
					unlink ("$dir/$file");
				}
			}
		}
	}
	if ($Max_Messages > 0) {
		@sortedfiles = sort {$b<=>$a} @files;
		$Message_Count = 0;
		foreach $file (@sortedfiles) {
			if (($file > 0) && ($file !~ /\.tmp$/)) {
				$Message_Count++;
				if ($Message_Count > $Max_Messages) {
					if ($ArchiveDir) {
						rename ("$dir/$file","$ArchiveDir/$file");
					}
					else {
						unlink ("$dir/$file");
					}
				}
			}
		}
	}
	if ($UseCookies) {
		&Send_Cookie;
	}
	&Header("Message Posted",$MessageHeaderFile);
	print "<P ALIGN=CENTER>[ <A HREF=\"$cgiurl?read=$num\">";
	print "Review Your Message</A> | <A HREF=\"$cgiurl\">Return to ";
	print "the Index</A> ]</P><HR>\n";
	print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
	print "$boardname</STRONG></BIG></BIG></BIG>\n";
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Your Message Has Been Posted</STRONG></BIG></BIG>\n";
	print "<P ALIGN=CENTER>Thanks for contributing!</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub UnWebify {
	$texttoconvert = $_[0];
	$texttoconvert =~ s/<P>/\n\n/g;
	$texttoconvert =~ s/<([^>]|\n)*>//g;
	$texttoconvert =~ s/\&quot\;/"/g;
	$texttoconvert =~ s/\&lt\;/</g;
	$texttoconvert =~ s/\&gt\;/>/g;
	$texttoconvert =~ s/\&amp\;/\&/g;
	$texttoconvert =~ s/\n(\n)+/\n\n/g;
	return $texttoconvert;
}

sub WordWrap {
	$quotedtext = $_[0];
	$returntext = "";
	$length = length($quotedtext)-1;
	$wrapcount = 0;
	foreach $key (0..$length) {
		$char = substr($quotedtext,$key,1);
		$wrapcount++;
		if (($wrapcount > 70) && ($char eq " ")) {
			$char = "\n";
		}
		$returntext = $returntext.$char;
		if ($char =~ /\n/) {
			$wrapcount = 0;
		}
	}
	return $returntext;
}

sub Get_Date {
	@days =
	  (Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday);
	@months =
	  (January,February,March,April,May,June,
	  July,August,September,October,November,December);
	$time = time;
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
	  localtime($time+($HourOffset*3600));
	$year = 1900 + $year;
	$ampm = "a.m.";
	if ($hour eq 12) { $ampm = "p.m."; }
	if ($hour eq 0) { $hour = "12"; }
	if ($hour > 12) {
		$hour = ($hour - 12);
		$ampm = "p.m.";
	}
	if ($min < 10) { $min = "0$min"; }
	$todaydate = "$days[$wday], $mday $months[$mon] $year, ";
	$todaydate = $todaydate."at $hour\:$min $ampm";
}

sub Send_Cookie {
	if (!$name) { $name = $Cookies{'name'}; }
	if (!$email) { $email = $Cookies{'email'}; }
	if (!$listtype) { $listtype = $Cookies{'listtype'}; }
	if (!$listtime) { $listtime = $Cookies{'listtime'}; }
	if (!$Cookies{'thisvisit'}) {
		$Cookies{'thisvisit'} = $Cookies{'lastvisit'};
	}
	if (!$Cookies{'thismessage'}) {
		$Cookies{'thismessage'} = $Cookies{'lastmessage'};
	}
	if (($time - $Cookies{'timestamp'}) < 1800) {
		$lastvisit = $Cookies{'lastvisit'};
		$lastseen = $Cookies{'lastmessage'};
		$thisvisit = $Cookies{'thisvisit'};
		$thisseen = $Cookies{'thismessage'};
	}
	else {
		$lastvisit = $Cookies{'thisvisit'};
		$lastseen = $Cookies{'thismessage'};
		$Cookies{'lastvisit'} = $Cookies{'thisvisit'};
		$Cookies{'lastmessage'} = $Cookies{'thismessage'};
		$thisvisit = $todaydate;
		$thisseen = $lastmessage;
	}
	if (!$Cookies{'lastmessage'}) {
		$Cookies{'lastmessage'} = $lastmessage;
	}
	&SetCompressedCookies($boardname,'name',$name,'email',$email,
	  'listtype',$listtype,'listtime',$listtime,
	  'lastmessage',$lastseen,'lastvisit',$lastvisit,
	  'thismessage',$thisseen,'thisvisit',$thisvisit,
	  'timestamp',$time,'wantnotice',$Cookies{'wantnotice'});
}

sub Reconfigure {
	&Header("$boardname Configuration",$MessageHeaderFile);
	print "<P ALIGN=CENTER>[ <A HREF=\"$cgiurl\">Return ";
	print "to the Index</A> ]</P><HR>\n";
	print "<P ALIGN=CENTER><BIG><BIG><BIG><STRONG>";
	print "$boardname</STRONG></BIG></BIG></BIG>\n";
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>Message Index ";
	print "Display Configuration</STRONG></BIG></BIG>\n";
	$ListType = $Cookies{'listtype'};
	$ListTime = $Cookies{'listtime'};
	if (!$ListType) { $ListType = $DefaultType; }
	if (!$ListTime) { $ListTime = $DefaultTime; }
	if ($ListTime eq "Archive") { $ListTime = "Several Eons"; }
	print "<P>Use the form below to search for messages ",
	  "which include certain keywords or which were posted ",
	  "at a particular time or by a particular individual, ",
	  "and/or to select the manner in which you wish the ",
	  "messages in the index to be displayed.\n";
	if ($UseCookies) {
		print "<P>(If your browser supports and is set to accept ";
		print "&quot;cookies,&quot; your preferences will be ";
		print "remembered the next time you visit!)</P>\n";
	}
	else {
		print "<P>(Note that since this board is not set to ";
		print "utilize &quot;cookies,&quot; your preferences ";
		print "will not be remembered the next time you ";
		print "visit.)</P>\n";
	}
	print "<HR WIDTH=50%>\n";
	print "<FORM METHOD=POST ACTION=\"$cgiurl\">\n";
	print "<P>List messages <SELECT NAME=\"ListType\"><OPTION";
	if (($ListType eq "Chronologically") || !$ListType) {
		print " SELECTED";
	}
	print ">Chronologically<OPTION";
	if ($ListType eq "By Threads") { print " SELECTED"; }
	print ">By Threads<OPTION";
	if ($ListType eq "By Threads, Reversed") { print " SELECTED"; }
	print ">By Threads, Reversed<OPTION";
	if ($ListType eq "Compressed") { print " SELECTED"; }
	print ">Compressed</SELECT>\n",
	  "<P><EM>(A chronological display will put the newest ",
	  "messages at the top of the list. A standard threaded ",
	  "display will put the newest messages at the bottom. A ",
	  "reversed threaded display will show messages in a mixed ",
	  "order: 'First' messages will be arranged with the newest ",
	  "at the top, but responses will be arranged with the ",
	  "newest at the bottom. Though awkward, this is the ",
	  "default index style of many Web-based bulletin boards, ",
	  "and is the style with which many users are most ",
	  "familiar. A compressed listing will show on the main ",
	  "index page only the first message of each thread.)</EM>\n",
	  "<P>List only those messages:</P><P><DL>\n";
	unless ($ArchiveOnly) {
		print "<DD><INPUT TYPE=RADIO NAME=\"ListCriteria\" ";
		print "VALUE=\"Recent\" CHECKED> ";
		print "Posted within the last <SELECT ";
		print "NAME=\"ListTime\"><OPTION";
		if ($ListTime eq "Day") { print " SELECTED"; }
		print ">Day <OPTION";
		if ($ListTime eq "Two Days") { print " SELECTED"; }
		print ">Two Days<OPTION";
		if (($ListTime eq "Week") || !($ListTime)) {
			print " SELECTED";
		}
		print ">Week<OPTION";
		if ($ListTime eq "Two Weeks") { print " SELECTED"; }
		print ">Two Weeks<OPTION";
		if ($ListTime eq "Month") { print " SELECTED"; }
		print ">Month<OPTION";
		if ($ListTime eq "Several Eons") { print " SELECTED"; }
		print ">Several Eons</SELECT>\n";
	}
	print "<P><DD><INPUT TYPE=RADIO ";
	print "NAME=\"ListCriteria\" VALUE=\"Archive\"";
	if ($ArchiveOnly) { print " CHECKED"; }
	print "> Posted between <SELECT ",
	  "NAME=\"StartMonth\"><OPTION ",
	  "SELECTED>Jan<OPTION>Feb<OPTION>Mar<OPTION>Apr",
	  "<OPTION>May<OPTION>Jun<OPTION>Jul<OPTION>Aug",
	  "<OPTION>Sep<OPTION>Oct<OPTION>Nov<OPTION>Dec</SELECT> ",
	  "<SELECT NAME=\"StartYear\">",
	  "<OPTION>1996<OPTION>1997<OPTION>1998<OPTION>1999<OPTION>2000<OPTION>2001<OPTION>2002<OPTION selected>2003",
	  "</SELECT> and <SELECT NAME=\"EndMonth\"><OPTION>Jan",
	  "<OPTION>Feb<OPTION>Mar<OPTION>Apr",
	  "<OPTION>May<OPTION>Jun<OPTION>Jul",
	  "<OPTION>Aug<OPTION>Sep<OPTION>Oct<OPTION>Nov",
	  "<OPTION SELECTED>Dec</SELECT> <SELECT ",
	  "NAME=\"EndYear\"><OPTION>1996<OPTION ",
	  ">1997<OPTION>1998<OPTION>1999<OPTION>2000<OPTION>2001<OPTION>2002<OPTION>2003<OPTION selected>2004</SELECT></DL></P>\n",
	  "<P>List:</P>\n",
	  "<P><DL><DD><INPUT TYPE=RADIO NAME=\"KeySearch\" ",
	  "VALUE=\"No\" CHECKED> All messages within the specified ",
	  "date range<P><DD><INPUT TYPE=RADIO NAME=\"KeySearch\" ",
	  "VALUE=\"Yes\"> Only messages containing <SELECT ",
	  "NAME=\"Boolean\"><OPTION SELECTED>Any",
	  "<OPTION>All</SELECT> of the following keywords:",
	  "<DD><INPUT TYPE=TEXT NAME=\"Keywords\" ",
	  "SIZE=50><P><DD><INPUT TYPE=RADIO NAME=\"KeySearch\" ",
	  "VALUE=\"Author\"> Only messages posted by:",
	  "<DD><INPUT TYPE=TEXT ",
	  "NAME=\"Author\" SIZE=50></DL></P>\n",
	  "<P><CENTER><INPUT TYPE=SUBMIT VALUE=\"View Message ",
	  "Index\"></CENTER></P></FORM>\n";
	&Footer($MessageFooterFile,"credits");
}

sub UpdateAddressList {
	$FORM{'email'} =~ s/\s//g;
	if ($FORM{'email'} =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)/
	  || $FORM{'email'} !~
	  /^.+\@(\[?)[a-zA-Z0-9\-\.]+\.([a-zA-Z]{2,3}|[0-9]{1,3})(\]?)$/)
	  {
		&Error_Email;
	}
	unless (-w "$dir") { &Error_File("$dir"); }
	open (LIST,"$dir/addresses.txt");
	@list = <LIST>;
	close (LIST);
	$listcheck = 0;
	open (LIST,">$dir/addresses.txt");
	foreach $address (@list) {
		if ($address =~ /$FORM{'email'}/i) {
			if ($FORM{'action'} eq "delete") {
				&Off_The_List;
				$listcheck = 1;
			}
			else {
				&Error_List_Yes;
				print LIST "$address";
				$listcheck = 1;
			}
		}
		else {
			print LIST "$address";
		}
	}
	if ($listcheck < 1) {
		if ($FORM{'action'} eq "delete") {
			&Error_List_No;
		}
		else {
			&On_The_List;
			print LIST "$FORM{'email'}\n";
		}
	}
	close (LIST);
	&Footer($MessageFooterFile,"return");
}

sub On_The_List {
	&Header("You're On The List!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Thanks For Your Interest!</STRONG></BIG></BIG>\n";
	print "<P>Your e-mail address (<STRONG>$FORM{'email'}</STRONG>) ";
	print "has been added to the $boardname e-mail notification ";
	print "list. Whenever a new message is posted, you'll know ";
	print "about it! If you have any questions, please send a note ";
	print "to <A HREF=\"mailto:$maillist_address\">";
	print "$maillist_address</A>. Thanks!</P>\n";
}

sub Off_The_List {
	&Header("You're Off The List!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "We're Sorry to See You Go!</STRONG></BIG></BIG>\n";
	print "<P>Your e-mail address (<STRONG>$FORM{'email'}</STRONG>) ";
	print "has been removed from the $boardname e-mail notification ";
	print "list. If you have any questions, please send a note to ";
	print "<A HREF=\"mailto:$maillist_address\">";
	print "$maillist_address</A>.</P>\n";
}

sub Error_List_Yes {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Duplicate Submission!</STRONG></BIG></BIG>\n";
	print "<P>Thanks for your interest, but your e-mail address ";
	print "(<STRONG>$FORM{'email'}</STRONG>) is <EM>already</EM> ";
	print "on the $boardname e-mail notification list! You don't ";
	print "really need <EM>two</EM> notices of each new post, ";
	print "do you?</P>\n";
}

sub Error_List_No {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "You're Not On The List!</STRONG></BIG></BIG>\n";
	print "<P>Your e-mail address (<STRONG>$FORM{'email'}</STRONG>) ";
	print "can't be removed from the $boardname e-mail notification ";
	print "list, since it is not currently <EM>on</EM> the list! ";
	print "If you have any questions, please send a note to ";
	print "<A HREF=\"mailto:$maillist_address\">";
	print "$maillist_address</A>.</P>\n";
}

sub Error_Email {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Invalid Address!</STRONG></BIG></BIG>\n";
	print "<P>Thanks for your interest, ";
	print "but the e-mail address you entered seems ";
	print "to be invalid. Please use the &quot;Back&quot; button ";
	print "on your browser to return and re-enter it.</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Error_File {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "File Error!</STRONG></BIG></BIG>\n";
	print "<P>The server encountered an error while trying to ";
	print "access <STRONG>$_[0]</STRONG>! Either the directory or ";
	print "file doesn't exist, or its permissions are set ";
	print "incorrectly.</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Error_NoMessage {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "No Message!</STRONG></BIG></BIG>\n";
	print "<P>Sorry, but the message you just tried to load ";
	print "doesn't exist! You may have followed an obsolete ";
	print "hard-coded link, or it may be that you just tried ";
	print "to enter the address manually, and mis-typed it. ";
	print "Please return to the <A HREF=\"$cgiurl\">";
	print "message index</A> and try again!</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Error_Incomplete {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Incomplete Submission!</STRONG></BIG></BIG>\n";
	print "<P>Your message is incomplete! Your enthusiasm is ";
	print "appreciated, but you need to make sure that you include ";
	print "<EM>your name</EM>, <EM>a subject line</EM> and (of ";
	print "course) <EM>a message</EM>! Please return to the <A ";
	print "HREF=\"$ENV{'HTTP_REFERER'}\">entry ";
	print "form</A> and try again! Thanks!\n";
	print "<P>(If you use the &quot;Back&quot; button on your ";
	print "browser, any information you've already input should be ";
	print "retained.)</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Error_Duplicate {
	&Header("Oops!",$MessageHeaderFile);
	print "<P ALIGN=CENTER><BIG><BIG><STRONG>";
	print "Duplicate Submission!</STRONG></BIG></BIG>\n";
	print "<P>This error usually means that you have pressed the ";
	print "&quot;Post Message&quot; button more than once ";
	print "for the same message. Please return to the ";
	print "<A HREF=\"$cgiurl\">message index</A> ";
	print "(and reload it if necessary) to confirm that ";
	print "your message was, in fact, posted!</P>\n";
	&Footer($MessageFooterFile,"return");
}

sub Header {
	local ($header_title, $header_file) = @_;
	print "\n";
	print "<HTML><HEAD><TITLE>$header_title</TITLE>\n";
	if ($HeadLinesFile) {
		open (HEADLN,"$HeadLinesFile");
		@headln = <HEADLN>;
		close (HEADLN);
		foreach $line (@headln) {
			print "$line";
		}
	}
	print "</HEAD><BODY $bodyspec>\n";
	if ($header_file) {
		open (HEADER,"$header_file");
		@header = <HEADER>;
		close (HEADER);
		foreach $line (@header) {
			if ($line =~ /<!--InsertAdvert\s*(.*)-->/i) {
				&insertadvert($1);
			}
			else {
				print "$line";
			}
		}
	}
}

sub Footer {
	local ($footer_file,$footer_type) = @_;
	if ($footer_type eq "credits") {
		print "<HR><P ALIGN=CENTER><SMALL>The $boardname ";
		print "is maintained with <STRONG>";
		print "<A HREF=\"http://awsd.com/scripts/webbbs/\">";
		print "WebBBS $version</A></STRONG>.</SMALL></P>\n";
	}
	else {
		print "<HR WIDTH=50%>\n";
		print "<P ALIGN=CENTER>[ <STRONG><A HREF=\"$cgiurl\">";
		print "Return to the Message Index</A></STRONG> ]</P>\n";
	}
	if ($footer_file) {
		open (FOOTER,"$footer_file");
		@footer = <FOOTER>;
		close (FOOTER);
		foreach $line (@footer) {
			if ($line =~ /<!--InsertAdvert\s*(.*)-->/i) {
				&insertadvert($1);
			}
			else {
				print "$line";
			}
		}
	}
	print "</BODY></HTML>\n";
	exit;
}

sub LockFile {
	local(*FILE) = @_;
	local($TrysLeft) = 10;
	if ($UseLocking) {
		while ($TrysLeft--) {
			$lockresult = eval("flock(FILE,6)");
			if ($@) {
				$UseLocking = 0;
				last;
			}
			if (!$lockresult) {
				select(undef,undef,undef,0.1);
			}
			else {
				last;
			}
		}
	}
	if ($TrysLeft >= 0) {
		return 0;
	}
	else {
		return -1;
	}
}

sub UnlockFile {
	local(*FILE) = @_;
	if ($UseLocking) {
		flock(FILE,8);
	}
}

1;

