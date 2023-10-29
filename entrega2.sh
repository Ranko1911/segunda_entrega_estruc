listaProg=
listaNattch=
unico=
lista=
leelista=0
leeProg=0
listaProg=
stovar=
nattchvar=

usage() 
{
  echo "Usage: scdebug [-h] [-sto arg] [-v | -vall] [-k] [prog [arg …] ] [-nattch progtoattach …] [-pattch pid1 … ]"
}

programa() {
  if [ $# -eq 0 ]; then
    echo "La función 'prog' fue llamada sin argumentos."
    exit 1
  else
    echo "La función 'prog' fue llamada con argumentos: $@"
  fi

  if [ -d "scdebug" ]; then # comprobar que la carpeta scdebug existe
    echo "La carpeta scdebug existe."
  else
    echo "La carpeta scdebug no existe."
    echo "mkdir scdebug"
    $(mkdir scdebug )
  fi

  if [ -d "scdebug/$1" ]; then # comprobar que la carpeta scdebug/$1 existe
    echo "La carpeta $1 existe."
  else
    echo "La carpeta $1 no existe."
    echo "mkdir scdebug/$1"
    $(mkdir scdebug/$1 )
  fi

  uuid=$(uuidgen)
  echo "strace $stovar  -o scdebug/$1/trace_$uuid.txt $@"
  $(strace $stovar -o scdebug/$1/trace_$uuid.txt $@)
}

nattch(){
    #echo $(ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )
    #PID=$( ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )

    #nattchvar="-p $PID"
  if [ $# -eq 0 ]; then
    echo "La función 'prog' fue llamada sin argumentos."
    exit 1
  else
      echo "La función 'prog' fue llamada con argumentos: $@"
  fi

  if [ -d "scdebug" ]; then # comprobar que la carpeta scdebug existe
    echo "La carpeta scdebug existe."
  else
    echo "La carpeta scdebug no existe."
    echo "mkdir scdebug"
    $(mkdir scdebug )
  fi

  if [ -d "scdebug/$1" ]; then # comprobar que la carpeta scdebug/$1 existe
    echo "La carpeta $1 existe."
  else
    echo "La carpeta $1 no existe."
    echo "mkdir scdebug/$1"
    $(mkdir scdebug/$1 )
  fi

    echo $(ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )
    PID=$( ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )

    nattchvar="-p $PID"

  uuid=$(uuidgen)
  echo "strace $stovar $nattchvar -o scdebug/$1/trace_$uuid.txt "
  $(strace $stovar $nattchvar -o scdebug/$1/trace_$uuid.txt )
}

if [ $# -eq 0 ]; then
  usage
  exit 1
fi

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           
            usage
            exit
            ;;         
        prog ) 
            leelista=1;
	          if [ "$leeProg" -eq 1 ]; then
		          leeProg=2
	          fi
        ;;    
        -sto )   
          stovar="$2"
          echo "sto es $stovar"
        ;;   
        -nattch )  
        #while [ "$2" != "-h" |  "$2" != "prog" |  "$2" != "-sto"      ]; do
        #nattch "$2"
        #done     
            nattch "$2"
            echo "nattch es $nattchvar"
            ;;
        * )   if [ "$leelista" -ne 1 -a "$leeProg" -ne 2 ]; then
		    leeProg=1
		    listaProg+="$1 "
            elif [ "$leelista" -eq 1 ]; then
                lista+="$1 "
            else
                usage
                exit 1
            fi
        ;;             
    esac
    shift
done


if [ -n "$lista" ]; then
    echo "Lista es $lista"
    programa $lista
fi

#if [ -n "$listaProg" ]; then
	#echo "Lista de programa es $listaProg"
#fi
