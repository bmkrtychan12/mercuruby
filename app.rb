require "rss"
require "redis"
require "yaml"

data = YAML.load_file("settings.yaml")
redis = Redis.new(url: data["redis_url"])
rss_urls = File.read("urls")

loop do
  rss_urls.split("\n").each do |url|
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        article = "#{item.title}\n#{item.link}"
        if redis.get(url) < item.date
          puts article
          redis.set(url, item.date)
        end
      end
    end
  end

  sleep data["sleep_timer"]
end