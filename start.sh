#!/bin/sh
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi
# Instala as Gems
bundle check || bundle install

# Check if the database needs to be set up
if [ "$FIRST_TIME_SETUP" = "true" ]; then
  echo "Running first time setup: db:create, db:migrate, db:seed"
  bundle exec rails db:create db:migrate db:seed
else
  echo "Skipping first time setup."
fi

# Roda nosso servidor
bundle exec puma -C config/puma.rb