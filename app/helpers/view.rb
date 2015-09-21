module BceExplorer
  module View
    # Helpers to format data in views
    module Helpers
      def partial(page, options = {})
        haml page.to_sym, options.merge!(layout: false)
      end

      def shorten_hash(hash_line)
        "#{hash_line[0..9]}..."
      end

      def coin_amount(value)
        format("%0.08f #{coin_tag}", value.abs)
      end

      def coin_percent(coins)
        @_money_supply ||= @client.money_supply
        format('%0.02f %', (coins.abs / @_money_supply) * 100.0)
      end

      def coin_tag
        @coin_info['Tag']
      end

      def human_time(tim)
        Time.at(tim.to_i).strftime('%F %H:%M')
      end

      def time_ago(tim)
        seconds = Time.now.to_i - tim.to_i
        if seconds < 60
          'just now'
        else
          str = time_ago_minutes(seconds / 60)
          str ||= human_time(tim)
          str
        end
      end

      private

      def time_ago_minutes(minutes)
        if minutes == 1
          'a minute ago'
        else
          if minutes < 60
            "#{minutes} minutes ago"
          else
            time_ago_hours(minutes / 60)
          end
        end
      end

      def time_ago_hours(hours)
        if hours == 1
          'an hour ago'
        else
          if hours < 24
            "#{hours} hours ago"
          else
            time_ago_days(hours / 24)
          end
        end
      end

      def time_ago_days(days)
        'some days ago' if days <= 7
      end
    end
  end
end
