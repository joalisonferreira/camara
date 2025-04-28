#!/bin/bash

# Mensagem automática de commit com data e hora
COMMIT_MESSAGE="Update - $(date '+%Y-%m-%d %H:%M:%S')"

echo "Adicionando arquivos..."
git add .

echo "Commitando alterações com mensagem: $COMMIT_MESSAGE"
git commit -m "$COMMIT_MESSAGE"

echo "Enviando para o GitHub..."
git push origin main

echo "Atualização finalizada com sucesso!"

