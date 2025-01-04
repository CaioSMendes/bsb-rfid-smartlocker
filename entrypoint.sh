#!/bin/bash
# Apaga o banco de dados existente
bundle exec rake db:drop
# Cria o banco de dados novamente
bundle exec rake db:create
# Realiza migrações
bundle exec rake db:migrate
# Carrega os dados do seed
bundle exec rake db:seed
# Inicia o servidor Rails
bundle exec rails s -b '0.0.0.0'