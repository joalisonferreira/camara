#!/bin/bash

echo "🔍 Iniciando verificação de segurança dos arquivos do WordPress..."

# Lista de arquivos sensíveis
ARQUIVOS_SENSIVEIS=(
  "wp-config.php"
  ".env"
  ".htaccess"
  "error_log"
  "phpinfo.php"
  "dump.sql"
  "backup.sql"
  "*.zip"
  "*.tar"
  "*.gz"
  "*.bak"
)

PROBLEMAS_ENCONTRADOS=false
ARQUIVOS_REMOVIDOS=()

# Verifica e remove do Git (mantendo local)
for file in "${ARQUIVOS_SENSIVEIS[@]}"; do
  matches=$(git ls-files "$file")
  if [ -n "$matches" ]; then
    for matched_file in $matches; do
      echo "⚠️  Removendo $matched_file do Git (mantendo local)..."
      git rm --cached "$matched_file"
      echo "$matched_file" >> .gitignore
      ARQUIVOS_REMOVIDOS+=("$matched_file")
      PROBLEMAS_ENCONTRADOS=true
    done
  fi
done

# Commit das alterações imediatas
if $PROBLEMAS_ENCONTRADOS; then
  echo -e "\n📄 Atualizando .gitignore e comitando mudanças..."
  git add .gitignore
  git commit -m "Remoção de arquivos sensíveis e atualização do .gitignore"
fi

# Reescrevendo o histórico Git se necessário
if [ ${#ARQUIVOS_REMOVIDOS[@]} -gt 0 ]; then
  echo -e "\n🧹 Reescrevendo histórico Git para apagar arquivos antigos..."
  for sensitive_file in "${ARQUIVOS_REMOVIDOS[@]}"; do
    git filter-branch --force --index-filter \
      "git rm --cached --ignore-unmatch '$sensitive_file'" \
      --prune-empty --tag-name-filter cat -- --all
  done

  echo -e "\n🧽 Limpando cache e reflogs..."
  rm -rf .git/refs/original/
  git reflog expire --expire=now --all
  git gc --prune=now --aggressive

  echo -e "\n🚀 Enviando mudanças com --force..."
  git push origin --force --all
  git push origin --force --tags
fi

# Final
if $PROBLEMAS_ENCONTRADOS; then
  echo -e "\n✅ Processo concluído: arquivos sensíveis foram removidos e histórico reescrito."
  echo -e "🔐 Lembre-se de trocar senhas/credenciais que possam ter sido expostas!"
else
  echo "✅ Nenhum arquivo sensível encontrado. Tudo certo!"
fi

