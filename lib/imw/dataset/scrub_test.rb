#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'scrub'
require 'scrub_simple_url'

test_strings = [
  nil, '', '12', '123', 'simple', 'UPPER', 'CamelCased', 'iden_tifier_23_',
  'twentyfouralphacharslong', 'twentyfiveatozonlyletters', 'hello.-_there@funnychar.com',
  "tab\t", "newline\n",
  "Iñtërnâtiônàlizætiøn",
  'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space ',
  'leftanglebracket<', 'ampersand&',
  "control char-bel\x07",
  "http://foo.bar.com/",
  "HTTP://FOO.BAR.com",
  ".com/zazz",
  "scheme://user_name@user_acct:passwd@host-name.museum:9047/path;pathquery/p!a-th~2/path?query=param&amp;query=pa%20ram#fragment",
  "http://web.site.com/path/path/file.ext",
  "ftp://ftp.site.com/path/path/file.ext",
  "/absolute/pathname/file.ext",
  "http://foo.bar.com/.hidden_file_with.ext",
  "http://foo.bar.com/.hidden_file",
  "dir/--/non_alpha_path_segment.ext",
  "http://foo.bar.com/dir/../two_dots_in_path",

]


scrubbers = {
  # :unicode_title   => Scrub::UnicodeTitle.new,
  # :title           => Scrub::Title.new,
  # :identifier      => Scrub::Identifier.new,
  # :free_text       => Scrub::FreeText.new,
  :uniqname        => Scrub::Uniqname.new,
  :simplified_url  => Scrub::SimplifiedURL.new,
  # :domain        => Scrub::Domain.new,
  # :email         => Scrub::Email.new,
}

scrubbers.each do |scrubber_name, scrubber|
  puts scrubber_name
  results = test_strings.map do |test_string|
    [!!scrubber.valid?(test_string), scrubber.sanitize(test_string).inspect, test_string.inspect ]
  end
  results.sort_by{|val,san,orig| val ? 1 : -1 }.each do |val,san,orig|
    puts "  %-5s %-30s %-30s" % [val,san,orig]
  end
end



# 'foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
#         'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
#         'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
#         'domain@can.haz.many.sub.doma.in',],
#       :invalid => [nil, '', '!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
#         'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
#         'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
#         # these are technically allowed but not seen in practice:
#         'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'
