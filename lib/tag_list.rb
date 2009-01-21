class TagList < Array
  cattr_accessor :delimiter
  cattr_accessor :level_delimiter
  self.delimiter = ';'
  self.level_delimiter = '>'

  class << self
    def format_tag(str)
      return str.to_s.split(delimiter).map(&:strip).uniq.inject([]) do |s,x|
        s += format_level(x).to_a unless x.blank?
      end
    end

    def format_level(string)
      result = string.split(level_delimiter).map(&:strip).inject([]) do |s,x|
        x.sub!(/"(.*?)"/,'\1')
        s = ((x.blank?) ? s : (s + x.to_a))
      end
      return result.join(level_delimiter)
    end
  end
end
