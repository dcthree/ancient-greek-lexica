data/headwords.json: _scripts/headwords2json.rb data/*-headwords.csv Gemfile.lock
	bundle exec ./_scripts/headwords2json.rb data/*-headwords.csv > data/headwords.json

Gemfile.lock: Gemfile
	bundle update
	bundle install
