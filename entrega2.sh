#!/bin/bash

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
pattchvar="-p " 

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

##### Funciones

# funcion ayuda
usage() 
{
  echo "Usage: scdebug [-h] [-sto arg] [-v | -vall] [-k] [prog [arg …] ] [-nattch progtoattach …] [-pattch pid1 … ]"
}


usage2() 
{
  echo "ocpcion no valida"
  usage
}

# funcion base
programa() {
  primeraBarrerra $1

  uuid=$(uuidgen)
  echo "strace $stovar  -o scdebug/$1/trace_$uuid.txt $@"
  $(strace $stovar -o scdebug/$1/trace_$uuid.txt $@)
}

nattch(){
  #echo "nattch $1"
    echo $(ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )
    PID=$( ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )

    nattchvar="-p $PID"
  primeraBarrerra $1

    echo $(ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )
    PID=$( ps aux | grep $1 | sort -k 4 | tail -n 4 | head -n 1 | tr -s ' ' | cut -d ' ' -f2  )

    nattchvar="-p $PID"

  uuid=$(uuidgen)
  echo "strace $stovar $nattchvar -o scdebug/$1/trace_$uuid.txt &"
  $(strace $stovar $nattchvar -o scdebug/$1/trace_$uuid.txt &)
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

kill2(){ # funciona en maquina ajena, pero no en la local
  ps_output=$(ps -U $USER -o pid,comm --no-header)

  while read -r line; do
    pid=$(echo "$line" | awk '{print $1}')

    # Verificar si el proceso está siendo trazado
    if [ -f "/proc/$pid/status" ]; then
      tracer_pid=$(awk -F'\t' '/TracerPid/{print $2}' "/proc/$pid/status")
      if [ "$tracer_pid" -ne 0 ]; then
        echo "kill $tracer_pid"
        kill -s SIGKILL $tracer_pid &> /dev/null
        echo "kill -s SIGKILL $pid"
        kill -s SIGKILL $pid &> /dev/null
      fi
    fi
  done <<< "$ps_output"

}

# comprobacion y creacion de carpetas para los archivos de traza
primeraBarrerra(){
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
}

pattch(){
  primeraBarrerra $1
  $(strace $stovar -p $1 -o scdebug/$1/trace_$uuid.txt &)
}


# pruebas de ejecucion
check_uuidgen_availability() {
    if command -v uuidgen &> /dev/null; then
        echo "uuidgen está disponible en el sistema."
    else
        echo "uuidgen no está disponible en el sistema."
    fi
}

check_strace_availability() {
    if command -v strace &> /dev/null; then
        echo "strace está disponible en el sistema."
    else
        echo "strace no está disponible en el sistema."
        exit 1
    fi
}


check_strace_availability

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
          while [ "$2" != "-h" ] && [ "$2" != "prog" ] && [ "$2" != "-sto" ] && [ "$2" != "" ]; do
            nattch "$2"
            shift
          done

            #nattch "$2"
            #echo "nattchvar es $nattchvar"
            ;;
        -k | --kill )  
          kill2
          shift
          ;;
        -pattch )  
          while [ "$2" != "-h" ] && [ "$2" != "prog" ] && [ "$2" != "-sto" ] && [ "$2" != "" ]; do
            pattch "$2"
            shift
          done
          ;;
        * )   if [ "$leelista" -ne 1 -a "$leeProg" -ne 2 ]; then
		      leeProg=1
		      listaProg+="$1 "
            elif [ "$leelista" -eq 1 ]; then
                lista+="$1 "
            else
                usage2
                exit 1
            fi
        ;;             
    esac
    shift
done

#trace # mostrar los procesos trazados

if [ -n "$lista" ]; then
    echo "Lista es $lista"
    programa $lista
fi

