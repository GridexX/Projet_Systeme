#!usr/bin/env bash

#   PROJET SYSTEME - MODULE M1101
#   Crée par MOLINA Romain, FOUGEROUSE Arsène, PLACIOS Mayeul et BELARBI Yassine
#   arborescence_v0_5.sh
#   prend en paramètres les deux arborescences à traverser
#   En cours : modifier la fonction TriFD
#              ajoutez des couleurs
             

checkParam(){
    #création d'un dossier log qui contient toutes les sorties de fichier du script
    logdir="logs"
    if [ ! -d "$logdir" ]
    then
        mkdir $logdir
    fi
    
    #analyse des répertoires à traverser

    if [ $# -ne 2 ]
    then
        printf "Voulez vous utiliser les arborescences par défaut (arbo1 et arbo2) pour l'analyse ? Tapez [o/n] >\n"
        read choix
        while [ "$choix" != "o" ] && [ "$choix" != "n" ]
        do
            echo "Veuillez entrer une lettre valide : d (pour defaut) et m (pour manuel) >"
        done
        if [ $choix = "o" ]
        then
            rep1="arbo1"
            rep2="arbo2"
        else
            checkRep 1
        fi

    else
        checkRep 0
    fi
    
}

checkRep(){
    #fonction qui test si les repertoires spécifiés existent
    existRep=$1
    
    for ((i=1 ; i<3 ; i++ ))
    do
        if [ $existRep -eq 1 ]  #Si les répertoires n'ont pas été rentrés en param on les read
        then
            echo "Entrez le nom du répertoire n°$i à traverser >"
            read dir
        else
            if [ $i -eq 1 ]
            then
                dir=$rep1   #Sinon on test chacun à la suite
            else
                dir=$rep2
            fi
        fi
        check=1
        find $dir -type d || check=0

        while [ $check -eq 0 ]
        do
            echo "Le répertoire $dir que vous voulez traverser n'est pas accesible depuis le rep courant ou n'existe pas"
            printf "Veuillez entrez un répertoire existant > "
            read dir
            check=1
            find $dir -type d || check=0
        done

        echo "Le répertoire n°$i est valide et prêt pour l'analyse !"
        if [ $i -eq 1 ]
        then
            rep1=$dir
        else
            rep2=$dir
        fi
    done

}


listeFD(){
    #fonction qui renvoie la liste des MD5/dossiers dans un fichier et le sauve dans le log
    type=$1 # 'f':file / 'd':directory
    dir1=$2
    dir2=$3

    listetxt=$type"_"$dir1"_"$dir2.txt
    repTraversee="$dir1 $dir2"
    for dir in $repTraversee
    do
        if [ "$dir" = "$dir2" ] #ajoute un séparateur de champ entre arbo1 et arbo2
        then
            echo "- Le repertoire2 ($dir2) contient :" >> $listetxt
        fi
        if [ "$dir" = "$dir1" ]
        then
            echo "- Le repertoire1 ($dir1) contient :" >> $listetxt
        fi

        for pointeur in `find $dir -type $type`
        do
            if [ $type = "f" ]
            then
                #Si fichier injecte le md5 dans un autre fichier
                md5sum $pointeur >> $listetxt
            else
                #Sinon affiche la liste des dossiers
                echo $pointeur >> $listetxt
            fi
        done
    done
    
    #enregistre le fichier avec la liste des md5/dossiers dans le dossier logs + horodatage
    #ce fichier sera supprimé plus tard si analyse des dossiers
    
    date=`date +%Y%m%e_%H%M%S_`
    nvfichier=$date"list_"$listetxt
    cp $listetxt ./$logdir/$nvfichier
    fichierBrut=./$logdir/$nvfichier
    #après la sauvegard on enlève les lignes informatives inutiles pour la suite et les répertoire
    sed -i '/- Le repertoire/d' $listetxt ; sed -i 's/\s.*$//' $listetxt
    TriFD $type $listetxt $fichierBrut $dir1 $dir2
}

TriFD(){
    #fonction qui concatène les md5/dossiers en double dans un autre fichier
    type=$1
    fichier=$2
    fichierBrut=$3
    dir1=$4
    dir2=$5
    
    temp=`mktemp TEMP_XXX`
    fichierTri=`mktemp TEMP_XXX`
    if [ -z "$dir2" ]
    then
        cmdDir="cat $fichier"
    else 
        cmdDir="sed -e s/$dir2//g"
    fi
    if [ $type = "d" ]
    then
        cat $fichier | $cmdDir | sed -e s/$dir1//g | tr / '\n' > $temp
        #printf $dir1'\n'$dir2 >> $temp
        awk NF $temp | sort > $fichier
    fi
    nbFD=`cat $fichier | wc -l`
    #Si f arbo1 ou 2 on doit conserver sauvegarder le md5 du fichier trié
    sort -u $fichier > $fichierTri
    nbdiffFD=`cat $fichierTri | wc -l`
    if [ -z "$dir2" ] #si une seule arbo en entrée
    then
        if [ "$dir1" = "$rep1" ] #si le repertoire 1 correspond au 1er entré on sauvegarde dans variables ...1
        then
            if [ "$type" = "f" ]
            then
                md5file1=`md5sum $fichier | cut -d' ' -f1` #md5 du fichier contenant les empreintes des fichiers contenus
                mot="es empreintes md5"
                ftemp=$fichierBrut
            else
                md5dir1=`md5sum $fichier | cut -d' ' -f1` #md5 du fichier contenant dossier dans l'arbo
                mot="s dossiers"
            fi
            
        else
            if [ "$type" = "f" ] #sinon c'est le rep 2 et les variables auraont un nom ...2
            then
                md5file2=`md5sum $fichier | cut -d' ' -f1`
                mot="es empreintes md5"
                ftemp=$fichierBrut
            else
                md5dir2=`md5sum $fichier | cut -d' ' -f1`
                mot="s dossiers"
            fi
        fi
        #ecrit le md5 des fichiers et dossiers dans les fichierBruts
        if [ "$mot" = "es empreintes md5" ]
        then
            fsortie=$fichierBrut
        else
            fsortie=$ftemp
        fi
        echo "- Empreinte md5 du fichier ($fichier) contenant les différent$mot de $dir1 : `md5sum $fichier | cut -d' ' -f1` " >> $fsortie
    else
        cheminCompletF $fichier $fichierTri $dir1 $dir2 $md5file1 $md5file2 $md5dir1 $md5dir2
    fi
    
    #analyse du nombre de dossiers/fichiers différents au total
    if [ $type = "d" ]
    then
        mot="dossiers"
    else
        mot="fichiers"
    fi
    if [ -n "$dir2" ]
    then
        arborescence="$dir1 et $dir2"
    else
        arborescence="$dir1"
    fi
    printf "\nIl y a $nbdiffFD $mot différents sur $nbFD au total dans $arborescence\nListe des $mot différents :\n"
    cat $fichierTri ; echo ""
    
    removeFiles $type $dir1 $dir2
}


cheminCompletF(){

    #Fonction qui affiche le chemin complet des fichiers différents
    
    fichier=$1
    fichierTri=$2
    dir1=$3
    dir2=$4
    md5file1=$5 
    md5file2=$7
    md5dir1=$7 
    md5dir2=$8
    
    nvfichierCC=$date"CC_"$fichier
    fichierBrutCC=./$logdir/$nvfichierCC

    while read ligne
    do
        echo "Le fichier ayant pour empreinte md5 $ligne apparait dans :" >> $fichierBrutCC
        grep $ligne $fichierBrut | cut -d' ' -f3 >> $fichierBrutCC
    done < $fichierTri
    
    #affiche si les répertoires sont identiques ou différents
    
    #Si le md5 du fichier contenant les md5 des fichiers dans les 2 arbo est identique et celui contenant les dossiers
    if [ "$md5file1" = "$md5file2" ] && [ "$md5dir1" = "$md5dir2" ]
    then
        printf "Les deux arborescences $dir1 et $dir2 sont IDENTIQUES\n" #on considère que les arbo sont pareils
    else
        printf "Les deux arborescences $dir1 et $dir2 sont DIFFERENTES\n"
    fi
}


removeFiles(){
    type=$1
    rm $fichier TEMP_???
    if [ "$type" = "d" ]
    then
        rm $fichierBrut
    fi
}


rep1=$1
rep2=$2
checkParam $rep1 $rep2

listeFD f $rep1
listeFD d $rep1
listeFD f $rep2
listeFD d $rep2
listeFD f $rep1 $rep2
