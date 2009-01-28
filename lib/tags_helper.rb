module TagsHelper
  # linux>vim>ruby
  #  <li><a href='/tags/linux'>linux</a>
  #    <ul>
  #      <li><a href='/tags/linux>vim'>vim</a>
  #        <ul><li><a href='/tags/linux>vim>ruby'>ruby</a></li></ul>
  #      </li>
  #    </ul>
  #  </li>
  def taglist(tag='')
    (tag.blank? ? Tag.roots : tag.children).inject('<ul>') do |s,x|
      s << "<li><a href='/tags/#{x.fullname}'>#{x.name}</a>#{x.children? ? taglist(x):''}</li>"
    end + "</ul>"
  end

  # linux>vim>ruby
  # <a href='/tags/linux'>linux</a>><a href='/tags/linux>vim'>vim</a>><a href='/tags/linux>vim>ruby'>ruby</a>;
  def tagslink(tags)
    tags.inject('') do |s,x|
      tag = x.split('>')
      s += (1..tag.size).inject([]) do |z,y|
        z << "<a href='/tags/#{tag.first(y).join('>')}'>#{tag[y-1]}</a>"
      end.join('>') + ';'
    end
  end
end
