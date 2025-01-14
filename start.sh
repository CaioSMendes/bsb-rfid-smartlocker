#!/bin/sh
# Remove o arquivo server.pid se ele existir
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Verifica e instala as Gems necessárias
bundle check || bundle install

# Verifica se o setup inicial deve ser executado
if [ "$FIRST_TIME_SETUP" = "true" ]; then
  echo "Executando a configuração inicial: db:create, db:migrate, db:seed"
  bundle exec rails db:create db:migrate db:seed || true
else
  echo "Pulado a configuração inicial."
  
  # Executa as migrações e o seed, ignorando erros
  echo "Rodando migrações e seed (ignorando erros)..."
  bundle exec rails db:migrate || true
  bundle exec rails db:seed || true
fi

# Inicia o servidor Puma
exec bundle exec puma -C config/puma.rb
