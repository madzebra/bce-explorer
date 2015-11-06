module BceExplorer
  # Application environmenet class
  class Env
    class << self
      attr_accessor :root

      def mongo_conf_file
        "#{Env.root}/config/mongo.yml"
      end

      def coins_path
        "#{Env.root}/config/coins"
      end
    end
  end
end
