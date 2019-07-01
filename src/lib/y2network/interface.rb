# Copyright (c) [2019] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "y2network/interface_type"

module Y2Network
  # Network interface.
  class Interface
    # @return [String] Device name ('eth0', 'wlan0', etc.)
    attr_accessor :name
    # @return [String] Interface description
    attr_accessor :description
    # @return [Symbol] Interface type
    attr_accessor :type
    attr_reader :configured
    attr_reader :hardware

    # Shortcuts for accessing interfaces' ifcfg options
    ["STARTMODE", "BOOTPROTO"].each do |ifcfg_option|
      method_name = ifcfg_option.downcase

      define_method method_name do
        # when switching to new backend we need as much guards as possible
        if !configured || config.nil? || config.empty?
          raise "Trying to read configuration of an unconfigured interface #{@name}"
        end

        config[ifcfg_option]
      end
    end

    # Constructor
    #
    # @param name [String] Interface name (e.g., "eth0")
    def initialize(name, type: InterfaceType::ETHERNET)
      @name = name
      @description = ""
      @type = type
      # @hardware and @name should not change during life of the object
      @hardware = Hwinfo.new(name: name)

      if !(name.nil? || name.empty?)
        @name = name
      elsif @hardware.nil?
        # the interface has to be either configured (ifcfg) or known to hwinfo
        raise "Attempting to create representation of nonexistent interface"
      end

      init(name)
    end

    # Determines whether two interfaces are equal
    #
    # @param other [Interface] Interface to compare with
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Interface)
      name == other.name
    end

    # eql? (hash key equality) should alias ==, see also
    # https://ruby-doc.org/core-2.3.3/Object.html#method-i-eql-3F
    alias_method :eql?, :==

    def config
      system_config(name)
    end

  private

    def system_config(name)
      Yast::NetworkInterfaces.devmap(name)
    end

    def init(name)
      @configured = !system_config(name).nil? if !(name.nil? || name.empty?)
    end
  end
end
