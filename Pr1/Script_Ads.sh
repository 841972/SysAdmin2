#!/bin/sh

# Introducción
echo "Bienvenido. Por favor, elige una opción:"
echo "0: Definición de las VMs"
echo "1: Definir y puesta en marcha de las VMs"
echo "2: Parada de las VMs y undefine"

# Leer la opción del usuario
read -p "Ingresa el número de la opción deseada: " opcion

# Gestión de errores
if [ "$opcion" != "0" ] && [ "$opcion" != "1" ] && [ "$opcion" != "2" ]; then
    echo "Opción inválida. Por favor, elige una opción válida."
    exit 1
fi

read -p "Escriba 'g' si quiere gestionar máquinas en grupo: " grupo
if [ "$grupo" != "g" ]; then
    # Procesar la opción elegida
    case $opcion in
        0)
            echo "Has elegido la opción de definición de las VMs"
            read -p "Ingresa el nombre de la máquina virtual a definir: " vm_name
            vm_name="$vm_name.xml"
            ;;
        1)
            echo "Has elegido la opción de puesta en marcha de las VMs"
            read -p "Ingresa el nombre de la máquina virtual a iniciar: " vm_name        
            ;;
        2)
            echo "Has elegido la opción de parada de las VMs"
            read -p "Ingresa el nombre de la máquina virtual a apagar: " vm_name        
            ;;
    esac

    case $opcion in
        0)
            # Definir las máquinas virtuales
            ssh a841972@155.210.154.198 "cd /misc/alumnos/as2/as22023/a841972 && virsh -c qemu:///system define $vm_name"
            ;;
        1)
            # Iniciar la máquina virtual $vm_name con virsh
             virsh -c qemu+ssh://a841972@155.210.154.198/system start $vm_name
            ;;
        2)
            # Parar la máquina virtual $vm_name con virsh
            virsh -c qemu+ssh://a841972@155.210.154.198/system shutdown $vm_name
            ;;
            esac
else
    if [ "$grupo" = "g" ]; then
    read -p "Escriba el nombre del fichero que contiene los nombres de las máquinas: " fichero

    while IFS= read -r line
    do
        case $opcion in
            0)
                # Definir las máquinas virtuales
                ssh -n a841972@155.210.154.198 "cd /misc/alumnos/as2/as22023/a841972 && virsh -c qemu:///system define $line.xml"
                
                ;;
            1)
                # Iniciar la máquina virtual $line con virsh
                echo "Iniciando $line"
                ssh -n a841972@155.210.154.198 "cd /misc/alumnos/as2/as22023/a841972 && virsh -c qemu:///system define $line.xml"
                virsh -c qemu+ssh://a841972@155.210.154.198/system start $line
                ;;
            2)
                # Parar la máquina virtual $line con virsh
                echo "Apagando $line"
                 virsh -c qemu+ssh://a841972@155.210.154.198/system shutdown $line
                 ssh -n a841972@155.210.154.198 "cd /misc/alumnos/as2/as22023/a841972 && virsh -c qemu:///system undefine $line"
                ;;
        esac
    done < "$fichero"
fi
fi

