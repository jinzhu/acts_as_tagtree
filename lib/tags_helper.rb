module TagsHelper
  # Linux>Vim>Ruby
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
end
