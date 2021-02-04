use strict;
use warnings;
use utf8;
use Test::More;
use Acceptessa2::Administration;

ok 1;

my $t = Acceptessa2::Administration->new;

$t->run_command("circle.create", {});

done_testing;
