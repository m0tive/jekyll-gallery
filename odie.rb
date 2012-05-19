
class Dir
    def self.foreach_r(dir, &block)
        foreach(dir) do |file|
            next if file[0] == '.'

            path = File.join(dir, file)
            next if File.symlink? path

            if File.directory? path
                foreach_r(path, &block)
            else
                yield dir, file
            end
        end
    end
end

module Jekyll

class GalleryPost < Page
    def initialize(site, base, dir, source, image)
        /^(.*)\.[^\.]*$/ =~ image
        basename = $1

        path = source[base.size()..-1] || ''
        path = path[/^\/?[^\/]+\/(.*)$/,1] || ''

        @site = site
        @base = base
        @dir = File.join dir, path
        @name = basename + '.html'

        @imageSource = source
        @imageName = image

        self.process(@name)
        self.read_yaml(File.join(base, '_layouts'), 'gallery_page.html')
        self.data['image'] = image
    end

    def write(dest)
        super(dest)

        # Copy the image to the dest dir
        #
        source = File.join(@imageSource, @imageName)

        imageDest = destination(dest)
        imageDest = File.join(File.dirname(imageDest), @imageName)
        FileUtils.cp source, imageDest
    end

    MATCHER = Post::MATCHER

    # Post name validator. Post filenames must be like:
    #   2008-11-05-my-awesome-post.textile
    #
    # Returns <Bool>
    def self.valid?(name)
      name =~ MATCHER
    end

    attr_accessor :date, :slug, :ext

    # Extract information from the post filename
    #   +name+ is the String filename of the post file
    #
    # Returns nothing
    def process(name)
      super(name)
      m, cats, date, slug, ext = *name.match(MATCHER)
      self.date = Time.parse(date)
      self.slug = slug
      self.ext = ext
    rescue ArgumentError
      raise FatalException.new("Gallery post #{name} does not have a valid date.")
    end
end

class GalleryGenerator < Generator
    safe true

    def generate(site)
        if site.layouts.key? 'gallery_page'
            dir = site.config['gallery_dir'] || 'gallery'
            source = File.join site.source, '_gallery'

            Dir.foreach_r(source) do |curDir, file|
                next unless file.downcase =~ /\.(?:png|jpe?g|bmp)$/
                next unless GalleryPost.valid? file
                write_gallery_page(site, dir, curDir, file)
            end
        else
            raise
        end
    end

    def write_gallery_page(site, dir, source, file)
        page = GalleryPost.new(site, site.source, dir, source, file)
        page.render(site.layouts, site.site_payload)
        page.write(site.dest)
        site.pages << page
    end
end

end
