#!/bin/bash

# Verifica si el archivo m1.txt existe
if [ ! -f "m1.txt" ]; then
    echo "El archivo m1.txt no existe."
    exit 1
fi

# Itera sobre cada línea del archivo m1.txt
while IFS= read -r ip_address; do
    gnome-terminal -- ssh -t -Y a841972@central.cps.unizar.es "ssh -t -Y a841972@$ip_address"
done < "m1.txt"

