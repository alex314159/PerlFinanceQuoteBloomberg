# PerlFinanceQuoteBloomberg
Bloomberg module for the Perl Finance::Quote module (used in particular by GnuCash)

To make this work within GnuCash, you need to:

1/add the Bloomberg.pm file in the Finance/Quote/ folder within your perl modules directory

2/edit the cookie definition in Bloomberg.pm. Instruction below.

3/edit the main Quote.pm file within the Finance::Quote module. Around line 175, @modules is defined, just add Bloomberg in the list.

As an example the following should work at the command line if all is installed correctly:

    gnc-fq-dump bloomberg 1938:HK

Within GnuCash, in the security editor, select Get Online Quotes and then Other, Bloomberg should be an option.

Note that given both GnuCash and Bloomberg use the ":" character as a delimiter, it is advisable to change the default delimiter in GnuCash to some other character such as "/" (in the GnuCash preferences).

Finally, this bug has been reported on Windows 10 (with a solution):

http://gnucash.1415818.n4.nabble.com/Re-No-stock-quote-for-LU1233758587-td4693298.html#none

*Updating the cookie header*

Bloomberg is trying to prevent bots querying data. You need to visit www.bloomberg.com using a regular web browser then insert the cookie into Bloomberg.pm. Here are instructions with Firefox (Chrome is harder!):

- get into your Firefox folder, into the latest distribution. On Ubuntu it's in `~/.mozilla/firefox/dpm0d9sv.default-release` (the dpm part may change).
- type `sqlite3 cookies.sqlite`
- type `select name,value from moz_cookies where host=".bloomberg.com";` Copy this output and paste it into Bloomberg.pm where it says `'Cookie' => `. Don't forget to put `'` at the beginning and end, and to add a `;` at the end of every line.
- you'll need to redo that every so often as the cookie expires.
