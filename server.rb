require 'eventmachine'
require 'em-websocket'

# List of admins IPs
CONNECTION_ADMIN = ['127.0.0.1','192.168.1.22','192.168.1.111','192.168.43.64','192.168.43.85']
# Monitored IPs
CONNECTION_ALLOW = ['127.0.0.1','192.168.1.22','192.168.1.111','192.168.43.64','192.168.43.85']
# Store connections
CONNECTION = []

class EM::WebSocket::Connection
  def remote_addr
    get_peername[2,6].unpack('nC4')[1..4].join('.')
  end
end

class MonitConnection < EventMachine::WebSocket::Connection
  def initialize(opt={})
    super
    onopen {on_open}
    onmessage {|message| on_message(message)}
    onclose {on_close}
  end

  def on_open
    remote_addr = self.remote_addr
    if CONNECTION_ALLOW.include?(remote_addr)
      Monit.add_connection self
    else
      puts "#{remote_addr} connection blocked"
    end
  end

  def on_message(message)
    # Check if ADMIN send command
    if CONNECTION_ADMIN.include?(remote_addr)
      # add IP to CONNECTION_ALLOW
      if message =~ /^ADD/i
        puts message.match(/ADD (.*)/)[1]
        CONNECTION_ALLOW.push message.match(/ADD (.*)/)[1]
      end

      # remove IP from CONNECTION_ALLOW
      if message =~ /^REMOVE/i
        puts message.match(/REMOVE (.*)/)[1]
        CONNECTION_ALLOW.delete message.match(/REMOVE (.*)/)[1]
      end
    end

    # Send message to ADMIN
    remote_addr = self.remote_addr
    if CONNECTION_ALLOW.include?(remote_addr)
      puts "#{self.remote_addr} Message: #{message}"
      Monit.send_to_admin message
    end
  end

  def on_close
    Monit.delete_connection self
  end
end


module Monit
  module_function

  def add_connection(connection)
    remote_addr = connection.remote_addr
    if CONNECTION_ALLOW.include?(remote_addr)
      puts "#{remote_addr} new connection"
      CONNECTION.push connection
    else
      puts "#{remote_addr} connection blocked"
      raise 'An error has occured. #{remote_addr} connection blocked'
    end
  end

  def delete_connection(connection)
    puts "connection closed"
    CONNECTION.delete connection
  end

  def send_to_admin(message)
    CONNECTION.each do |connection|
      if CONNECTION_ADMIN.include?(connection.remote_addr)
        connection.send message
      end
    end
  end
end

EM.run do
  EM.start_server '0.0.0.0', '8080', MonitConnection
end
