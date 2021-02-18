package Acceptessa2::Administration::Command::Circle::Create;
use strictures 2;
use feature 'state';
use Mouse;
use Function::Parameters;
use Function::Return;
use Syntax::Keyword::Try;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;
use namespace::clean;

with 'Acceptessa2::Administration::Role::Command';

has exhibition_id => (is => 'ro', isa => Str,     required => 1);
has data          => (is => 'ro', isa => HashRef, required => 1);

method run() {
    my $v   = $self->ctx->get_validator($self->exhibition_id);
    my $ret = $v->validate_all($self->data);

    if ($ret->has_error) {
        return { error => $ret->errors };
    }

    my $param = {};

    while (my ($k, $v) = each %{ $ret->valid_data }) {
        $param->{$k} = { S => $v };
    }

    try {
        my $ret = $self->ctx->dynamodb->PutItem(
            TableName           => 'acceptessa2-circle',
            ConditionExpression => 'attribute_not_exists(id)',
            Item                => $param,
        );

        return { message => 'success' };
    }
    catch ($e) {
        return { error => 1, message => 'create failed', raw_message => $e };
    }
}

1;
