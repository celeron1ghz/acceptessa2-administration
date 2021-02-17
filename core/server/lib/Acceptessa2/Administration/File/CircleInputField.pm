package Acceptessa2::Administration::File::CircleInputField;
use strictures 2;
use Mouse;
use Function::Parameters;
use Function::Return;
use Syntax::Keyword::Try;
use Acceptessa2::Administration::Types -types;
use TOML;
use Acceptessa2::Administration::Validator;
use namespace::clean;

with 'Acceptessa2::Administration::Role::File';

method validate() {
    if (!-r $self->file) {
        return { error => 'file not exist' };
    }

    open my $fh, $self->file or die $self->file . " " . $!;
    local $/;
    my $content = <$fh>;
    close $fh;

    my $data    = from_toml($content);
    my $columns = $data->{columns};

    if (ref $columns ne 'ARRAY') {
        return { error => 'invalid format: key "columns" not exist' };
    }

    # use Data::Dumper;
    # warn Data::Dumper->Dump([$data]);

    try {
        Acceptessa2::Administration::Validator->build($data->{columns});
    }
    catch ($e) {
        chop $e;
        return { error => $e };
    }

    return { success => 1 };
}

1;
