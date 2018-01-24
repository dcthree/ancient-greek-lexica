all: data/headwords.json data/all_headwords_unique.csv

data/headwords.json: _scripts/headwords2json.rb data/*-headwords.csv Gemfile.lock
	bundle exec ./_scripts/headwords2json.rb data/*-headwords.csv > data/headwords.json

data/all_headwords_unique.csv: data/headwords.json
	jq 'keys[]' data/headwords.json | sed -e 's/^"//' -e 's/"$$//'| sort -u > data/all_headwords_unique.csv

Gemfile.lock: Gemfile
	bundle update
	bundle install

.PHONY: all clean
clean:
	rm -v data/headwords.json data/all_headwords_unique.csv
