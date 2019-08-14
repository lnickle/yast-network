require "yast"
require "y2network/config"
require "y2network/interface_config_builder"

module Y2Network
  module InterfaceConfigBuilders
    class Wireless < InterfaceConfigBuilder
      include Yast::Logger

      def initialize(config: nil)
        super(type: InterfaceType::WIRELESS, config: config)
      end

      def mode
        select_backend(
          @config["WIRELESS_MODE"],
          @connection_config.mode
        )
      end

      def mode=(mode)
        @config["WIRELESS_MODE"] = mode
        @connection_config.mode = mode
      end

      def essid
        select_backend(
          @config["WIRELESS_ESSID"],
          @connection_config.essid
        )
      end

      def auth_modes
        Yast::LanItems.wl_auth_modes
      end

      def auth_mode
        select_backend(
          @config["WIRELESS_AUTH_MODE"],
          @connection_config.auth_mode
        )
      end

      def auth_mode=(mode)
        @config["WIRELESS_AUTH_MODE"] = mode
        @connection_config.auth_mode = mode
      end

      def eap_mode
        select_backend(
          @config["WPA_EAP_MODE"],
          @connection_config.eap_mode
        )
      end

      def eap_mode=(mode)
        @config["WIRELESS_EAP_MODE"] = mode
        @connection_config.eap_mode = mode
      end

      def access_point
        select_backend(
          @config["WIRELESS_AP"],
          @connection_config.ap
        )
      end
    end
  end
end
