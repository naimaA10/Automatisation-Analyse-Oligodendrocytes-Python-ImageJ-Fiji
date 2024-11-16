# Automatisation de l'Analyse d'Images pour la Différenciation des Oligodendrocytes

## Contexte du Projet
Le but de ce projet était d'automatiser l'analyse d'images dans le cadre de la recherche sur la **sclérose en plaques (SEP)**. L'objectif spécifique était de créer un algorithme pour **quantifier et classer les cellules** (oligodendrocytes vs astrocytes) en fonction de leur état de différenciation. 

### Contexte scientifique :
Les oligodendrocytes sont des cellules essentielles du système nerveux central, responsables de la formation de la myéline. Leur démyélinisation est un facteur clé dans des pathologies comme la sclérose en plaques. Ce projet visait à automatiser le processus de classification des images de cellules pour mieux comprendre leur rôle dans la SEP.

## Travail Réalisé

### 1. **Automatisation de l'Analyse des Images**
J'ai développé un **script Python** afin d'automatiser la quantification des cellules et leur classification en différents sous-types. Ce processus initialement manuel était long et sujet à des erreurs humaines. Mon script permet de :

- Identifier et classifier les cellules (oligodendrocytes vs astrocytes).
- Analyser les résultats et générer des graphiques/statistiques pour faciliter l'interprétation des données.
  
Le script utilise des outils comme **ImageJ FIJI** pour l'analyse d'images et **Python** pour la gestion des données.

### 2. **Fiches Utilisateur**
Pour rendre les scripts accessibles et faciles à utiliser, j'ai également créé des **fiches utilisateur** détaillant la marche à suivre pour exécuter les scripts Python et manipuler les fichiers. Ces fiches sont conçues pour des utilisateurs non familiers avec le code.

### 3. **Structure des Dossiers**
- Le répertoire `patient_controle` et `patient_malade` contiennent des sous-dossiers pour chaque plaque d'échantillon, avec des fichiers **.TIF** correspondant à des images générées lors des analyses. 
- **Note importante** : Je ne peux malheureusement pas partager ces données sensibles car elles proviennent de l'institut. Seuls les scripts sont mis à disposition ici.

### 4. **Fichiers de Script**
Les scripts développés incluent :

- **Classification.ipynb** : Pour classifier les cellules en fonction de leur type.
- **Comptage.ipynb** : Pour compter les cellules dans chaque image.
- **Suppime.DIB et regrouper les puits.ipynb** : Pour nettoyer les données d'image.
- **Modifier le script python.ipynb** : Pour ajuster les paramètres du script de manière flexible.
- **Macro.ijm** : Scripts spécifiques à ImageJ FIJI pour le traitement des images.

### 5. **Fichiers Utilisateurs**
Vous trouverez des dossiers contenant les instructions pour utiliser les scripts, notamment :

- **indications** : Contient les instructions de base sur l'utilisation des scripts.
- **patient_controle** et **patient_malade** : Dossiers contenant les sous-dossiers d'images (ne sont pas partagés ici en raison de la confidentialité des données).

## Contact
Pour toute question ou besoin d'assistance concernant le projet, vous pouvez me contacter par email à **naima.ammiche@gmail.com**.

## Dates
Le travail a été réalisé dans le cadre de mon stage de Master 1 entre avril et juin 2023.

---

Merci de noter que ce dépôt contient uniquement **les scripts** et **les instructions pour les utiliser**, mais pas les données de patients, qui sont confidentielles.

## Licence
Tous droits réservés. Aucune redistribution ou utilisation n'est autorisée sans l'accord préalable de l'auteur.
