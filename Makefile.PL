use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::TestBase;
name 'HTML-QRCode';
all_from 'lib/HTML/QRCode.pm';

requires 'Carp';
requires 'Text::QRCode';

resources repository => 'https://github.com/hidek/HTML-QRCode';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
