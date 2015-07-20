############################################
##                                        ##
##                 WebBBS                 ##
##           by Darryl Burgdorf           ##
##       (e-mail burgdorf@awsd.com)       ##
##                                        ##
##             version:  3.20             ##
##        last modified: 10/10/98         ##
##           copyright (c) 1998           ##
##                                        ##
##    latest version is available from    ##
##        http://awsd.com/scripts/        ##
##                                        ##
############################################

#################
# General Stuff #
#################

@days =
('Sunday','Monday','Tuesday','Wednesday',
'Thursday','Friday','Saturday');

@months =
('January','February','March','April','May','June',
'July','August','September','October','November','December');

$text{'0001'} = "Read Responses";
$text{'0002'} = "View Thread";
$text{'0003'} = "Post Response";
$text{'0004'} = "Return to Index";
$text{'0005'} = "Read Prev Msg";
$text{'0006'} = "Read Next Msg";
$text{'0007'} = "Post New Message";
$text{'0008'} = "(Un)Subscribe";
$text{'0009'} = "Search";
$text{'0010'} = "Set Preferences";
$text{'0011'} = "Review Your Message";

$text{'0100'} =
"<H1 ALIGN=CENTER>&quot;No Frames&quot; Page</H1><P>This site utilizes frames, which apparently either your browser doesn't support or you've disabled. However, a <!--NoFramesURL-->plain text version</A> is also available.</P>";

$text{'0200'} =
"<H1 ALIGN=CENTER>Message(s) Deleted!</H1><P>The designated message(s) are no longer on the board. If you have any questions, please send a note to <!--emaillink-->. Thanks!</P>";

#########################
# New Message Post Form #
#########################

$text{'1500'} =
"<P><SMALL>If you'd like to include a link to another page with your message,<BR>please provide both the URL address and the title of the page:</SMALL>";

$text{'1501'} =
"<P><SMALL>If you'd like to include an image (picture) with your message,<BR>please provide the URL address of the image file:</SMALL>";

$text{'1502'} =
"<P><SMALL>If you'd like to have the option of deleting your post later,<BR>please provide a password (CASE SENSITIVE!):</SMALL>";

$text{'1503'} =
"<P><SMALL>If you'd like e-mail notification of responses, please check this box:</SMALL>";

###################
# Message Preview #
###################

$text{'2000'} =
"<H1 ALIGN=CENTER>Message Preview</H1><P>Below, you can see how your message will look. <STRONG>The message has <EM>not</EM> been posted yet!</STRONG> This is merely a preview screen. If everything looks as you intended, hit the &quot;Post Message&quot; button below. Otherwise, use the &quot;Back&quot; button on your browser to return to the input form.";

########################
# "Reconfigure" Screen #
########################

$text{'5000'} = 
"(<STRONG>&quot;Chronological&quot;</STRONG> displays show messages simply in the order in which they were posted; <STRONG>&quot;threaded&quot;</STRONG> displays show messages in indented lists, with responses directly beneath their parent messages. In either style, a normal list puts the newest messages at the bottom, while a reversed list, obviously, does the reverse. The <STRONG>&quot;reversed theaded&quot;</STRONG> display, though somewhat awkward, is the &quot;default&quot; index style of many Web-based bulletin boards, including Matt Wright's &quot;WWWBoard&quot; script, and is the style with which many users are most familiar. The <STRONG>&quot;mixed threaded&quot;</STRONG> display is a bit of a half-breed; it arranges primary messages with the newest at the top, thus tending to keep newer messages toward the top of the page, but arranges responses with the newest at the bottom, thus preserving a more &quot;intuitive&quot; threading structure. <STRONG>&quot;Compressed&quot;</STRONG> displays show on the main index page only the first message of each thread; responses are available only by going to the primary message's page. This keeps the index page a bit smaller, but also, of course, makes the responses a bit more difficult to access. Finally, <STRONG>&quot;guestbook-style&quot;</STRONG> displays show the full text of messages on the main index page in a strict chronological manner; <STRONG>&quot;threaded guestbook-style&quot;</STRONG> displays show an index page very similar to that of the &quot;compressed&quot; displays, but show the full text of all messages in a thread on a single page.)";

##################
# E-Mail Notices #
##################

$text{'7000'} =
"The following new message has been posted on <!--boardname--> at <<!--boardurl-->>.";

