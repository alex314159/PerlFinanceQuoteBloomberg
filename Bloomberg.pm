package Finance::Quote::Bloomberg;
require 5.013002;

use strict;

use vars qw($VERSION $BLOOMBERG_URL);

use LWP::UserAgent;
#use HTTP::Cookies;
use HTTP::Request::Common;
use HTML::TreeBuilder;

$VERSION = '0.2';
$BLOOMBERG_URL = 'https://www.bloomberg.com/quote/';

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
    #my $cookie_jar = HTTP::Cookies->new(file => "$ENV{'HOME'}/lwp_cookies.dat", autosave => 1,);
    #$ua->cookie_jar($cookie_jar);
    my @ns_headers = (
#      'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:67.0) Gecko/20100101 Firefox/67.0', 
#      'User-Agent' => 'Mozilla/5.0 (Linux; Android 6.0.1; SM-G532G Build/MMB29T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.83 Mobile Safari/537.36', 

      'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36',
      'Referer' => 'https://www.bloomberg.com/',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Accept-Encoding' => 'br', 
      'Accept-Language' => 'en-US,en;q=0.9,fr;q=0.8',
      'scheme'=> 'https',
      'upgrade-insecure-requests' => '1',
      'Cookie' => '_pxvid|d0276e7a-6115-11ea-a96a-0242ac120008;
_cc_dc|1;
notice_gdpr_prefs|0|1|2:;
cmapi_gtm_bl|;
cmapi_cookie_privacy|permit_1|2|3_;
_gat|1;
notice_preferences|2:;
_lc2_duid|b1166d620485--01e2wkrcz59w3s4hn7wmg5sv9k;
kw.session_ts|1583655705480;
kw.pv_session|1;
_sp_ses.3377|*;
_sp_id.3377|9a44946b-1a0f-4f83-8417-5e1367bf07ca.1583655706.1.1583655706.1583655706.acf5ba62-0f98-4e25-8d63-86c6fc833041;
__gads|ID=4ff612b3d7461822:T=1583655707:S=ALNI_MYxPELVGdGT5noHoHFbSKRzQnbxxA;
_gcl_au|1.1.99878994.1593550792;
_dc_gtm_UA-11413116-1|1;
_scid|7b6b779a-dad7-45ae-93c0-a578411d61ad;
_parsely_session|{%22sid%22:2%2C%22surl%22:%22https://www.bloomberg.com/quoteAAPL:US%22%2C%22sref%22:%22%22%2C%22sts%22:1593550802468%2C%22slts%22:1583655695669};
_parsely_visitor|{%22id%22:%2256ef2d2c-83a8-4258-bced-1b16f99fe083%22%2C%22session_count%22:2%2C%22last_session_ts%22:1593550802468};
_uetsid|d209c6cb-a51a-b59a-0a9d-406145a26c1b;
_uetvid|7facd679-3e7b-d472-602e-5ee128d1b061;
_lc2_fpi|b1166d620485--01ec3gf0tvwndh2bx06x16mpdm;
__pvi|%7B%22id%22%3A%22v-2020-06-30-21-59-52-634-T99bDMVmRSvMvi4l-483d48dcebbcc9d3c56b620dd57ef7a0%22%2C%22domain%22%3A%22.bloomberg.com%22%2C%22time%22%3A1593550809119%7D;
_fbp|fb.1.1593550794776.793277860;
_cc_id|fc6f9799f1b821a67b970dc0dd06cb4f;
_cc_cc|ACZ4nGNQSEs2S7M0t7RMM0yyMDJMNDNPsjQ3SEk2SEkxMEtOMkljAIK438uvf%2Fr%2F%2Fz8%2FAwyIrll1X5rxUBzDf0ZGhodrEOzlt2eKw9ibVyLEXyOpX7sewZ60CcF%2B%2FwLBfnx1phyMffvUIza4%2BX8KYcxtUzVhzDefLGHMH9fec8PY544eYoaxVx1XhzEPL57DAmOfR2J3bpoCZx%2B6f1cJxr6EZD8AiaJsuQ%3D%3D;
_cc_aud|ABR4nGNgYGCI%2B738OgMMMDOwZhaBGKyZhSCKq%2FwukAQAfz4F%2BA%3D%3D;
__tbc|%7Bjzx%7Dt_3qvTkEkvt3AGEeiiNNgD023z7l_5zhA8WKE_Fqx1Z_9ePl8XkSZxMY7tW_hUrmJhalcqj_HNzhoKrmiUMlQYTES0FG6BtkummC5wrld5t0oJlo4auDbjEngeY_EHYfjylU0Z664w9lha1BgkmqDg;
__pat|-14400000;
xbc|%7Bjzx%7DgRhWlbP9Y_i8h3_7rJeifk7euE-jOZNwV23jLn42vrW5-68-2EDgLnDPAgHNCXuDSkyGlbBpzopLnZCQ_NrMcvDs4gborAO9etTb59KfwQ28Kk4JDi5gMk2tZv3rCRH81aE7Fkj58FacDUyV7RsaoNGC7ztc3bqLsxEU93W4ArzJvHFrChHH2OeKvFFTQMA_0n8uHQfT4PiDOIdkk1s25kS_bB7tm-FiI11uSzLF1tRQ9MTUNkr8CsKe5nH8vz5FWPTDnnFEr0URhhQo2RxBkwT4CRI9vpiJMzGfKQxYvHYA8HJvd2bbVJNsseqOKHkmcfcBWzmjGO-DSqLq6uKCGuALDQv3G4uwNLpNLpjGazMoMZEIhUCRe2rRTYvsUB6pcmZGduPV1pr2azutjL_FrA;
cto_bundle|uVmLr19TS1ZCNm4lMkZyVXBmWDhiMWRic2E4MEVCM2xDUG9PQXlueE5NUWw0alJaMEFENVc5OFlvM1VDdXZYVFZRdHdvWVloRldFenQ5eHFUYTNVMGZnQkxKYjYyUWpLTjRxJTJCTG1NQ2JiazVhdThFb2dseVFSM2NoWUQ1d0laJTJGdCUyQmNCVmtMSHpoaEpSZm5WJTJGeWZad2o5RVNiVkVRJTNEJTNE;
_gat_UA-11413116-1|1;
agent_id|a1e24fc4-8d83-4a25-9365-d79d2bb623d9;
session_id|d95dc0c6-5257-417f-95c2-67c781ac4242;
session_key|458c9effe114454269ab098307188fc504ec36e8;
_is-ip-whitelisted|false;
_px2|eyJ1IjoiYWM2OGM5YjAtYmIxNC0xMWVhLWI3YWYtNmRiMmEyZjVlODgyIiwidiI6ImQwMjc2ZTdhLTYxMTUtMTFlYS1hOTZhLTAyNDJhYzEyMDAwOCIsInQiOjE1OTM1NTExMTU4MzIsImgiOiIyMDViY2M0ZGI1NTMwYWE2ZjM5YjRlYmExYjliZDQwZTIxNzJiZjBhYzViMzJmNjE5NWExNDRlN2IyNTQxYjU4In0=;
_px3|f7a32bb12042e514597833c2a0a8517532a5df98809f1f967f578867b4c70ef9:zuaJ40KqMgBqZ5jX4NC7uqtMYRpTDAf/5F/+YNdNlT/dR8Mw6JKxUhci53FTC4W4+b6F/zr3U7oG77ez74B5jw==:1000:q7uj1v6FeXsvJgLJkvfaJqKRJDKcTlTQtEC0IEipDFmsiSxsdIidLGUU6Nt4xt4qoqJ2MI23Atws3B2HYXHw7ADm2+4TDLVyoKlGNb0Nr0dFDV1bvvBFyc41eO+dkazKcHQpz1zlo0X0Io6B1oq9H7K6n0VHCtCFV6M1QMTw6yg=;
_ga|GA1.2.1062283548.1583655694;
_gid|GA1.2.2069578720.1593550792;
_pxde|e4a5b7349a3259cc2dfb017677a082a7fa27562974cf22a89103e5733a5672cc:eyJ0aW1lc3RhbXAiOjE1OTM1NTA5MDIzMzQsImZfa2IiOjAsImlwY19pZCI6W119;',


#'Cookie' => 'bbAbVisits=; _reg-csrf=s%3Abeiro2fr6yDhYT1UbBWKdN4I.3rHFdz49qG4t7UF30KQ3weWuDEnfV4feCcNkY0BpgZ0; _reg-csrf-token=7VTbASCv-b5EjnK4q0EhdaAOj4rKEx_QlnxM; agent_id=32481640-35eb-46f3-9a36-f286dbfe9cfe; session_id=1981de61-a1b4-4f72-aaed-29bb508d73b6; session_key=b9cab98960cfc255b50d2556ed262157761acf06; _user-status=anonymous; bb_geo_info={"country":"US","region":"US"}|1571248634895; _gcl_au=1.1.1726577321.1570643835; _user_newsletters=[]; bdfpc=004.7282107926.1570643835028; _pxvid=39e85df8-eabe-11e9-b15e-0242ac12000a; _pxde=55ea6c4ae7fac9b65de3e3294ead1b4196b5897e9cca205a6e38506042e1d90d:eyJ0aW1lc3RhbXAiOjE1NzA2NTA1Njk3ODUsImZfa2IiOjAsImlwY19pZCI6W119; notice_behavior=none; permutive-session=%7B%22session_id%22%3A%22ea50b626-74bc-4892-b9c5-b5a0e66b1524%22%2C%22last_updated%22%3A%222019-10-09T19%3A32%3A00.088Z%22%7D; permutive-id=7d79e993-6fbd-42a4-b808-88b8309fc4b0; bbAbVisits=; __tbc=%7Bjzx%7Dt_3qvTkEkvt3AGEeiiNNgLInO7D5q-gNNVMYXaomFA2PMn8RDJYCbbD0v3FQwh5JoF2YFoNbzIciTP5GaZdl7Olyvla-utZCr3u2Idlnxj_Rd0cZApFfxEpVLgqJPn0ojylU0Z664w9lha1BgkmqDg; __pat=-14400000; __pvi=%7B%22id%22%3A%22v-2019-10-09-15-27-56-189-zxArGrb2lq6M5tHj-d22356553525b0b6eb9b1ec44e609a58%22%2C%22domain%22%3A%22.bloomberg.com%22%2C%22time%22%3A1570649520446%7D; xbc=%7Bjzx%7DmC1EG7Vp2x-b744jJOaYuXwpUEc_9qOgc-zkolGtMvyAMh8E7P12r-eF6pe8ljatdh5vpf3do1EJLRy5V87EY9kRpCf7mYszQmQ9CXx9N2f4v0YiXfN8cD3f5J1HuZ3mBsVacZYqfnIfb4NqeIWEFwzgyo6_uM6Bmz00PDJkWGw30flLxTyB3997m2CsLDH57aWfkw4co3SpbaTakmahVoV7y1_H-R06EV4wuhPFk2ek-VLldYfws69_bQHoEuXz-p0rU7z-aNO8xtjHpC96mTawE8o7efuD6xFd4tq23XqiEYzaxwoG9SweVrnV2_HSkqw5J6lEisaUk_cH1uAcRJ2QEbHDKNt5GhA53b272UV0OBseA2ri_7iKQdHaFRt_Pix2-dSvxmZ0OPSEJiZ0labdeUSmmdjzK9NDxao2kz0; _px2=eyJ1IjoiNzU0ZTA5YTAtZWFjYi0xMWU5LTlmZWItOWJiMjQ1NTY2MThlIiwidiI6IjM5ZTg1ZGY4LWVhYmUtMTFlOS1iMTVlLTAyNDJhYzEyMDAwYSIsInQiOjE1NzA2NTA3ODc1NjksImgiOiJjN2MxOTA5OTIxM2UwZmIwYWRhODgwNzA5MjhmNmRmZDBlMjU1ZDk0MDE4YjY2NDA2ZDllYjczNmJiNTZkOTIzIn0=; _px3=4a300cb3ee50dc28e8dd39391191ce239f622b0052cf8d85e23e4e0fa66cdf8d:KNJk6033mkUn8dQXkS3s3AaXLd/k4U1dxwt/HtX/+Jlm/wd6BIqNX0gTImrQNl032egQ93soMPKXJVXoHo/KxA==:1000:JELhFNUphuO88sTQ5G95bl9bKNQcAzN8UYo/AvMix6j6dZ/CapDusbofLJi3CoEL//tq9Z+LAKg9O/00Y+3Z5AkXwVS6TDk0PATjv0h2okuvp30RthcYEdheNOi1sY4fuaUK3czGKp/XU2GWjz93wiK6l2t7rhhxehlSDUFZi7Q=; cookieConsent=firstVisit|; cPixel=required|performance|advertising|linkedin-insights|media-shop|; __ncuid=4e6c215a-12db-465a-aa11-4189045443ef; _user-ip=71.233.149.118',
#

      'cache-control' => 'max-age=0',
      'Pragma' => 'no-cache', );
    #sleep(2);
    $reply = $ua->get($url, @ns_headers);
    # below used for debugging    
    #print $reply->content;
    unless ($reply->is_success) {
      foreach my $symbol (@symbols) {
        $funds{$symbol, "success"}  = 0;
        $funds{$symbol, "errormsg"} = "HTTP failure";
      }
	  return wantarray ? %funds : \%funds;
    }

    my $tree = HTML::TreeBuilder->new_from_content($reply->content);
    my @price_array = $tree -> look_down(_tag=>'span','class'=>'priceText__1853e8a5');
    my $price = @price_array[0]->as_text();#->attr('content');
    my @curr_array = $tree -> look_down(_tag=>'span','class'=>'currency__defc7184');
    my $curr = @curr_array[0]->as_text();#->attr('content');
    # my @date_array = $tree -> look_down(_tag=>'div','class'=>'time__94e24743');
    # my $date = @date_array[0]->as_text();#attr('content');
    # print $price;
    # print $curr;
    # print $date;


    $funds{$name, 'method'}   = 'bloomberg';
    $funds{$name, 'price'}    = $price;
    $funds{$name, 'currency'} = $curr;
    $funds{$name, 'success'}  = 1;
    $funds{$name, 'symbol'}  = $name;
    # US date format (mm/dd/yyyy) as defined in Quote.pm
    # Read the string from the end, because for Stocks it adds time at the
    # begining; but for mutual funds, not.
    # $quoter->store_date(\%funds, $name, {usdate => substr($date,-14,10)});
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
