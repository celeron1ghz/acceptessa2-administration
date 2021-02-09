use utf8;
use strict;
use Test::More;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;

plan tests => 3;

my $v = Acceptessa2::Administration::Validator->build(
    [
        {
            column_name => 'name',
            label       => '名前',
            type        => Str,
            description => 'なまえ',
        },
        {
            column_name => 'price',
            label       => '価格',
            type        => Int,
            description => 'かかく',
        },
    ]
);

isa_ok $v, 'Acceptessa2::Administration::Validator';
is $v->validate_single(aa   => undef), undef, 'return false on not exist column';
is $v->validate_single(name => undef), '',    'return false on validator is false';
