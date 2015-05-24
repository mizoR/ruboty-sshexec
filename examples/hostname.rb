require 'ruboty'

module Ruboty
  module Handlers
    class Hostname < Base
      env :SSH_USER_AT_HOST, 'Remote hostname and user.'
      env :SSH_PASSWORD,     'Remote password'

      on %r|hostname$|, name: 'hostname'

      def hostname(message)
        Ruboty::Actions::Hostname.new(message).call
      end
    end
  end

  module Actions
    class Hostname < Base
      include Sshexec
      ssh ENV['SSH_USER_AT_HOST'], password: ENV['SSH_PASSWORD']

      def call
        sshexec "hostname"
      end
    end
  end
end
