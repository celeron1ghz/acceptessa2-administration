use utf8;
use strict;
use Test::More;
use Test::Exception;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;

plan tests => 9;

{
    throws_ok {
        Acceptessa2::Administration::Validator::Column->new(
            {
                column_name => 'name',
                label       => '名前',
                type        => Str,
                description => 'なまえ',
                moge        => 'fuga',
            }
        )
    }
    qr/^Unknown attribute passed to the constructor of Acceptessa2::Administration::Validator::Column: moge/, 'die on specify non-required column';
}
{
    my $c = Acceptessa2::Administration::Validator::Column->new(
        {
            column_name => 'name',
            label       => '名前',
            type        => Str,
            description => 'なまえ',
        }
    );

    is $c->validate(undef),  '';
    is $c->validate("moge"), 1;
    is $c->get_error_message(), "「名前」は文字列で入力してください。";
}
{
    my $c = Acceptessa2::Administration::Validator::Column->new(
        {
            column_name => 'price',
            label       => '価格',
            type        => Int,
            description => 'かかく',
        }
    );

    is $c->validate(undef),  '';
    is $c->validate("moge"), '';
    is $c->validate("1"),    1;
    is $c->validate("1.1"),  '';
    is $c->get_error_message(), "「価格」は数値で入力してください。";
}
