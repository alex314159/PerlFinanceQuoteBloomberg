# PerlFinanceQuoteBloomberg
Bloomberg module for the Perl Finance::Quote module (used in particular by GnuCash)

To make this work within GnuCash, you need to:

1/add the Bloomberg.pm file in the Finance/Quote/ folder within your perl modules directory

2/edit the main Quote.pm file within the Finance::Quote module. Around line 175, @modules is defined, just add Bloomberg in the list.

As an example the following should work at the command line if all is installed correctly:

    gnc-fq-dump bloomberg 1938:HK

Within GnuCash, in the security editor, select Get Online Quotes and then Other, Bloomberg should be an option.

Note that given both GnuCash and Bloomberg use the ":" character as a delimiter, it is advisable to change the default delimiter in GnuCash to some other character such as "/" (in the GnuCash preferences).

Finally, this bug has been reported on Windows 10 (with a solution):

http://gnucash.1415818.n4.nabble.com/Re-No-stock-quote-for-LU1233758587-td4693298.html#none
