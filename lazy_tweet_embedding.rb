require "open-uri"
require "json"

module Jekyll

  # convert tweet url to embedding html
  class LazyTweetEmbedding
    def embed(content)
      embedded_content = content
      content.scan(/^(https?:\/\/twitter\.com\/[a-zA-Z0-9_]+\/status\/([0-9]+)\/?)$/).each do |url, id|
        tweet_json = open("https://api.twitter.com/1/statuses/oembed.json?id=#{id}").read
        tweet_html = JSON.parse(tweet_json, { :symbolize_names => true })[:html]
        embedded_content = embedded_content.gsub(/#{url}/, tweet_html)
      end
      embedded_content
    end
  end

  # for markdown, extend oroginal parser's convert method
  module Converters
    class Markdown < Converter
      alias_method :parser_converter, :convert

      def convert(content)
        parser_converter(Jekyll::LazyTweetEmbedding.new.embed(content))
      end
    end
  end

  # for html, extend converter as a plugin
  class EmbeddingTweetIntoHTML < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /^\.html$/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      Jekyll::LazyTweetEmbedding.new.embed(content)
    end
  end

end
