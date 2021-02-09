package Acceptessa2::Administration::Validator;
use strictures 2;
use Mouse;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has validators => (is => 'ro', isa => Map[Str, InstanceOf['Acceptessa2::Administration::Validator::Column']], required => 1);

method build(ArrayRef[HashRef] $params): Return(InstanceOf[__PACKAGE__]) {
    my $columns;

    for my $p (@$params) {
        my $v = Acceptessa2::Administration::Validator::Column->new(%$p);
        $columns->{$v->column_name} = $v;
    }

    return $self->new(validators => $columns);
}

method validate_single(Str $column, Maybe [Str] $value) {
    my $v = $self->validators->{$column} or return;
    return $v->validate($value);
}

method validate_all(Map[Str, Str] $data) {

}

1;

package Acceptessa2::Administration::Validator::Column;
use utf8;
use strictures 2;
use Mouse;
use MouseX::StrictConstructor;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has type => (is => 'ro', isa => InstanceOf['Type::Tiny'], required => 1);
has column_name => (is => 'ro', isa => Str, required => 1);
has label       => (is => 'ro', isa => Str, required => 1);
has description => (is => 'ro', isa => Str, required => 0);

my $MESSAGE = {
    Str => "「%s」は文字列で入力してください。",
    Int => "「%s」は数値で入力してください。",
};

method validate(Maybe [Str] $val): Return(Bool) {
    !!$self->type->check($val);
}

method get_error_message(): Return(Str) {
    my $type = $self->type->name;
    my $mess = $MESSAGE->{$type} or die "no message for $type";
    return sprintf $mess, $self->label;
}

1;
