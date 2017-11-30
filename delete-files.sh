function loop(){
  for file in `ls $1`
     do
       path=$1/$file
       if [ -d $path ]
          then
              loop $path $2
          else
            echo $file
            date=`date -r data +'%Y-%m-%d'`
            echo $date
            echo "param:$2"
            if test $date = $2
            then
               echo "delete $file"
            else
                echo "pass"
            fi
          fi
        done
}
loop $1 $2
