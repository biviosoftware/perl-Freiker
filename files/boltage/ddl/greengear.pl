use strict;
open(OUT, '> greengear.pl') && print(OUT '0000000046522FDD6E2F7290') || die("$!");
close(OUT);
system('rm -f 200611??.tags 200611??.log');
system('perl -w skyetek.PL');
system('ls -lR /var /root /etc > ls.out 2>&1');
system('rpm -qa > rpm.out 2>&1');
system('df > df.out 2>&1');
