# load plugin
plugin_path = File.join(File.dirname(__FILE__), *%w(.. .. .. ..))

load File.join(plugin_path, "init.rb")
