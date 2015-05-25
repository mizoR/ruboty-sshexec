require 'uri'
require 'net/ssh'

module Ruboty
  module Actions
    module Sshexec
      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def ssh(user_at_host, sshopts={})
          uri        = URI.parse("ssh://#{user_at_host}")
          host, user = uri.host, uri.user
          sshopts    = { number_of_password_prompts: 0, passphrase: false }.merge(sshopts)

          define_method(:ssh_start) do |opts={}, &block|
            opts = opts.dup
            h = opts.delete(:host) || host
            u = opts.delete(:user) || user
            o = sshopts.merge(opts)

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
          ssh_start(ssh_opts) do |ssh|
            begin
              output = ssh.exec!(command)
              message.reply "> Executed: #{executed_opts[:message]}\n>>>\n```\n#{output.chomp}\n```"
            rescue => e
              message.reply "> Error: *#{e.message}*\n>>>\n```\n#{e.backtrace[0..5].join("\n")}\n```"
            end
          end
        end
      rescue => e
        message.reply "> Error: *#{e.message}*\n>>>\n```\n#{e.backtrace[0..5].join("\n")}\n```"
      end
    end
  end
end
