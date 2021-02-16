use utf8;
use strict;
use Test::More;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Exhibition::Columns;

plan tests => 2;

my $clazz = "Acceptessa2::Administration::Exhibition::Columns";
is $clazz->validator->get_validator("aa"),   undef, 'return false on not exist column';
is $clazz->validator->get_validator("name"), undef, 'return false on validator is false';

