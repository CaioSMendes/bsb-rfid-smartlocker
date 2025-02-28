#!/bin/bash

# Define o diretório do PostgreSQL
POSTGRES_DIR="postgres/data/"

# Verifica se o diretório existe
if [ -d "$POSTGRES_DIR" ]; then
    echo "Verificando permissões para o diretório $POSTGRES_DIR..."
    
    # Verifica as permissões do diretório
    ls -ld $POSTGRES_DIR

    # Altera as permissões para leitura e escrita
    echo "Alterando permissões para leitura e escrita..."
    sudo chmod -R 755 $POSTGRES_DIR

    # Altera a propriedade para o usuário atual
    echo "Alterando a propriedade do diretório para o usuário atual..."
    sudo chown -R $(whoami) $POSTGRES_DIR

    # Atualiza o arquivo .gitignore para garantir que o diretório seja ignorado
    echo "Atualizando .gitignore para ignorar o diretório $POSTGRES_DIR..."
    echo "$POSTGRES_DIR" >> .gitignore

    # Adiciona as mudanças ao git
    echo "Adicionando as mudanças ao git..."
    git add .gitignore
    git commit -m "Ignorar diretório postgres/data/ e corrigir permissões"
    
    echo "Correção concluída!"
else
    echo "O diretório $POSTGRES_DIR não foi encontrado!"
fi