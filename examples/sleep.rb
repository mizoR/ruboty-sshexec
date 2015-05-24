require 'ruboty'

module Ruboty
  module Handlers
    class Sleep < Base
      env :SSH_USER_AT_HOST, 'Remote hostname and user.'
      env :SSH_PASSWORD,     'Remote password'

      on %r|sleep ([1-9])$|, name: 'sleep'

      def sleep(message)
        Ruboty::Actions::Sleep.new(message).call
      end
    end
  end

  module Actions
    class Sleep < Base
      include Sshexec
      ssh ENV['SSH_USER_AT_HOST'], password: ENV['SSH_PASSWORD']

      def call
        sec = message[1].to_i

        sshexec "sleep #{sec}; echo '(*ﾟﾛﾟ)ｶﾞﾊﾞｯ!!'",
          executes: {message: "I'll sleep for #{sec} seconds."},
          executed: {message: "I slept for #{sec} seconds."}
      end
    end
  end
end
