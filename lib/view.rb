require "rubygems"

require "haml"

class View

  def initialize handler
    @manifest_handler = handler
  end

  def create dirname
    Dir::mkdir dirname unless File.exists? dirname

    index = template "index"
    engine = Haml::Engine.new index

    File.open "#{dirname}/index.html", "w" do |file|
      file.puts engine.render( binding )
    end
  end

  def template name
    File.read( File.expand_path( File.dirname( __FILE__ ) +
      "/../view/#{name}.html.haml" ) )
  end

end
