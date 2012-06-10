Jekyll Gallery Plugin
=====================

This plugin adds easy to manage galleries to [Jekyll](http://jekyllrb.com). There is a basic example of the plugin in use [here](http://m0tive.github.com/jekyll-gallery-example/).

Read more about Jekyll plugins in the [Jekyll docs](https://github.com/mojombo/jekyll/wiki/Plugins).

Installation
------------

In the directory containing you're Jekyll site:

* Add `gallery.rb` to the `_plugins` folder of your Jekyll site. 
* Add a layout `gallery_post.html` to the `_layouts` folder (or copy the example from this folder.

To enable the use of exif information to automatically identify photo dates you must install the gem [exifr](http://exifr.rubyforge.org/).

Features
--------

The Gallery plugin adds a new type of item to a site, the `GalleryPost`. These posts are generated using the images found in the gallery directory `_gallery`.

Images can be named following the normal Jekyll post naming style `YYYY-MM-DD-Post-Title.ext` or can exclude the date. If the date is excluded either the file creation time will be used or, if the `exifr` gem is installed, the photo's capture date will be used.

### Site

The Jekyll `site` variable has been extended to contain `site.gallery`, a reverse chronological list of GalleryPosts similar to `site.posts`.

### Page

On GalleryPost pages, the following have been added to the page data.

* `page.image` - The URL of the GalleryPost's image.
* `page.image_info` - The contents of the images info file. See __Info Files__ below for more info.
* `page.next` - The URL of the next chronological GalleryPost or empty if there at the latest GalleryPost.
* `page.previous` - The URL of the previous chronological GalleryPost or empty if there at the earliest GalleryPost.
* `page.last` - The URL of the latest GalleryPost or empty if there at the latest GalleryPost.
* `page.first` - The URL of the earliest GalleryPost or empty if there at the earliest GalleryPost.

### Info Files

Because images cannot contain [YAML Front Matter](https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter), each gallery image can have an optional image file. These files have the same name as the image, but with the extension `.txt`, so `2012-01-01-Happy-New-Year.jpg` would have the info file `2012-01-01-Happy-New-Year.txt`.

Info files can be used to change the date, title or layout for any GalleryPost. The content of an info file can be accessed in the GalleryPost's layout using `page.image_info`.

### Config

Gallery configuration options available in `_config.yaml`:

* `gallery_dir` - Specify the directory containing the original gallery images. (default: `_gallery`)

* `gallery_layout` - Set the layout to use for gallery posts. (default: `gallery_post.html`)

* `gallery_permalink_style` - Similar to `permalink`, controls the URLs that gallery posts are generated with. See Jeykll docs [Permalinks](https://github.com/mojombo/jekyll/wiki/Permalinks) page. (default: `/gallery/:categories/:title.html`)

Todo
----

* Multiple galleries.
* Specify time for images using EXIFR, not just the date.

Author
------

[Peter Dodds](http://pddds.com)

License
-------

MIT, see `LICENSE.txt`
