# Use uma imagem base com Ruby e Node.js
FROM ruby:3.1.2

# Instalar dependências
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Definir o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copiar o Gemfile e o Gemfile.lock para instalar as gems
COPY Gemfile Gemfile.lock ./ 

# Instalar as dependências do Bundler
RUN bundle install

# Copiar o código da aplicação para o diretório de trabalho
COPY . .

# Definir a variável de ambiente para servir arquivos estáticos
ENV RAILS_SERVE_STATIC_FILES=true

# Pré-compilar os assets para produção
RUN bundle exec rake assets:clobber
RUN bundle exec rake assets:precompile

# Copiar o entrypoint.sh e dar permissões de execução
COPY start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

# Expôr a porta que o Rails usará
EXPOSE 3000

# Definir o entrypoint para o script
ENTRYPOINT ["/usr/bin/start.sh"]

# Rodar o servidor do Rails
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && rails server -b 0.0.0.0"]
