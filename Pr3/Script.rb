#!/usr/bin/ruby -w
require 'net/ping'
require 'net/ssh'
require 'net/scp'

# Get the option and group or machine from the command line
group_or_machine = ARGV[0]
if group_or_machine == "c"
  boolean = true
  option = ARGV[0]
  group_or_machine = "todas"
else  
  option = ARGV[1]
end
command = ARGV[2]

# Read the hosts file and store the lines in a list
hosts_file = File.open(ENV["HOME"] + "/u/hosts.txt")
lines = hosts_file.readlines.map(&:chomp)

# Create a dictionary to store the groups and their machines
groups = {}
current_group = nil

# Iterate over the lines of the hosts file
lines.each do |line|
  if line.start_with?("-")
    # This is a new group, initialize it
    current_group = line[1..-1]
    # Create a new list for the machines of the group
    groups[current_group] = []
  elsif line.start_with?("+")
    # This is an existing group
    existing_group = line[1..-1]
    # Add the machines of the existing group to the current group
    groups[current_group] += groups[existing_group]
  elsif !line.empty?
    # This is a machine
    groups[current_group] << line
  end
end

# Get the machines to execute the command on
machines = if group_or_machine
  if groups.has_key?(group_or_machine)
    # This is a group
    groups[group_or_machine]
  else
    # This is a machine
    [group_or_machine]
  end
else
  # No group or machine provided, execute on all machines
  groups.values.flatten
end

# Execute the command on the machines
machines.each do |machine|
  if !machine.empty?
    case option
    when 'p'
      if Net::Ping::TCP.new(machine, 22, 0.2).ping?
        puts "#{machine} FUNCIONA"
      else
        puts "#{machine} falla"
      end
    when 's'
      Net::SSH.start(machine, "a841972", keys: ["~/.ssh/id_rsa"]) do |ssh|
        puts "Ejecutando comando: #{command} en #{machine}"
        result = ssh.exec!(command)
        puts result
      end
    when 'c'
      Net::SSH.start(machine, "a841972", keys: ["~/.ssh/id_rsa"]) do |ssh|
        if (boolean == true)
          init =1
        else
          init = 2
        end
        ARGV[init..-1].each do |manifest|
          timestamp = Time.now.to_i
          remote_file = "/tmp/#{File.basename(manifest)}_#{timestamp}"
          puts "Copiando manifiesto #{manifest} a #{machine}"
          Net::SCP.upload!(machine, "a841972", File.join(ENV["HOME"], "u", "manifiestos", manifest), remote_file)
          puts "Aplicando manifiesto #{manifest} en #{machine}"
          result = ssh.exec!("sudo puppet apply #{remote_file}")
          puts result
          ssh.exec!("rm #{remote_file}")
        end
      end
    else
      puts "Opción no válida"
    end
  end
end
