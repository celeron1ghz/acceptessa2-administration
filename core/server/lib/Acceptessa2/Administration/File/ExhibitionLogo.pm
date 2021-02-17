package Acceptessa2::Administration::File::ExhibitionLogo;
use strictures 2;
use Mouse;
use Function::Parameters;
use Function::Return;
use Syntax::Keyword::Try;
use Acceptessa2::Administration::Types -types;
use Image::Size;
use namespace::clean;

with 'Acceptessa2::Administration::Role::File';

method validate() {
    if (!-r $self->file) {
        return { error => 'file not exist' };
    }

    if (-s $self->file > 5_000_000) {
        return { error => 'file too large' };
    }

    open my $fh, $self->file or die $self->file . " " . $!;
    local $/;
    my $content = <$fh>;
    close $fh;

    my ($w, $h, $type) = imgsize(\$content);

    if ($w / $h != 2) {
        return { error => 'width/height ratio should 2' };
    }

    return { success => 1 };
}

1;
