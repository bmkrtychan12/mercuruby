require "uri"
require "rss"
require "redis"
require "yaml"

data = YAML.load_file("settings.yaml")
redis = Redis.new(url: data["redis_url"])
rss_urls = File.read("urls")

loop do
  rss_urls.split("\n").each do |url|
    open(url) do |rss|
      feed = RSS::Parser.parse(rss, false)
      pure_url = URI.extract(feed.items[0].link.to_s).first
      article = "#{feed.items[0].title}\n#{pure_url}"
      # puts redis.get(url)
      redis.set(url, "nil") if redis.get(url).nil?
      # puts pure_url
      if redis.get(url) != pure_url
        puts article
        redis.set(url, pure_url)
      end
    end
  end

  sleep data["sleep_timer"].to_time
end
