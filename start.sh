#!/bin/sh
chown -R deploy_user:deploy_group /app/public/assets
chmod -R 755 /app/public/assets

echo "Limpando caches antes de iniciar o serviço..."

# Limpar cache do DNS
sudo systemd-resolve --flush-caches

# Limpar cache do sistema
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches

# Limpar cache do compilador
ccache -C

# Limpar cache do Rails
bundle exec rake tmp:cache:clear

# Reiniciar Nginx (caso esteja rodando no container)
sudo service nginx restart || echo "Nginx não encontrado, ignorando..."

# Remove o arquivo server.pid se ele existir
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Verifica e instala as Gems necessárias
bundle check || bundle install

echo "Caches limpos! Subindo a aplicação..."

# Verifica se o setup inicial deve ser executado
if [ "$FIRST_TIME_SETUP" = "true" ]; then
  echo "Executando a configuração inicial: db:create, db:migrate, db:seed"
  bundle exec rails db:drop db:create db:migrate db:seed || true
else
  echo "Pulado a configuração inicial."
  
  # Executa as migrações e o seed, ignorando erros
  echo "Rodando migrações e seed (ignorando erros)..."
  bundle exec rails db:migrate || true
  bundle exec rails db:seed || true
fi

# Inicia o servidor Puma
exec bundle exec puma -C config/puma.rb
