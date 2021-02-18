use utf8;
use strict;
use Test::More tests => 12;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;

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

is $v->get_validator("aa"), undef, 'return null on not exist column';
is $v->get_validator("name")->column_name, 'name', 'return object on exist column';

{
    ## all error pattern
    my $ret = $v->validate_all({});
    is $ret->has_error, 1;
    is_deeply $ret->valid_data, {};
    is_deeply $ret->errors, { name => '「名前」は文字列で入力してください。', price => '「価格」は数値で入力してください。' };
}
{
    ## partly error pattern
    my $ret = $v->validate_all({ name => "aaa", price => "piyopiyo" });
    is $ret->has_error, 1;
    is_deeply $ret->valid_data, { name  => 'aaa' };
    is_deeply $ret->errors,     { price => '「価格」は数値で入力してください。' };
}
{
    ## all valid pattern
    my $ret = $v->validate_all({ name => "aaa", price => "123" });
    is $ret->has_error, '';
    is_deeply $ret->valid_data, { name => 'aaa', price => 123 };
    is_deeply $ret->errors, {};
}
