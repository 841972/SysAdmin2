#!/usr/bin/ruby -w
require 'net/ping'
require 'net/ssh'

# Get the option from the command line
#dir = ARGV[0]
option = ARGV[0]
hosts = File.open(ENV["HOME"] + "/u/hosts.txt") # "/home/a841972/u/hosts.txt
# Read the file and store the hosts in a list
lista = hosts.readlines.map(&:chomp)
case option
when 'p'
  puts "Ejecutando ping sobre las máquinas definidas: \n"
    lista.each do |host|
        if Net::Ping::TCP.new(host,22,0.2).ping? # puerto 22, timeout 0.1
            puts "#{host} FUNCIONA"
        else
            puts "#{host} falla"
        end

    end
when 's'
    command= ARGV[2]
    puts "Ejecutando ssh sobre las máquinas definidas: \n"
    lista.each do |host|
        Net::SSH.start(host,"a841972" ,keys: ["~/.ssh/id_rsa"]) do |ssh|
            puts "Ejecutando comando: #{command} en #{host}"
            result = ssh.exec!(command)
            puts result
        end
    end
else
  # Handle other options
  puts "Opción no válida"
end
