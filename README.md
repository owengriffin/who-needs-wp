# who-needs-wp
_Who needs Wordpress?_

The majority of web sites are consumed. Visitors will stumble upon the site, read a few pages (if you're lucky) and then disappear. Normally for every visitor to the site each webpage is generated dynamically. Each visitor has their own version of the web page for that particular moment of time. Is this really necessary? How often does the content on the web site you are visiting change?

Take blogs for example. I have a blog written using the excellent Wordpress software. I'm able to write posts within Wordpress and see them appear on the web site without leaving my web browser. My posts are held in a database, when a user requests to view my blog multiple requests are made to the database to build a dynamic page on which contents rarely changes. I create a new blog post every 3 weeks, it seems a bit unnecessary to generate a web page when the content hasn't changed.

There is another option. Instead of generating the web site dynamically when the page is requested I can generate the web page whenever the content changes. So whenever I create a new post - I regenerate the site. 

This has the advantage of serving web pages faster; I use less hosting space; and I cut any unnecessary features which Wordpress provides.

The main disadvantage is that user's aren't able to comment on my posts - but this don't matter too much - nobody ever did! ;-)

## Getting Started

`who-needs-wp` is a small Ruby program which helps generate static web sites. To start using `who-needs-wp` you need to install Ruby. On Ubuntu enter the following into a command prompt:

    sudo apt-get install ruby ruby-dev rubygems
    
You then need to install `who-needs-wp` by running the following:

    sudo gem install who-needs-wp
    
Ensure that Ruby gems is in your `PATH` variable by opening `~/.bashrc` and entering:

    export PATH=/var/lib/gems/1.8/bin:$PATH

You'll need to re-load the `.bashrc` file by using the following command:

    . ~/.bashrc
    
Now create a folder which will host your web site

    mkdir /var/www/website/
    
`who-needs-wp` stores posts in the `posts/` folder followed by a folder representing the date of the post. i.e. `posts/year/month/day`.

Create an example post by creating a folder and creating a Markdown file.

    mkdir /var/www/website/posts/2010/03/15/ --parents
    gedit /var/www/website/posts/2010/03/15/An_example_post.markdown
    
The filename will be used as the title for the page - all the underscores will be replaced with spaces.

Along with [Markdown Syntax][MarkdownSyntax] you can also specify the author of the blog post within the file:

    Author: Your Name

Before it can generate the site `who-needs-wp` needs to be configured. Copy the following into `/var/www/website/.who-needs-wp.yaml`

    --- 
    :url: /website/test
    :title: An example blog
    :author: Your Name

These are the properties which are used to generate the website:

* `url` - The base URL of the website
* `title` - A title for the index of your site
* `author` - When a author is not specified within the post this author is displayed

Now you can generate your site:

    who-needs-wp .
    
And view the blog at the following URL:

    http://localhost/website/

## Overriding Templates

You will probably find that the templates used by `who-needs-wp` don't quite match your requirements. You can override any of the templates by creating a `templates` folder. You can copy the existing templates from the gem as a starting point. The templates are stored within the `/var/lib/gems/1.8/gems/who-needs-wp-0.1.0/lib/who-needs-wp/templates/`. 

## Applying alternative styles

You can specify an additional stylesheet by using the `-s` or `--stylesheet` option to the `who-needs-wp` command.

## Twitter

`who-needs-wp` can place a [Twitter][Twitter] stream in the side bar. This can either be a search or an individual user's feed.

Modifying `.who-needs-wp.yaml` and add:

    :twitter:
      :user: <your twitter user>
      :search: <your twitter search>
      
## Delicious

`who-needs-wp` can also display a list of bookmarks from [Delicious][Delicious]. Modify `.who-needs-wp.yaml` and add:

    :delicious:
      :user: <your delicious username>

## Syntax Highlighting

`who-needs-wp` will syntax highlight your code snippets using [Makers-Mark][MakersMark] and [Pygments][Pygments]

## Migration from Wordpress

A simple script is in development which will convert a MySQL database to seperate Markdown pages.

### Copyright

Copyright (c) 2010 Owen Griffin. See LICENSE for details.

[Markdown]: http://daringfireball.net/projects/markdown/
[MarkdownSyntax]: http://daringfireball.net/projects/markdown/syntax
[Delicious]: http://del.icio.us/
[Twitter]: http://twitter.com/
[MakersMark]: http://github.com/nakajima/makers-mark
[Pygments]: http://pygments.org/
