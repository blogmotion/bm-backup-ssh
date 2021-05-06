#!/bin/bash
# backup-bm-ssh : do a data+mysql backup
#
# Author: Mr Xhark -> @xhark
# License : Creative Commons http://creativecommons.org/licenses/by-nd/4.0/deed.fr
# Website : http://blogmotion.fr/systeme/backup-bm-blog-13132 
VERSION="2021.05.16"

#============================#
#    VARIABLES A MODIFIER    #

# chemin absolu vers la racine du site à sauvegarder (souvent htdocs, www ou html), sans slash de fin
SRC_BACKUP="/var/www/monsite"

# chemin absolu vers la destination du backup, sans slash de fin
DST_BACKUP="/var/backup"

# Informations de connexion MySQL
usersql="mon_utilisateur"
mdpsql="xxxxxxxxx"
hostsql="localhost"
basesql="ma_base"

# Nom du site au choix (sans espace), apparaitra dans le nom des fichiers
SITENAME="bm"

#### FIN DES VARIABLES - NE RIEN MODIFIER APRES CETTE LIGNE ####
################################################################

# Controle des arguments
ARGS=1
E_MAUVAISARGS=0
TYPEBACKUP=$1

# Couleurs
COUL_RESET="\033[0m"
COUL_JAUNE="\033[1;33m"
COUL_VERT="\033[1;32m"
COUL_BLANC="\033[1;39m"
COUL_CYAN="\033[1;36m"
COUL_BG_ROSE="\033[45m"

# Teste le nombre d'arguments du script (toujours une bonne idee) et controle le type de backup passe en argument
if [[ $# != "$ARGS" || ($TYPEBACKUP != "MENSUEL" && $TYPEBACKUP != "HEBDO" && $TYPEBACKUP != "LIVE" && $TYPEBACKUP != "BDD") ]]
then
	if [[  $TYPEBACKUP == "LIVE" ]]; then
		SUFFIXE=''		
	fi

        echo -e "${COUL_JAUNE}Utilisation: `basename $0` TYPE_DU_BACKUP ${COUL_RESET} \n"
        echo -e "Type de backup possibles :${COUL_VERT} MENSUEL, HEBDO, LIVE, BDD ${COUL_RESET}"
        echo -e "Les modes MENSUEL et HEBDO suffixent:                  [date]_backup-${SITENAME}_data|mysql__${COUL_VERT}MENSUEL|HEBDO${COUL_RESET}.tar.gz"
        echo -e "Le mode LIVE ne suffixe pas, il permet un instantanne: [date]_backup-${SITENAME}_data|mysql.tar.gz"
		echo -e "\n\t${COUL_BLANC}scripted by @xhark - Creative Commons BY-ND 4.0 (v${VERSION}) ${COUL_RESET}\n"
        exit $E_MAUVAISARGS
fi

# on definit le suffixe suivant le type de backup
if [[ $TYPEBACKUP == "LIVE" ]]; then
	SUFFIXE=''
else
	SUFFIXE="__"$TYPEBACKUP
fi


NOW=$(date +"%Y-%m-%d")
MON_GZ="${NOW}_backup-${SITENAME}_data${SUFFIXE}.tar.gz"
MON_MYSQL="${NOW}_backup-${SITENAME}_mysql${SUFFIXE}.gz"

#####################################
# Debut du script
# Creation du rep de destination s'il n'existe pas
mkdir -p $DST_BACKUP

# Supprime les backups existants (pour pas prendre trop de place)
rm ${DST_BACKUP}/*backup-${SITENAME}_data*.tar.gz 	2> /dev/null
rm ${DST_BACKUP}/*backup-${SITENAME}_mysql*.gz		2> /dev/null

echo -e "${COUL_BG_ROSE}\n\n\n=== Lancement du backup ${TYPEBACKUP} le : $(date +'%d/%m/%Y a %Hh%M') ... ${COUL_RESET}"

if [[ $TYPEBACKUP == "BDD" ]]; then
        echo -e "${COUL_CYAN}Sauvegarde BDD seule, skip des datas${COUL_RESET}"
else

###########################
# lancement du backup data (sans verbose sur le tar : ajouter v pour l'avoir "zcvf")

	# compression multithread si pigz disponible
	type -P pigz &>/dev/null && TAR_OPT="-I pigz -cf" && GZ="pigz -v" || TAR_OPT="zcf" && GZ="gzip -v"

	tar $TAR_OPT $DST_BACKUP/$MON_GZ $SRC_BACKUP 			\
		--exclude '${DST_BACKUP}' 							\
		--exclude '/var/www/html/wp-content/backup' 		\
		--exclude '/var/www/html/wp-content/cache'  		\
		--exclude '/var/www/html/un_repertoire_a_exclure'

fi
	
###########################
# lancement du backup mysql

if MYSQL_PWD=$mdpsql mysqldump --single-transaction --column-statistics=0 --host=$hostsql --user=$usersql $basesql | gzip -v > $DST_BACKUP/$MON_MYSQL
then
	echo -e "\n... mysqldump : OK\n"
else
	echo -e "${COUL_ROUG} ATTENTION : IL Y A UNE ERREUR DANS L'EXPORT MYSQLDUMP ${COUL_RESET}"
fi

# fin du script
echo -e "${COUL_BG_ROSE}\n\n\n=== ... Fin du Backup ${TYPEBACKUP} le $(date +'%d/%m/%Y a %Hh%M') -- opt:$TAR_OPT \n\n\n ${COUL_RESET}"

# on affiche la taille et chemin du backup
cd $DST_BACKUP
echo -e $COUL_CYAN
ls -lh $MON_GZ $MON_MYSQL 2> /dev/null | awk '{print $5, "\t"$6, "\t"$7, "\t"$8, "\t"$9}'
echo -e "\n\n\n $COUL_RESET"

exit 0