#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'i18n'

ID_MAX = 150000
URL_PREFIX = 'http://dictionaries.brillonline.com/document?source=montanari&highlight=&docid='

def normalize(input)
  input.strip.unicode_normalize(:nfc).sub(/^\d+\. +/,'').tr('()','')
end

index = 27684

begin
  page = Nokogiri::HTML(open("#{URL_PREFIX}#{index}"))
  headword = page.css('.articlecontent > p > b:first-child > text()').text.split(/[*&,]/).first
  unless headword.nil? || (headword.length == 0)
    if headword =~ /[()]/
      puts "#{index},#{normalize(headword.gsub(/\(.*?\)/,''))}"
    end
    puts "#{index},#{normalize(headword)}"
    STDOUT.flush
  end
  index += 1
  sleep 1
rescue Exception => e
  $stderr.puts e.inspect
  sleep 60
  retry
end until (index > ID_MAX)
