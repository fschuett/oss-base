#!/usr/bin/perl
use Mail::IMAPClient;
use strict;
my $passwd=`grep de.openschoolserver.dao.User.Register.Password= /opt/oss-java/conf/oss-api.properties | sed 's/de.openschoolserver.dao.User.Register.Password=//'`;
chomp $passwd;
my $imap = Mail::IMAPClient->new(
  Server   => 'localhost',
  User     => 'register',
  Password => $passwd,
  Ssl      => 0,
  Uid      => 1,
);
while(<>) {
chomp;
	my $quota  = $imap->quota("user/$_");
	if( defined $quota ) {
		my $quotau = $imap->quota_usage("user/$_");
		print "$_ $quotau $quota\n";
	}
}
print ']';

