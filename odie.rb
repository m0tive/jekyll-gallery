
module Jekyll

class OdieGalleryIndex < Page
    def initialize(site, base, dir, category)
    end
end

class OdieGalleryGenerator < Generator
    safe true

    def generate(site)
        @@layout = site.config['gallery_layout'] || 'gallery'

        unless site.layouts.key? @@layout
            $stderr.puts 'WARNING: Could not read gallery layout ' + @@layout.inspect
            return
        end

        @galleries = site.config['gallery_dir'] || '_gallery'
        # ensure galleries is a hash starting with a named items...
    end
end

end
