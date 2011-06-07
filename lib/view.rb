require "rubygems"

require "haml"

class View

  def initialize handler
    @manifest_handler = handler
  end

  def create dirname
    assert_dir dirname

    index = template "index"
    engine = Haml::Engine.new index

    File.open "#{dirname}/index.html", "w" do |file|
      file.puts engine.render( binding )
    end

    library_path = "#{dirname}/libraries/"
    assert_dir library_path

    engine = Haml::Engine.new template "library"

    manifests.each do |manifest|
      File.open library_path + manifest["name"] + ".html", "w" do |file|
        @manifest = manifest
        file.puts engine.render( binding )
      end
    end

  end

  def m attr
    @manifest[ attr ]
  end

  def link_to_manifest name
    "<a href=\"libraries/#{name}.html\">#{name}</a>"
  end

  def manifests
    if @manifest_handler.manifests.empty?
      @manifest_handler.read_remote
    end
    @manifest_handler.manifests
  end

  private
  
  def assert_dir name
    Dir::mkdir name unless File.exists? name
  end    
  
  def template name
    File.read( File.expand_path( File.dirname( __FILE__ ) +
      "/../view/#{name}.html.haml" ) )
  end

end
