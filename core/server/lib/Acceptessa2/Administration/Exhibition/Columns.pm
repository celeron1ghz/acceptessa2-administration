package Acceptessa2::Administration::Exhibition::Columns;
use strictures 2;
use feature 'state';
use Mouse;
use Function::Parameters;
use Function::Return;
use Acceptessa2::Administration::Types -types;
use Acceptessa2::Administration::Validator;
use namespace::clean;

my $COLUMNS = [
    {
        column_name => 'exhibition_name',
        label       => '即売会名',
        type        => Str,
        description => '即売会の正式名称',
    },
    {
        column_name => 'register_id',
        label       => '申込時の即売会ID',
        type        => Str,
        description => 'サークル申し込みで使われる即売会ID（推測を防ぐため）',
    },
    {
        column_name => 'exhibition_date',
        label       => '即売会の日付',
        type        => Str,
        description => '即売会当日の日付を設定します',
    },
    {
        column_name => 'enable',
        label       => '即売会を有効にする',
        type        => Bool,
        description => '即売会を無効にすると追加変更が不可能となり、閲覧のみ行えます。',
    },
    {
        column_name => 'enable_register',
        label       => '申込を有効にする',
        type        => Bool,
        description => 'オンにするとサークルの参加登録ページが利用できるようになります',
    },
    {
        column_name => 'enable_checklist',
        label       => 'チェックリストを有効にする',
        type        => Bool,
        description => 'オンにするとチェックリストが利用できるようになります',
    },
    {
        column_name => 'tweet_register',
        label       => 'サークル参加登録完了時のツイートの文言',
        type        => Str,
        description => '',
    },
    {
        column_name => 'tweet_circlecut',
        label       => 'サークルカットアップロード時のツイートの文言',
        type        => Str,
        description => '',
    },
    {
        column_name => 'homepage',
        label       => 'ホームページ',
        type        => Uri,
        description => '即売会のトップページへのリンク',
    },
];

method validator() {
    state $VALIDATOR = Acceptessa2::Administration::Validator->build($COLUMNS);
    $VALIDATOR;
}

1;
