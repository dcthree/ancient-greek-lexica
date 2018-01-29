#!/usr/bin/env ruby

require 'i18n'

ARGF.each_line do |line|
  puts line.unicode_normalize(:nfd).tr("\u{0306}\u{0304}",'').unicode_normalize(:nfc)
end
