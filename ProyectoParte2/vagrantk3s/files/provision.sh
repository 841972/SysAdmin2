#!/bin/bash -x
#Establece las variables de entorno que se pasan por parametro
HOSTNAME=$1
NODEIP=$2
MASTERIP=$3
NODETYPE=$4

timedatectl set-timezone Europe/Madrid

cd /vagrant

#Introduce en el /etc/hostname el nombre del nodo (HOSTNAME)que se pasa por parametro
echo $1 > /etc/hostname
hostname $1

#Introduce en el /etc/hosts la IP y el nombre de los nodos que se pasan por parametro
{
  echo "192.168.1.141 w1"
  echo "192.168.1.142 w2"
  echo "192.168.1.143 w3"
  cat /etc/hosts
} > /etc/hosts.new
mv /etc/hosts{.new,}

#Se copia el ejecutable k3s de kubernetes en /usr/local/bin
cp k3s /usr/local/bin/

# A continuacion se realiza la instalacion de k3s en los nodos, es diferente la intalación 
# en el nodo master y en los nodos worker
# En el nodo master se instala el servidor de k3s el cual se especifica en el parámetro install.sh 
# y en los nodos worker se instala el agente de k3s.
# En caso del master se especifica el token que se ha generado en el nodo master y se especifica
# la interfaz de red que se va a utilizar para la red flannel, la dirección IP del nodo, el nombre del nodo
# y se deshabilita el traefik y el servicelb. 
if [ $NODETYPE = "master" ]; then 
  INSTALL_K3S_SKIP_DOWNLOAD=true \
  ./install.sh server \
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  --flannel-iface enp0s8 \
  --bind-address $NODEIP \
  --node-ip $NODEIP --node-name $HOSTNAME \
  --disable traefik \
  --disable servicelb \
  --node-taint k3s-controlplane=true:NoExecute 
  # El parámetro `--node-taint` se utiliza para aplicar una restricción a un nodo en el clúster de k3s.
  # En este caso, se está aplicando la restricción `k3s-controlplane=true:NoExecute` al nodo.
  # esta restricción indica que este nodo es parte del plano de control de k3s 
  # y que no se deben programar pods regulares en él. Los pods regulares solo se programarán en los nodos 
  # que no tengan esta restricción. La opción `NoExecute` en la restricción significa que 
  # si un pod ya está en ejecución en este nodo y la restricción se aplica posteriormente, 
  # el pod no se eliminará automáticamente, pero no se programarán nuevos pods en este nodo.

  #--advertise-address $NODEIP
  #--cluster-domain “cluster.local”
  #--cluster-dns "10.43.0.10"k3s

  #Copia el fichero de configuración yaml de k3s en el directorio /vagrant
  cp /etc/rancher/k3s/k3s.yaml /vagrant
  
else
  # En caso de los nodos worker se instala el agente de k3s, 
  # se especifica la dirección IP del nodo maestro y el puerto, y el token que se ha generado en el nodo master,
  # la ip del nodo, el nombre del nodo y la interfaz de red que se va a utilizar para la red flannel.

  INSTALL_K3S_SKIP_DOWNLOAD=true \
  ./install.sh agent --server https://${MASTERIP}:6443 \
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  --node-ip $NODEIP --node-name $HOSTNAME --flannel-iface enp0s8
fi
