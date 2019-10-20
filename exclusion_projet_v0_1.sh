
dir1="arbo2"
fileMD5_1=`mktemp fileMD5_1_XXX`
CPfileMD5_1=`mktemp CpfileMD5_1_XXX`
triMD5_1=`mktemp TriMD5_1_XXX`


#sort un fichier avec le md5 pour chaque fichier dans le rep
for fichier in `find $dir1 -type f`
do
    md5sum $fichier >> $fileMD5_1
done

#crée une copie ordonné des MD5
cat $fileMD5_1 | sort | cut -d' ' -f1 >> $CPfileMD5_1
cat $CPfileMD5_1

nbfiles=`cat $CPfileMD5_1 | wc -l`
echo $nbfiles

debut=1
occur=0
cpt=0

while [ $debut -le $nbfiles ]
do
    chaine=`cat $CPfileMD5_1 | head -n $debut | tail -n 1`
    echo $chaine >> $triMD5_1
    debut=$(($debut + `cat $CPfileMD5_1 | grep -c "$chaine"`))
    occur=$(($debut - 1 - $cpt))
    cpt=$(($cpt + 1))
    echo $chaine $debut $occur
done

cat $fileMD5_1 | grep -c "$triMD5_1"
rm $CPfileMD5_1
rm $fileMD5_1
rm $triMD5_1