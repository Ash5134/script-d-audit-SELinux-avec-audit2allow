#!/bin/bash
# ---------------------------------------
# 1. Définition des couleurs pour l'affichage
# ---------------------------------------
RED='\033[0;31m'    # Rouge pour les erreurs ou refus SELinux
GREEN='\033[0;32m'  # Vert pour indiquer qu'aucun refus n'a été détecté
YELLOW='\033[1;33m' # Jaune pour les messages informatifs comme la génération de règles
BLUE='\033[0;34m'   # Bleu pour les titres et étapes importantes
NC='\033[0m'        # Aucune couleur, pour réinitialiser l'affichage
# ---------------------------------------
# 2. Lecture du fichier de politique fourni en argument
# ---------------------------------------
POLICY_FILE=$1 # Je récupère le premier argument, qui doit être le fichier de politique
if [[ -z "$POLICY_FILE" ]]; then
  # Si aucun fichier n'est fourni, j'affiche un message d'erreur et je quitte le script
  echo -e "${RED}Erreur : Aucun fichier de politique fourni.${NC}"
  exit 1
fi
echo -e "${BLUE}Chargement de la politique depuis $POLICY_FILE${NC}"
# ---------------------------------------
# 3. Lecture des processus depuis le fichier politique
# ---------------------------------------
declare -A PROCESSES # Je crée un tableau associatif pour stocker les processus et leurs chemins
while IFS=: read -r name paths; do
  # Pour chaque ligne du fichier, je sépare le nom du processus et ses chemins
  PROCESSES["$name"]="$paths"
done <"$POLICY_FILE"
# J'affiche la liste des processus disponibles pour que l'utilisateur puisse vérifier
echo -e "\nProcessus disponibles dans $POLICY_FILE :"
for p in "${!PROCESSES[@]}"; do
  echo "- $p:${PROCESSES[$p]}"
done
# ---------------------------------------
# 4. Choix d'un processus spécifique à scanner
# ---------------------------------------
read -p $'\nVoulez-vous scanner un processus spécifique ? (laisser vide pour tous) : ' CHOICE
# Si l'utilisateur laisse vide, tous les processus seront analysés
# ---------------------------------------
# 5. Préparation du fichier de rapport
# ---------------------------------------
REPORT_FILE="rapport.log"
echo "" >"$REPORT_FILE" # Je vide le fichier avant de commencer l'analyse
echo -e "\n${BLUE}=== Analyse des refus SELinux ===${NC}"
# ---------------------------------------
# 6. Boucle sur les processus pour analyser les refus
# ---------------------------------------
for process in "${!PROCESSES[@]}"; do
  # Si un processus spécifique a été choisi et qu'il ne correspond pas à celui de la boucle, je passe au suivant
  if [[ -n "$CHOICE" && "$process" != "$CHOICE" ]]; then
    continue
  fi
  PATHS="${PROCESSES[$process]}" # Je récupère les chemins associés au processus
  # ---------------------------------------
  # 7. Vérification des refus SELinux pour ce processus
  # ---------------------------------------
  REFUS=$(ausearch -m avc -c "$process" 2>/dev/null) # Je recherche les logs AVC pour ce processus
  if [[ -z "$REFUS" ]]; then
    # Aucun refus détecté
    echo -e "${GREEN} Aucun refus SELinux détecté pour $process:$PATHS${NC}"
    echo "Aucun refus SELinux détecté pour $process:$PATHS" >>"$REPORT_FILE"
  else
    # Refus détecté, je l'affiche et je l'enregistre dans le rapport
    echo -e "${RED} Refus SELinux détecté pour $process:$PATHS${NC}"
    echo "$REFUS" >>"$REPORT_FILE"
    # ---------------------------------------
    # 8. Génération d'une règle permissive locale avec audit2allow
    # ---------------------------------------
    echo "$REFUS" | audit2allow -M "${process}_local" 2>/dev/null
    echo -e "${YELLOW} Règle SELinux locale générée : ${process}_local.pp${NC}"
  fi
done
# ---------------------------------------
# 9. Fin de l'analyse
# ---------------------------------------
echo -e "\n${BLUE}Analyse terminée. Rapport complet enregistré dans $REPORT_FILE.${NC}"
