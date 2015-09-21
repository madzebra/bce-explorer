module BceExplorer
  module Route
    # Helpers to build links
    module Helpers
      ROUTE_METHODS = %w(address block tx)

      ROUTE_METHODS.each do |method|
        define_method "to_#{method}", proc { |id| url("/#{method}/#{id}") }
      end

      ROUTE_METHODS.each do |method|
        define_method \
          "link_to_#{method}",
          proc { |id| "<a href='#{url("/#{method}/#{id}")}'>#{id}</a>" }
      end

      def link_to_tx_short(id)
        "<a href='#{url("/tx/#{id}")}'>#{shorten_hash(id)}</a>"
      end

      def link_to(link)
        "<a href='#{link}'>#{link}</a>"
      end
    end
  end
end
