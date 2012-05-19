
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

class Site; attr_accessor :gallery; end

class GalleryPost < Post
    def initialize(site, base, source, image)
        /^(.*)\.[^\.]*$/ =~ image
        basename = $1

        path = source[base.size()..-1] || ''
        path = path[/^\/?[^\/]+\/(.*)$/,1] || ''

        @imageSource = source
        @imageName = image

        super(site, base, path, basename + '.html')

        #self.process(@name)
        #self.read_yaml(File.join(base, '_layouts'), 'gallery_page.html')

        self.data['image'] = image
    end

    EXT_REGEX = /\.[^\.]*$/

    def read_yaml(base, name)
        # defer this to another file...
        info = name.sub(EXT_REGEX, '.txt')
        galleryLayout = self.site.config['gallery_layout'] || 'gallery_page.html'
        if File.exists? File.join(@imageSource, info)
            super(@imageSource, info)
        else
            super(File.join(@site.source, '_layouts'), galleryLayout) if self.data.nil?
        end

        # ensure there is a layout...
        self.data['layout'] = galleryLayout.sub(EXT_REGEX, '') unless self.data.has_key? 'layout'
    end

    def template
        self.site.config['gallery_permalink_style'] ||
            '/gallery/:categories/:title.html'
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

    def html?; true; end

    def to_liquid
        super.deep_merge({
            "last"  => self.last,
            "first" => self.first })
    end

    def first
        item = self.site.gallery.first
        if item != self
            item
        else
            nil
        end
    end

    def last
        item = self.site.gallery.last
        if item != self
            item
        else
            nil
        end
    end

    def next
      pos = self.site.gallery.index(self)

      if pos && pos < self.site.gallery.length-1
        self.site.gallery[pos+1]
      else
        nil
      end
    end

    def previous
      pos = self.site.gallery.index(self)
      if pos && pos > 0
        self.site.gallery[pos-1]
      else
        nil
      end
    end
end

class GalleryGenerator < Generator
    safe true

    def generate(site)
        if site.layouts.key? 'gallery_page'
            dir = site.config['gallery_dir'] || 'gallery'
            source = File.join site.source, '_gallery'

            site.gallery = []


            Dir.foreach_r(source) do |curDir, file|
                next unless file.downcase =~ /\.(?:png|jpe?g|bmp)$/
                next unless GalleryPost.valid? file
                site.gallery << GalleryPost.new(site, site.source, source, file)
                site.pages << site.gallery.last
            end

            site.gallery.sort!
        else
            raise
        end
    end
end

end