$text{'7001'} =
"***************************************************************************";

$text{'7002'} =
"This is an automatically-generated notice.  If you'd like to be removed from the mailing list, please visit <!--boardname--> at <<!--boardurl-->>, or send your request to <!--email-->.";

$text{'7003'} =
"If you wish to respond to this message, please post your response directly to the board.  Thank you!";

$text{'7500'} =
"The following new messages have been posted on <!--boardname--> at <<!--boardurl-->>.";

##################
# Error Messages #
##################

$text{'9100'} =
"No Message!";

$text{'9101'} =
"Sorry, but the message you just tried to load doesn't exist! You may have followed an obsolete hard-coded link, or it may be that you just tried to enter the address manually, and mis-typed it.";

$text{'9200'} =
"Incomplete Submission!";

$text{'9201'} =
"Your message is incomplete! Your enthusiasm is appreciated, but you need to make sure that you include <EM>your name</EM>, <EM>a subject line</EM> and (of course) <EM>a message</EM>! Please return to the entry form and try again. Thanks! (If you use the &quot;Back&quot; button on your browser, any information you've already input should be retained.)";

$text{'9250'} =
"Message Too Long!";

$text{'9251'} =
"Your message is longer than is allowed on this board! It may be that you included too much quoted material, or it may just be that you had too much to say! In either event, please return to the entry form and try to reduce the verbiage. Thanks! (If you use the &quot;Back&quot; button on your browser, any information you've already input should be retained.)";

$text{'9300'} =
"Invalid Address!";

$text{'9301'} =
"Thanks for your interest, but the e-mail address you entered seems to be invalid. Please use the &quot;Back&quot; button on your browser to return and re-enter it.";

$text{'9400'} =
"File Error!";

$text{'9401'} =
"The server encountered a file error! This most likely means either that the data directory's location has been incorrectly defined or that its permissions have been incorrectly set.";

$text{'9410'} =
"File Lock Error!";

$text{'9411'} =
"The server encountered a file lock error! This most likely means either that the data directory's location has been incorrectly defined or that its permissions have been incorrectly set, or that the flock() command is not supported, in which case the script's $UseLocking configuration variable should be set to 0.";

$text{'9450'} =
"Mail System Error!";

$text{'9451'} =
"The server encountered an error while trying to send out e-mail notifications. This most likely means that the e-mail program has been incorrectly defined in the program's configuration.";

$text{'9500'} =
"Duplicate Submission!";

$text{'9501'} =
"This error usually means that you have pressed the &quot;Post Message&quot; button more than once for the same message. If that's the case, then your message has probabably already been posted. The error could also mean that you &quot;previewed&quot; your message, but then went back to the main input form and tried to submit it from there without making any changes. If that's the case, simply go back, make a minor change, and resubmit it!";

$text{'9510'} =
"Submission Not Accepted!";

$text{'9511'} =
"Your submission was not accepted, due to the presence of &quot;naughty&quot; language. Please use the &quot;Back&quot; button on your browser to go back and edit your post, then resubmit it!";

$text{'9520'} =
"Submission Not Accepted!";

$text{'9521'} =
"Your submission was not accepted, as unfortunately, your IP address has been banned from posting to <!--boardname-->. If you're the hapless victim of someone else's misbehavior, please contact the site administrator to see if it's possible to revise the ban.";

$text{'9600'} =
"Invalid Password!";

$text{'9601'} =
"Either your password was incorrect or no password was entered. Without a proper password, messages may not be deleted. Please use the &quot;Back&quot; button on your browser to return and try again.";

$text{'9700'} =
"Duplicate Address Submission!";

$text{'9701'} =
"Thanks for your interest, but your e-mail address is already on the e-mail notification list! You don't really need <EM>two</EM> notices of each new post, do you?";

$text{'9750'} =
"Invalid Address Submission!";

$text{'9751'} =
"Your e-mail address can't be removed from the e-mail notification list, since it is not currently <EM>on</EM> the list!";

$text{'9800'} =
"You're On The List!";

$text{'9801'} =
"Your e-mail address has been added to the e-mail notification list. Whenever a new message is posted, you'll know about it!";

$text{'9850'} =
"You're Off The List!";

$text{'9851'} =
"Your e-mail address has been removed from the e-mail notification list.";

$text{'9999'} =
"If you have any questions, please send a note to <!--emaillink-->.";

1;

