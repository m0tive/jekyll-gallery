
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
                write_gallery_page(site, curDir, file)
            end
        else
            raise
        end
    end

    def write_gallery_page(site, source, file)
        page = GalleryPost.new(site, site.source, source, file)
        page.render(site.layouts, site.site_payload)
        page.write(site.dest)
        site.pages << page
    end
end

end
