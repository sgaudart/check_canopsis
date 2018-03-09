# Verification de Canopsis

## Sommaire

1. [Introduction](#introduction)
2. [Objectif](#objectif)
   1. [Version](#version)
   2. [Support](#support)
   3. [Périmètre](#périmètre)
4. [Prérequis](#prérequis)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Le résultat](#le-résultat)
7. [Utilisation](#utilisation)
8. [Vérification](#vérification)
9. [Problèmes connus](#problèmes-connus)

## Introduction

- auteur : sgaudart@capensis.fr
- date : 05/03/2018

[Canopsis](http://www.canopsis.com/) est un hyperviseur édité par la société [Capensis](https://www.capensis.fr/).

## Objectif

Le script `check_everything.pl` permet de vérifier la bonne installation et disponiblité de Canopsis.  
Le script prend en entrée 2 fichiers de configuration :
- un fichier d'inventaire ([inventory.conf](inventory.conf)) qui précise qq infos sur le produit canopsis (chemin d'install,hostname,port)
- un fichier de checks ([check_*.conf](check_cano255.conf)) qui répertorie les vérifications à faire sur Canopsis (à faire évoluer !!)

En retour, vous aurez le résultat des vérifications définies dans `checks.conf`.


### Version

Testé avec Canopsis 2.4.X et 2.5.X sur du CentOS7.


### Support

- Support de SELinux : NON
- Support d'un changement de datadir : NON
- Support d'un proxy (si requête HTTP) : NON


### Périmètre

Le script check_everything.pl s'exécute sur les noeuds canopsis (qui porte les moteurs et/ou bus AMQP et/ou serviceweb)


## Prérequis

| Type    | Nom         | Version |
|---------|-------------|---------|
| système | perl        | 5.X     |
| perl    | lib Getopt::Long |    |
| perl    | lib IO::Socket   |    |


## Installation

```
git clone https://github.com/sgaudart/check_canopsis.git
```


## Configuration

Il vous faut éditer le fichier `inventory.conf`, et changer les variables ci-dessous si nécessaire :
- $cps_home    = "/opt/canopsis"

- $amqp_vip    = "127.0.0.1" # put VIP here
- $amqp_port   = 5672

- $mongo_host1 = "mongo1"
- $mongo_host2 = "mongo2" # si cluster mongo
- $mongo_host3 = "mongo3" # si cluster mongo
- $mongo_port   = 27017

- $influx_host = "influx_hostname"
- $influx_port = 4444


## Le résultat
screenshot ici

## Utilisation

Pour ne voir que les tests KO :
```
./check_everything.pl --checkfile check_cano255.conf --inventory inventory.conf
```


Je vois le résultat de tous les tests :
```
./check_everything.pl --checkfile check_cano255.conf --inventory inventory.conf --verbose
```


## Vérification
Quelles commandes pour vérifier si l'installation s'est bien déroulé ?


## Problèmes connus
ici les problèmes rencontrés potentiels + numéro de ticket/issue en lien avec le sujet
