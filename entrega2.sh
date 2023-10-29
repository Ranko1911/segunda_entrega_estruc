##### Opciones por defecto
listaProg=
listaNattch=
unico=
lista=
leelista=0
leeProg=0
listaProg=
stovar=
nattchvar=

##### Constantes
TITLE="Información del sistema para $HOSTNAME" # $HOSTNAME muestra el nombre del host
RIGHT_NOW=$(date +"%x %r%Z") # date muestra la fecha y hora actual
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER" # muestra el nombre del usuario actual con la fecha y hora actual

##### Estilos

TEXT_BOLD=$(tput bold) # tput bold hace que el texto sea negrita
TEXT_GREEN=$(tput setaf 2) # tput setaf 2 hace que el texto sea verde
TEXT_RED=$(tput setaf 1) # tput setaf 1 hace que el texto sea rojo
TEXT_RESET=$(tput sgr0) # tput sgr0 hace que el texto sea normal
TEXT_ULINE=$(tput sgr 0 1) # tput sgr 0 1 hace que el texto sea subrayado

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

trace(){
  ps_output=$(ps -U $USER -o pid,comm --no-header)

  # Recorrer la lista de procesos y verificar el atributo TracerPid
  while read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    process_name=$(echo "$line" | awk '{print $2}')

    # Verificar si el proceso está siendo trazado
    if [ -f "/proc/$pid/status" ]; then
      tracer_pid=$(awk -F'\t' '/TracerPid/{print $2}' "/proc/$pid/status")
      if [ "$tracer_pid" -ne 0 ]; then
        tracer_name=$(awk -F'\t' '/Name/{print $2}' "/proc/$tracer_pid/status")
        echo "${TEXT_GREEN} Proceso bajo trazado (PID, Nombre): $pid, $process_name ---- Proceso trazador (PID, Nombre): $tracer_pid, $tracer_name ${TEXT_RESET}"
        #echo "Proceso trazador (PID, Nombre): $tracer_pid, $tracer_name"
        echo "-------------------------"
      else 
        echo "${TEXT_RED} Proceso bajo trazado (PID, Nombre): $pid, $process_name ---- Proceso trazador (PID, Nombre): 0, Ninguno${TEXT_RESET}"
        #echo "Proceso trazador (PID, Nombre): 0, Ninguno"
        echo "-------------------------"
      fi
    fi
  done <<< "$ps_output"
}

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

trace # mostrar los procesos trazados

if [ -n "$lista" ]; then
    echo "Lista es $lista"
    programa $lista
fi

