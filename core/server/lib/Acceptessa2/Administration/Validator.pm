package Acceptessa2::Administration::Validator;
use strictures 2;
use Moose;
use Function::Parameters;
use Function::Return;
use Syntax::Keyword::Try;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has validators => (is => 'ro', isa => Map[Str, InstanceOf['Acceptessa2::Administration::Validator::Column']], required => 1);

method build(ArrayRef[HashRef] $params): Return(InstanceOf[__PACKAGE__]) {
    my $columns;
    my $idx = 0;
    my $type;

    try {
        for my $p (@$params) {
            $type = $p->{type};
            if ($type && !ref $type) {
                $p->{type} = Acceptessa2::Administration::Types->meta->get_type($type) or die;
            }

            my $v = Acceptessa2::Administration::Validator::Column->new(%$p);
            $columns->{$v->column_name} = $v;
            $idx++;
        }
    } catch ($e) {
        if ($e->isa('Moose::Exception')) {
            my $mess = $e->message;
            die "invalid format: $mess in columns[$idx]\n";
        } else {
            die "invalid format: unknown type '$type' in columns[$idx]\n";
        }
    }

    return $self->new(validators => $columns);
}

method get_validator(Str $column) {
    return $self->validators->{$column};
}

method validate_all(Map[Str, Str] $data) {
    my $errors = {};
    my $valid_data = {};

    while (my($col,$v) = each %{$self->validators}) {
        if ($v->validate($data->{$col})) {
            $valid_data->{$col} = $data->{$col};
        }else {
            $errors->{$col} = $v->get_error_message();
        }
    }

    return Acceptessa2::Administration::Validator::Result->new(
        errors     => $errors,
        valid_data => $valid_data,
    );
}

1;

package Acceptessa2::Administration::Validator::Result;
use strictures 2;
use Moose;
use MooseX::StrictConstructor;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has valid_data => (is => 'ro', isa => HashRef, required => 1);
has errors => (is => 'ro', isa => HashRef, required => 1);

method has_error() {
    return !!keys %{$self->errors};
}

1;

package Acceptessa2::Administration::Validator::Column;
use utf8;
use strictures 2;
use Moose;
use MooseX::StrictConstructor;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use namespace::clean;

has type => (is => 'ro', isa => InstanceOf['Type::Tiny'], required => 1);
has column_name => (is => 'ro', isa => Str, required => 1);
has label       => (is => 'ro', isa => Str, required => 1);
has description => (is => 'ro', isa => Str, required => 0);

my $MESSAGE = {
    "Str"           => "「%s」は文字列で入力してください。",
    "Int"           => "「%s」は数値で入力してください。",
    "PositiveInt"   => "「%s」は正の整数で入力してください。",
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
