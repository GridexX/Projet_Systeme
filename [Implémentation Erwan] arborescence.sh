# Projet Système
# Crée par BELARBI Yassine, PALACIOS Mayeul, MOLINA Romain, FOUGEROUSE Arsène
# DUT INFO 1

# Ce script prend en paramètres le nom des deux répertoires à traverser
#Si les 2 noms de répertoire ne sont pas donnés, le script les demandent à l'utilisateur

param=$#

#création de fichiers temporaires pour stocker les valeurs :
fileMD5=`mktemp fileMD5_XXX`
#fileCompare=`mktemp fileCompare_XXX`

if [ $param -lt 2 ] 
then
	echo  "Veuillez saisir le nom du 1er répertoire >"
	read dir1
	echo  "Veuillez saisir le nom du 2ème répertoire >"
	read dir2

else
	dir1=$1
	dir2=$2
fi

#renvoie un fichier .txt avec tous les fichiers des 2 repertoires

chaine="$dir1 $dir2"
#echo "[empreinte md5] [nom_fichier]" >> $fileMD5

for dir in $chaine
do
	echo "- Le répertoire $dir contient :" >> $fileMD5

	#echo $dir
	for fichier in `find $dir -type f`
	do
		md5sum $fichier >> $fileMD5
	done
done


lol(){
	echo "break"
}

cat $fileMD5
ligneStop=`cat $fileMD5 | tail -n +2 | grep -n '-' | cut -d: -f1`
echo "Ligne de stop : $ligneStop"
cpt=0
etatRep="identiques"
occur=0
sommeOccur=0

while read ligne
do
	chaine=`echo "$ligne" | cut -d\  -f1`
	# AJOUT DES MD5 DANS CHAINE ET TEST SI MD5 EXISTE DEJA : EVITER RETEST DOUBLE
	
	if [[ "$chaine" =~ [0-9a-zA-Z*] ]] && [ $cpt -lt $ligneStop ]
	then
		
		occur=`cat $fileMD5 | grep -c $chaine`
		echo "$chaine apparait : $occur fois"
		if [ $etatRep = "identiques" ] && [ $occur -gt 1 ]
		then
			etatRep="différentes"
		fi

	elif [[ "$chaine" =~ ^-$ ]]
	then
		echo "commencement des fichiers du 2ème rep"
		#exit
		#rm $fileMD5
	fi
	echo "CPT : $cpt"
	cpt=$(($cpt + 1))
	sommeOccur=$(($sommeOccur + $occur))
done < $fileMD5



#test si les 2 arborescences sont identiques :

echo "Les deux arborescences sont $etatRep"

#VOIR COMMANDE DIFF POUR DIFFERENCE FICHIER
#calcul du nombre de fichier différents :
echo "Nb total d'occurences : $sommeOccur"
nbDiffer=$(($cpt - $sommeOccur))
echo "Nb fichier différents : $nbDiffer"

#cat $fileMD5
#rm $fileCompare
rm $fileMD5
