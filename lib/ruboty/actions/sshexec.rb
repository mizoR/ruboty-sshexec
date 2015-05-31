require 'uri'
require 'net/ssh'

module Ruboty
  module Actions
    module Sshexec
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def ssh(user_at_host, ssh_opts={})
          uri        = URI.parse("ssh://#{user_at_host}")
          host, user = uri.host, uri.user
          ssh_opts   = { number_of_password_prompts: 0, passphrase: false }.merge(ssh_opts)

          define_method(:ssh_start) do |opts={}, &block|
            opts = opts.dup
            h = opts.delete(:host) || host
            u = opts.delete(:user) || user
            o = ssh_opts.merge(opts)

            Net::SSH.start(h, u, o) { |ssh| block.call(ssh) }
          end
        end
      end

      def ssh_exec(command, opts={})
        executes_opts = opts[:executes] || {}
        executed_opts = opts[:executed] || {}
        ssh_opts      = opts[:ssh_options] || {}

        message.reply "> Executes: #{executes_opts[:message]}\n>>>\n```\n$ #{command}\n```"
        Thread.start do
          begin
            ssh_start(ssh_opts) do |ssh|
              output = ssh.exec!(command)
              str = "> Executed: #{executed_opts[:message]}"
              str << "\n>>>\n```\n#{output.chomp}\n```" if output
              message.reply str
            end
          rescue => e
            message.reply "> Error: *#{e.message}*\n>>>\n```\n#{e.backtrace[0..5].join("\n")}\n```"
          end
        end
      rescue => e
        message.reply "> Error: *#{e.message}*\n>>>\n```\n#{e.backtrace[0..5].join("\n")}\n```"
      end
    end
  end
end
