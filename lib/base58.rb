require 'digest/sha2'

module BceExplorer
  # Public key also known as address
  # This code was found here:
  # http://rosettacode.org/wiki/Bitcoin/address_validation#Ruby
  class Base58Check
    class << self
      #  Nigel_Galloway
      #  October 13th., 2014
      N = [0, 1, 2, 3, 4, 5, 6, 7, 8, nil, nil, nil, nil, nil, nil, nil,
           9, 10, 11, 12, 13, 14, 15, 16, nil, 17, 18, 19, 20, 21, nil,
           22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
           nil, nil, nil, nil, nil, nil,
           33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, nil,
           44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57]

      def valid?(address)
        sum = address.bytes.inject(0) { |a, e| a * 58 + N[e - 49] }.to_s(16)
        hex = sum.slice!(0..-9)
        (hex.length...42).each { hex.insert(0, '0') }
        checksum(hex) == sum
      end

      private

      def checksum(hex)
        b = [hex].pack('H*') # unpack hex
        Digest::SHA256.hexdigest(Digest::SHA256.digest(b))[0...8]
      end
    end
  end
end
