#!/usr/bin/env ruby

require 'csv'
require 'i18n'
require 'json'

def normalize(input)
  input.unicode_normalize(:nfc).downcase.strip.gsub(/[-<>†*";.,\]\[_(){}&:^·\\=0-9]/,'')
end

headwords = {}
ARGV.each do |csv_file|
  $stderr.puts csv_file
  prefix = File.basename(csv_file,'-headwords.csv')
  File.foreach(csv_file) do |line|
    components = line.split(',')
    ref = components[0]
    headword = components[1..-1].join(',')
    normalized_headword = normalize(headword)
    
    headwords[normalized_headword] ||= {}
    headwords[normalized_headword][prefix] = ref
  end
end

puts headwords.to_json
