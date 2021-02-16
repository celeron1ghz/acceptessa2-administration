package Acceptessa2::Administration::Command::Exhibition::Create;
use strictures 2;
use Mouse;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use Syntax::Keyword::Try;
use namespace::clean;

with 'Acceptessa2::Administration::Role::Command';

has exhibition_id   => (is => 'ro', isa => Str, required => 1);
has exhibition_name => (is => 'ro', isa => Str, required => 1);

method run() {
    try {
        my $ret = $self->ctx->dynamodb->PutItem(
            TableName           => 'acceptessa2-exhibition',
            ConditionExpression => 'attribute_not_exists(id)',
            Item                => {
                id              => { S => $self->exhibition_id },
                exhibition_name => { S => $self->exhibition_name },
            },
        );

        return { message => 'success' };
    }
    catch ($e) {
        return { error => 1, message => 'create failed', raw_message => $e };
    };
}

1;
