#!/bin/bash
TEMPLATE_DIR="templates"
MAKEFILE="Makefile"

# Récupère tous les dossiers dans templates
folders=()
while IFS= read -r -d $'\0' dir; do
    folder_name=$(basename "$dir")
    folders+=("$folder_name")
done < <(find "$TEMPLATE_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

# Génère le Makefile
{
    # PHONY
    echo -n ".PHONY: help "
    for f in "${folders[@]}"; do
        echo -n "$f "
    done
    echo "all"
    echo

    # Cible help par défaut
    echo "help:"
    echo -e "\t@echo \"Usage: make <target>\""
    echo -e "\t@echo \"\""
    echo -e "\t@echo \"Available targets:\""
    for f in "${folders[@]}"; do
        echo -e "\t@echo \"  $f\""
    done
    echo -e "\t@echo \"  all\""
    echo -e "\t@echo \"\""
    echo -e "\t@echo \"Example: make windows10-22h2-x64-server\""
    echo -e "\t@echo \"         make all\""
    echo

    # Cible all
    echo -n "all:"
    for f in "${folders[@]}"; do
        echo -n " $f"
    done
    echo
    echo

    # Chaque template
    for f in "${folders[@]}"; do
        echo "$f:"
        echo -e "\tpacker init $TEMPLATE_DIR/$f"
        echo -e "\tpacker validate $TEMPLATE_DIR/$f"
        echo -e "\tpacker build $TEMPLATE_DIR/$f"
        echo
    done
} > "$MAKEFILE"

echo "Makefile généré avec succès pour ${#folders[@]} templates, avec aide intégrée."
