package Acceptessa2::Administration::Validator;
use strictures 2;

sub build {

}

sub validate_single {

}

sub validate_all {

}

1;

package Acceptessa2::Administration::Validator::Column;
use utf8;
use strictures 2;
use Mouse;
use Syntax::Keyword::Try;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has column_name => (is => 'ro', isa => 'Str',        required => 1);
has label       => (is => 'ro', isa => 'Str',        required => 1);
has type        => (is => 'ro', isa => 'Type::Tiny', required => 1);
has description => (is => 'ro', isa => 'Str',        required => 0);

my $MESSAGE = {
    Str => "「%s」は文字列で入力してください。",
    Int => "「%s」は数値で入力してください。",
};

method validate(Maybe [Str] $val) {
    $self->type->check($val);
}

method get_error_message() {
    my $type = $self->type->name;
    my $mess = $MESSAGE->{$type} or die "no message for $type";
    return sprintf $mess, $self->label;
}

1;
