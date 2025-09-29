# 🔒 Script d’audit SELinux avec audit2allow

Ce projet propose un script Bash qui **analyse les refus SELinux** liés à des processus spécifiques et génère automatiquement des **règles permissives locales** grâce à `audit2allow`.

---

## ✨ Fonctionnalités

- 📋 Lecture d’un fichier de politique (`policy.txt`) listant les processus et chemins associés  
- 🔍 Analyse des refus SELinux via `ausearch`  
- 🖊️ Génération de modules `.pp` locaux pour assouplir les permissions  
- 📑 Rapport centralisé (`rapport.log`) clair et lisible  
- 🎨 **Affichage coloré** pour plus de clarté :
  - 🔴 **Rouge** : refus SELinux détectés  
  - 🟢 **Vert** : aucun refus détecté  
  - 🟡 **Jaune** : génération de règles locales  
  - 🔵 **Bleu** : étapes et titres importants  

---

## 🛠️ Prérequis

Avant utilisation, assurez-vous d’avoir :  
```bash
sudo apt update
sudo apt install selinux-basics selinux-policy-default auditd policycoreutils-python-utils -y
````

Activez ensuite **SELinux** en mode `enforcing` ou `permissive` selon vos besoins.

---

## 🚀 Utilisation

1. Préparez un fichier `policy.txt` : (par exemple)

   ```
   httpd:/var/www/html
   mysqld:/var/lib/mysql
   ```

2. Lancez le script :

   ```bash
   ./script.sh policy.txt
   ```

3. Exemple de sortie :

   ```
   Chargement de la politique depuis policy.txt
   Processus disponibles :
   - httpd:/var/www/html
   - mysqld:/var/lib/mysql

   === Analyse des refus SELinux ===
   Aucun refus SELinux détecté pour httpd:/var/www/html
   Refus SELinux détecté pour mysqld:/var/lib/mysql
   Règle SELinux locale générée : mysqld_local.pp

   Analyse terminée. Rapport complet enregistré dans rapport.log
   ```

---

## 📊 Schéma du fonctionnement

```
+-------------+       +-------------+       +-------------+       +-------------+
|  Processus  |  -->  |   Refus     |  -->  |  audit2allow |  -->  |  Règle .pp  |
|  (policy)   |       |   SELinux   |       |  Génération  |       |  locale     |
+-------------+       +-------------+       +-------------+       +-------------+
                              |
                              v
                        +-------------+
                        |  Rapport    |
                        | rapport.log |
                        +-------------+
```

---

## ⚠️ Bonnes pratiques

* Exécuter le script avec un fichier de politique valide
* Vérifier que `auditd` est actif pour capturer les logs
* Tester les règles générées avant de les appliquer en production

---

## 📚 Licence

Projet libre sous licence MIT.
