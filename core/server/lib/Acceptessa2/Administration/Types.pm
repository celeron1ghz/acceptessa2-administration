package Acceptessa2::Administration::Types;
use strictures 2;

use Type::Library -base;
use Type::Utils -all;

BEGIN {
    extends qw(
      Types::Standard
      Types::Common::Numeric
      Types::Common::String
      Types::URI
    );
}

1;
