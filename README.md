bm-backup-ssh (blogmotion backup ssh)
===

###Description###
Script de sauvegarde bash (serveur dédié, VPS et sur certains mutualisés (comme Web4all). Script composé d'un unique fichier **bm-backup-ssh.sh** qui permet :

- la sauvegarde des données dans une archive tar.gz
- la sauvegarde d'une base MySQL dans une archive .gz

##Configuration minimale###
- un hébergement avec un accès SSH
- interpréteur bash
- binaires nécessaires : mysqldump, gzip, tar.

###Utilisation###
Il est recommandé de créer un répertoire de destination un cran au dessus de "www", pour qu'il ne soit pas acessible. Si vous le laissez dans "www" pensez à protéger l'accès à ce dossier avec un fichier *.htaccess* ou à minima lui donner un nom exotique (pour des raisons de sécurité).

```
chmod +x bm-backup-ssh.sh
./bm-backup-ssh.sh TYPE_BACKUP
```

Le `TYPE_BACKUP` n'influence pas le contenu du backup, uniquement son nom :
* LIVE : ne suffixe pas le nom du backup
* MENSUEL, HEBDO : suffixe le nom du backup

###English version ###

###[EN] Description ###
Backup script for hosting with SSH access. The script works with the single file **bm-backup-ssh.sh** which allows for :

- data backup in a tar.gz archive
- saving a MySQL database in a .gz archive

###[EN] Requirements ###
- hosting with SSH remote access
- bash interpreter
- required binaries : mysqldump, gzip, tar.

###[EN] Usage ###
It is recommended to create a destination folder in the parent of "www", to not be accessible. If you leave it in "www" please protect it with a *.htaccess* file or rename something that nobody can easily figure out (for security reasons).

```
chmod +x bm-backup-ssh.sh
./bm-backup-ssh.sh TYPE_BACKUP
```

`TYPE_BACKUP` does not influence the content of backup, only his name:
* LIVE: Do not suffix the name of the backup
* MENSUEL (=MONTHLY), HEBDO (=WEEKLY): suffix the name of the backup