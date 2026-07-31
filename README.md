Auto HDR Direct3D Registry Manager est un outil Windows permettant de gérer facilement les profils Auto HDR de Windows 11 pour les jeux Direct3D.

L'outil automatise la création et la gestion des entrées registre utilisées par Windows Auto HDR afin de permettre l'activation du mode HDR automatique pour les jeux qui ne sont pas détectés nativement.

Fonctionnalités
Interface graphique Windows Forms simple et légère.
Ajout automatique d'un jeu dans les profils Direct3D.
Support des jeux :
Steam
Epic Games
Xbox Game Pass / Microsoft Store
Détection des entrées existantes pour éviter les doublons.
Mise à jour d'une configuration existante.
Suppression des profils Auto HDR existants.
Choix du comportement Auto HDR :

Mode compatible Auto HDR :

BufferUpgradeEnable10Bit=1

Mode forcé pour jeux non reconnus :

BufferUpgradeOverride=1;BufferUpgradeEnable10Bit=1
Principe de fonctionnement

L'outil modifie uniquement les clés registre utilisateur :

HKEY_CURRENT_USER\Software\Microsoft\Direct3D

Chaque jeu est enregistré sous une entrée :

Application0
Application1
Application2
...

avec les valeurs :

Name
D3DBehaviors

Aucun fichier du jeu n'est modifié.

Utilisation
Lancez AutoHDR_Direct3D_Manager.ps1.
Choisissez :
Ajouter / mettre à jour un jeu ;
Supprimer une entrée existante.
Sélectionnez le fichier .exe ou indiquez le nom de l'exécutable pour les jeux Game Pass.
Choisissez si le jeu est déjà compatible Auto HDR ou s'il faut forcer l'activation.
Compatibilité
Windows 11
DirectX 11 / DirectX 12
Jeux utilisant Direct3D
Cartes graphiques compatibles HDR
Avertissement

Cette application modifie le registre Windows.

Une mauvaise configuration peut empêcher Auto HDR de fonctionner correctement pour certains jeux. Il est recommandé de créer un point de restauration Windows avant une utilisation avancée.

Licence

Projet libre. Vous pouvez modifier et redistribuer ce script selon les conditions de la licence choisie.
