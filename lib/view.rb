require "rubygems"

require "haml"

class View

  def initialize handler
    @manifest_handler = handler
  end

  def create output_dir
    assert_dir output_dir

    assert_dir "#{output_dir}/public"
    system "cp #{view_dir}/public/* #{output_dir}/public/"

    index = template "index"
    engine = Haml::Engine.new index

    File.open "#{output_dir}/index.html", "w" do |file|
      file.puts engine.render( binding )
    end

    library_path = "#{output_dir}/libraries/"
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
    File.read( view_dir + "#{name}.html.haml" )
  end

  def view_dir
    File.expand_path( File.dirname( __FILE__ ) + "/../view/" ) + "/"
  end

end
