class Settings

  def manifest_dir
    local_dir "manifests"
  end

  def cache_dir
    local_dir "cache"
  end

  def version
    "0.0.1"
  end

  private

  def local_dir dirname
    home = ENV["HOME"] + "/.inqlude/"
    Dir::mkdir home unless File.exists? home
    path = home + dirname
    Dir::mkdir path unless File.exists? path
    path
  end

end
