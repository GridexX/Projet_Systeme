#!bin/bash

listeFile(){
    choixtype=$1 # 'f':file / 'd':directory
    dir1=$2
    dir2=$3
    repTraversee="$dir1 $dir2"
    nomfichier="list_"$choixtype"_"$dir1"_"$dir2
    fichiertxt="$nomfichier".txt

    echo "$choixtype / $dir1 / $dir2 / $repTraversee / $fichiertxt"
    
    for dir in $repTraversee
    do
        if [ "$dir" = "$dir2" ]
        then
            echo "- Le repertoire2 ($dir2) contient :" >> $fichiertxt
        fi

        for pointeur in `find $dir -type $choixtype`
        do
            if [ $choixtype = "f" ]
            then
                md5sum $pointeur >> $fichiertxt
            else
                echo $pointeur >> $fichiertxt
            fi
        done
    done

    cat $fichiertxt
    rm $fichiertxt
}

sed -i 's/\r$//' listeFichier.sh
listeFile f arbo1
listeFile f arbo2
listeFile f arbo1 arbo2
listeFile d arbo1
listeFile d arbo2
listeFile d arbo1 arbo2