module BceExplorer
  # Helper for Explorer app views
  module ExplorerHelper
    def partial(page, options = {})
      haml page.to_sym, options.merge!(layout: false)
    end

    def coin_amount(value)
      format("%0.08f #{coin_tag}", value.abs)
    end

    def coin_percent(coins)
      supply = @cache.cache_for('money_supply', 60 * 60) do # cache for an hour
        @client.money_supply.to_s
      end.to_f
      format('%0.02f %', (coins.abs / supply) * 100.0)
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
      return 'a day ago' if days == 1
      return "#{days} days ago" if days < 30
    end
  end
end
