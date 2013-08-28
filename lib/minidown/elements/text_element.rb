require 'cgi'

module Minidown
  class TextElement < Element
    EscapeChars = %w{# > * + \- ` _}
    EscapeRegexp = /\\([#{EscapeChars.join '|'}])/
    
    Regexp = {
      tag: /&lt;(.+?)&gt;/,
      quot: /&quot;/,
      link: /\[(.+)\]\((.+)\)/,
      link_title: /((?<=").+(?="))/,
      link_url: /(\S+)/,
      link_ref: /\[(.+?)\]\s*\[(.*?)\]/,
      star: /((?<!\\)\*{1,2})(\S+?)\1/,
      underline: /\A\s*((?<!\\)\_{1,2})(\S+)\1\s*\z/,
      quotlink: /\<(.+)\>/,
      link_scheme: /\A\S+\:\/\//,
      email: /\A.+@/
    }

    attr_accessor :escape, :convert
    
    def initialize *_
      super
      @escape = true
      @convert = true
    end
    
    def parse
      nodes << self
    end

    def content
      str = super
      convert_str(str) if convert
      str.gsub!(EscapeRegexp, '\\1') if escape
      str = CGI.escape_html str
      str.gsub! Regexp[:tag] do
        tag = $1
        tag.gsub! Regexp[:quot] do
          '"'
        end
        "<#{tag}>"
      end
      str
    end

    def convert_str str
      #parse <link>
      str.gsub! Regexp[:quotlink] do |origin_str|
        link = $1
        attr = case link
               when Regexp[:link_scheme]
                 {href: link}
               when Regexp[:email]
                 {href: "mailto:#{link}"}
               end
        attr ? build_tag('a', attr){|a| a << link} : origin_str
      end
      
      #parse * _
      Regexp.values_at(:star, :underline).each do |regex|
        str.gsub! regex do |origin_str|
          tag_name = $1.size > 1 ? 'strong' : 'em'
          build_tag tag_name do |tag|
            tag << $2
          end
        end
      end
      
      #convert link reference
      str.gsub! Regexp[:link_ref] do |origin_str|
        text = $1
        id = ($2 && !$2.empty?) ? $2 : $1
        ref = doc.links_ref[id.downcase]
        if ref
          attr = {href: ref[:url]}
          attr[:title] = ref[:title] if ref[:title] && !ref[:title].empty?
          build_tag 'a', attr do |a|
            a << text
          end
        else
          origin_str
        end
      end

      #convert link syntax
      str.gsub! Regexp[:link] do
        text, url = $1, $2
        url =~ Regexp[:link_title]
        title = $1
        url =~ Regexp[:link_url]
        url = $1
        attr = {href: url}
        attr[:title] = title if title
        build_tag 'a', attr do |content|
          content << text
        end
      end
    end

    def paragraph
      ParagraphElement.new doc, raw_content
    end

    def to_html
      content
    end
  end
end
