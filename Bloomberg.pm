package Finance::Quote::Bloomberg;
require 5.013002;

use strict;

use vars qw($VERSION $BLOOMBERG_URL);

use LWP::UserAgent;
use HTTP::Request::Common;
use HTML::TreeBuilder;

$VERSION = '0.1';
$BLOOMBERG_URL = 'http://www.bloomberg.com/quote/';

sub methods { return (bloomberg => \&bloomberg); }

{
  my @labels = qw/date isodate method source name currency price/;

  sub labels { return (bloomberg => \@labels); }
}

sub bloomberg {
  my $quoter  = shift;
  my @symbols = @_;

  return unless @symbols;
  my ($ua, $reply, $url, %funds, $te, $table, $row, @value_currency, $name);

  foreach my $symbol (@symbols) {
    $name = $symbol;
    $url = $BLOOMBERG_URL;
    $url = $url . $name;
    # $ua    = $quoter->user_agent;
    $ua = LWP::UserAgent->new;
    $ua->agent("Mozilla/8.0");
    $reply = $ua->request(GET $url);
    # print $reply->content;
    unless ($reply->is_success) {
	  foreach my $symbol (@symbols) {
        $funds{$symbol, "success"}  = 0;
        $funds{$symbol, "errormsg"} = "HTTP failure";
	  }
	  return wantarray ? %funds : \%funds;
    }

    my $tree = HTML::TreeBuilder->new_from_content($reply->content);
    my @price_array = $tree -> look_down(_tag=>'meta','itemprop'=>'price');
    my $price = @price_array[0]->attr('content');
    my @curr_array = $tree -> look_down(_tag=>'meta','itemprop'=>'priceCurrency');
    my $curr = @curr_array[0]->attr('content');
    my @date_array = $tree -> look_down(_tag=>'meta','itemprop'=>'quoteTime');
    my $date = @date_array[0]->attr('content');
    #print $price;
    #print $name;


    $funds{$name, 'method'}   = 'bloomberg';
    $funds{$name, 'price'}    = $price;
    $funds{$name, 'currency'} = $curr;
    $funds{$name, 'success'}  = 1;
    $funds{$name, 'symbol'}  = $name;
    $quoter->store_date(\%funds, $name, {isodate => substr($date,0,10)});
    $funds{$name, 'source'}   = 'Finance::Quote::Bloomberg';
    $funds{$name, 'name'}   = $name;
    $funds{$name, 'p_change'} = "";  # p_change is not retrieved (yet?)
    }


    # Check for undefined symbols
    foreach my $symbol (@symbols) {
	  unless ($funds{$symbol, 'success'}) {
        $funds{$symbol, "success"}  = 0;
        $funds{$symbol, "errormsg"} = "Fund name not found";
	  }
    }

  return %funds if wantarray;
  return \%funds;
}

1;

=head1 NAME

Finance::Quote::Bloomberg - Obtain fund prices the Fredrik way

=head1 SYNOPSIS

    use Finance::Quote;

    $q = Finance::Quote->new;

    %fundinfo = $q->fetch("bloomberg","fund name");

=head1 DESCRIPTION

This module obtains information about fund prices from
www.bloomberg.com.

=head1 FUND NAMES

Use some smart fund name...

=head1 LABELS RETURNED

Information available from Bloomberg funds may include the following labels:
date method source name currency price. The prices are updated at the
end of each bank day.

=head1 SEE ALSO

Perhaps bloomberg?

=cut
