package Acceptessa2::Administration::Command::Exhibition::Update;
use strictures 2;
use Mouse;
use Function::Parameters;
use Function::Return;
use Syntax::Keyword::Try;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Exhibition::Columns;
use namespace::clean;

with 'Acceptessa2::Administration::Role::Command';

has id  => (is => 'ro', isa => Str, required => 1);
has key => (is => 'ro', isa => Str, required => 1);
has value => (is => 'ro', isa => Any);

method run() {
    my $v = Acceptessa2::Administration::Exhibition::Columns->validator->get_validator($self->key)
      or return { error => 1, message => "invalid key" };

    $v->validate($self->value)
      or return { error => 1, message => "validation failed" };

    try {
        my $ret = $self->ctx->dynamodb->UpdateItem(
            TableName                 => 'acceptessa2-exhibition',
            ExpressionAttributeNames  => { "#KEY" => $self->key },
            ExpressionAttributeValues => { ":VAL" => { S => $self->value } },
            Key                       => { "id" => { S => $self->id } },
            ReturnValues              => "ALL_NEW",
            UpdateExpression          => "SET #KEY = :VAL",
            ConditionExpression       => 'attribute_exists(id)',
        );

        return { message => 'success' };
    }
    catch ($e) {
        return { error => 1, message => "update failed", raw_message => $e };
    }
}

1;
