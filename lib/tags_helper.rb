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
    (tag.blank? ? Tag.roots : tag.children).inject('') do |html,x|
      html << "<li><a href='/tags/#{x.fullname}'>#{x.name}</a>" +
        (x.children? ? "<ul>#{taglist(x)}</ul>" : '') + "</li>"
    end
  end
end
