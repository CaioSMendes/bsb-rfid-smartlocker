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

# Copiar o entrypoint.sh e dar permissões de execução
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Definir o entrypoint para o script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Expôr a porta que o Rails usará
EXPOSE 3000

# Rodar o servidor do Rails
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && rails server -b 0.0.0.0"]
