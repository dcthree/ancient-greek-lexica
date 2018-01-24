#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'i18n'

URL_PREFIX = 'http://www.aristarchus.unige.net/Wordsinprogress/it-it/Database/View/'

index = 1

begin
  page = Nokogiri::HTML(open("#{URL_PREFIX}#{index}"))
  headword = page.css('.ibox-title > h2 > strong > text()').text.split(/[-‑*&,]/).first
  unless headword.nil? || (headword.length == 0)
    puts "#{index},#{headword.strip.unicode_normalize(:nfc)}"
    STDOUT.flush
  end
  index += 1
end until (index > 2000)
