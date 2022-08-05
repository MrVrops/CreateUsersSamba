#!/bin/bash

#Génération d'un mot de passe aléatoire pour chaque utilisateur avec 15 caractères alphanumériques
while read line
do
mdp=`tr -cd '[:alnum:]' < /dev/urandom | fold -w15 | head -n1`
echo $line $mdp >> samba
done < utilisateur

#Récupération des mot de passe des différents utilisateurs
cut -d ':' -f1,4 samba >> motdepassesamba.txt


#Création des comptes unix sans mots de passe avec leur répertoire individuel dans samba, affectation des groupes pour les utilisateurs, configuration du mot de passe des comptes samba pour chaque utilisateurs
while IFS=':' read nom_unix group nom_samba pass
do
    adduser --gecos "$nom_unix" --shell /bin/false --disabled-login --home "/home/sharing/$nom_samba" $nom_unix
    [ $? -eq 0 ] && echo "Utilisateur créé $nom_unix" || echo "Échec de la création de l'utilisateur $nom_unix"
    adduser $nom_unix $group
    [ $? -eq 0 ] && echo "Utilisateur $nom_unix ajouté au groupe $group" || echo "Echec de l'ajout de l'utilisateur $nom_unix au groupe $group"
    echo "$nom_unix:$pass" | chpasswd 
    [ $? -eq 0 ] && echo "Mot de passe de l'utilisateur $nom_unix configuré" || echo "Échec de la confihuration du mot de passe de l'utilisateur $nom_unix"
    echo -n "$pass\n$pass\n" | /usr/bin/smbpasswd -s -a $nom_unix
    [ $? -eq 0 ] && echo "Mot de passe samba configuré pour $nom_unix" || echo "Échec de la configuration du mot de passe samba pour $nom_unix"
    adduser $nom_unix sharing
    [ $? -eq 0 ] && echo "Utilisateur $nom_unix ajouté au samba" || echo "Échec de l'ajout de l'utilisateur $nom_unix au samba"
done < samba
