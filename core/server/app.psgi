use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;

our $VERSION = '0.13';

# sub load_config {
#     my $c    = shift;
#     my $mode = $c->mode_name || 'development';

#     +{ 'DBI' => [ "dbi:SQLite:dbname=$mode.db", '', '', ], };
# }

get '/' => sub {
    my $c = shift;
    return $c->render_json({ hello => "world" });
};

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ($c, $res) = @_;
        my $cookies = $c->req->cookies;

        if (my $cookie = $cookies->{acceptessa2}) {
            warn $cookie;
        }
        else {
            return $c->create_response(403, [], '403 Forbidden');
        }
    }
);

__PACKAGE__->load_plugin('Web::JSON');

__PACKAGE__->to_app(handle_static => 1);
