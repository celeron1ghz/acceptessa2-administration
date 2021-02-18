use utf8;
use strict;
use Test::More tests => 2;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Exhibition::Columns;

my $clazz = "Acceptessa2::Administration::Exhibition::Columns";
is $clazz->validator->get_validator("aa"),   undef, 'return false on not exist column';
is $clazz->validator->get_validator("name"), undef, 'return false on validator is false';

