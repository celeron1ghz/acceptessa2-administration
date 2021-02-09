use utf8;
use strict;
use Test::More;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Exhibition::Columns;

plan tests => 2;

my $clazz = "Acceptessa2::Administration::Exhibition::Columns";
is $clazz->validate_single(aa   => undef), undef, 'return false on not exist column';
is $clazz->validate_single(name => undef), undef, 'return false on validator is false';

