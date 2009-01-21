class TagList < Array
  cattr_accessor :delimiter
  cattr_accessor :level_delimiter
  self.delimiter = ';'
  self.level_delimiter = '>'

  class << self
    def format_tag(str)
      # "linux >  >  vim;tex > xetex"   =>   [linux>vim],[tex>xetex]
      return str.to_s.split(delimiter).map(&:strip).uniq.inject([]) do |s,x|
        s += format_level(x).to_a unless x.blank?
      end
    end

    def format_level(string)
      # "linux >  >  vim"   =>   "linux>vim"
      string.split(level_delimiter).map(&:strip).inject([]) do |s,x|
        x.sub!(/"(.*?)"/,'\1')
        s = ((x.blank?) ? s : (s + x.to_a)) # s will be nil if add nothing
      end.join(level_delimiter)
    end
  end
end
