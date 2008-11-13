class TagList < Array
  cattr_accessor :delimiter
  cattr_accessor :level_delimiter
  self.delimiter = ';'
  self.level_delimiter = '>'

  class << self
    def format_tag(string)
      returning [] do |result|
        string.split(delimiter).map(&:strip).uniq.each do |x|
          result << format_level(x) unless x.blank?
        end
      end
    end

    def format_level(string)
      result = []
      string.split(level_delimiter).map(&:strip).each do |x|
        x.sub!(/"(.*?)"/,'\1')
        result << x unless x.blank?
      end
      return result.join(level_delimiter)
    end
  end
end
