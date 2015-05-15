#!/bin/bash
# backup-bm-ssh : do a data+mysql backup
#
# Author: Mr Xhark -> @xhark
# License : Creative Commons http://creativecommons.org/licenses/by-nd/4.0/deed.fr
# Website : http://blogmotion.fr 
VERSION="2015.05.15"

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
if [[ $# != "$ARGS" || ($TYPEBACKUP != "MENSUEL" && $TYPEBACKUP != "HEBDO" && $TYPEBACKUP != "LIVE") ]]
then
	if [[  $TYPEBACKUP == "LIVE" ]]; then
		TYPEBACKUP=''		
	fi

        echo -e "${COUL_JAUNE}Utilisation: `basename $0` TYPE_DU_BACKUP ${COUL_RESET} \n"
        echo -e "Type de backup possibles :${COUL_VERT} MENSUEL, HEBDO, LIVE ${COUL_RESET}"
        echo -e "Les modes MENSUEL et HEBDO suffixent:                  [date]_backup-${SITENAME}_data|mysql__${COUL_VERT}MENSUEL|HEBDO${COUL_RESET}.tar.gz"
        echo -e "Le mode LIVE ne suffixe pas, il permet un instantanne: [date]_backup-${SITENAME}_data|mysql.tar.gz"
		echo -e "\n\t${COUL_BLANC}scripted by @xhark - Creative Commons BY-ND 4.0 (v${VERSION}) ${COUL_RESET}\n"
        exit $E_MAUVAISARGS
fi

# on definit le suffixe suivant le type de backup
if [[ $TYPEBACKUP == "LIVE" ]]; then
	TYPEBACKUP=''
else
	TYPEBACKUP="__${TYPEBACKUP}"
fi



NOW=$(date +"%Y-%m-%d")
MON_GZ="${NOW}_backup-${SITENAME}_data${TYPEBACKUP}.tar.gz"
MON_MYSQL="${NOW}_backup-${SITENAME}_mysql${TYPEBACKUP}.gz"

#####################################
# Debut du script
# Creation du rep de destination s'il n'existe pas
mkdir -p $DST_BACKUP

# Supprime les backups existants (pour pas prendre trop de place)
rm ${DST_BACKUP}/*backup-${SITENAME}_data*.tar.gz
rm ${DST_BACKUP}/*backup-${SITENAME}_mysql*.gz

echo -e "${COUL_BG_ROSE}\n\n\n=== Lancement du backup complet le : $(date +'%d/%m/%Y a %Hh%M') ... ${COUL_RESET}"


###########################
# lancement du backup data (sans verbose sur le tar : ajouter v pour l'avoir "zcvf")

tar zcf ${DST_BACKUP}/${MON_GZ} ${SRC_BACKUP} 	\
	--exclude '${DST_BACKUP}' 					\
	--exclude '/var/www/html/wp-content/backup' \
	--exclude '/var/www/html/wp-content/cache'  \
	--exclude '/var/www/html/un_repertoire_a_exclure'

	
###########################
# lancement du backup mysql

mysqldump -h $hostsql -u $usersql -p${mdpsql} $basesql | gzip -v > ${DST_BACKUP}/${MON_MYSQL} 

# fin du script
echo -e "${COUL_BG_ROSE}\n\n\n=== ... Fin du Backup complet (data+mysql) le $(date +'%d/%m/%Y a %Hh%M')\n\n\n ${COUL_RESET}"

# on affiche la taille et chemin du backup
cd $DST_BACKUP
echo -e $COUL_CYAN
ls -lh $MON_GZ $MON_MYSQL | awk '{print $5, "\t"$6, "\t"$7, "\t"$8, "\t"$9}'
echo -e "\n\n\n $COUL_RESET"
