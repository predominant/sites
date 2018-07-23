---
title: "Building My Site With Cakephp - Stage 1"
date: 2008-09-09T00:00:00+09:00
highlight: true
draft: false
---

The old favourite blog tutorial.

Its changes somewhat from when I was learning CakePHP back in the day, and I do feel that people following through the latest blog tutorial are missing out on the basics of associations and model / controller interactions within CakePHP. The current form is just not as thorough as it used to be.

As part of the redesign and redevelopment of my own site, I am posting entries about the process I am going through to complete it. This will act as a resource for anyone that needs assistance with the various tasks required to complete a site like this in CakePHP, and the issues and resolutions as they arise.

Initially, I started with the basics. And like all good applications, we start with planning and a database design.

Initially we want:

* Posts
* Tags
* Comments
* Spam Filtering

I created the following database structure based on the information I wanted to store. Note that I have prefixed everything with blog_. This is just for my own personal benefit, as it allows all the blog related data to be situated together when browsing the database with any database management tool like PHPMyAdmin.

Here is the Schema:

```sql
CREATE TABLE `blog_posts` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(125),
  `content` TEXT,
  `published` TINYINT(1) NOT NULL DEFAULT 0,
  `deprecated` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted_date` DATETIME,
  `created` DATETIME,
  `modified` DATETIME,
  PRIMARY KEY (`id`),
  INDEX(`slug`)
);

CREATE TABLE `blog_comments` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `blog_post_id` INT(11) UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `url` VARCHAR(255),
  `content` TEXT,
  `spam` TINYINT(1) NOT NULL DEFAULT 0,
  `false_spam` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted_date` DATETIME,
  `created` DATETIME,
  `modified` DATETIME,
  PRIMARY KEY(`id`)
);

CREATE TABLE `blog_tags` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted_date` DATETIME,
  `created` DATETIME,
  `modified` DATETIME,
  PRIMARY KEY(`id`)
);

CREATE TABLE `blog_posts_blog_tags` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `blog_post_id` INT(11) UNSIGNED NOT NULL,
  `blog_tag_id` INT(11) UNSIGNED NOT NULL,
  PRIMARY KEY(`id`)
);

CREATE TABLE `settings` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `value` VARCHAR(150) NOT NULL,
  PRIMARY KEY(`id`),
  INDEX(`name`)
);
INSERT INTO `settings` (`name`, `value`) VALUES
('akismet_server', 'rest.akismet.com'),
('akismet_port', '80'),
('akismet_version', '1.1'),
('akismet_key', 'mykeyhere'),
('blog_url', 'http://grahamweldon.com');
```

To explain this a little, comments belong to posts. This is because a comment is only added with reference to a single post. We can't really post a comment about two blog entries at the same time. So: BlogComment belongsTo BlogPost.

Next, we have posts and tags. A tag is sort of like a category that a post will belong to. We can have then a tag cloud, if we want, or a filtering system so visitors can limit their view to just posts about a certain topic. The relationship here is a HABTM (HasAndBelongsToMany / Has And Belongs To Many). This is because one post may have many tags associated with it (Post about CakePHP might be tagged with "Programming", "Web", and "My site"), and a tag can be assigned to many posts ("My site" tag migt be attached to a range of posts as I develop my site). This requires a join table, so we can store what posts are associated with what tags.

Enter the BlogPostsBlogTags table. This stores the id of a post, and the id of a tag. It also has a simple auto_incrementing id just for good measure. The last table is somewhat unrelated, but will be used for a variety of things throughout the site. This is the settings table. Its just a set of name and value pairs, and will probably extend to include a description later, but its not necessary right now.

So our associations are as follows:

* BlogPost hasMany BlogComment
* BlogComment belongsTo BlogPost
* BlogPost hasAndBelongsToMany BlogTag
* BlogTag hasAndBelongsToMany BlogPost

The next part was pretty easy. I wanted to just get up and running with everything in a basic form, and customise from there.

Cake's bake shell is great for this. For those of you on windows, I'm unfortunately not considerate enough to convert the following commands into windows ones for you, but anyone with a handle on a command prompt should get the gist of what I am doing here, and be able to convert them into commands for whatever operating system you are using.

Whilst situated in your "app" directory, run the bake script:

```bash
$ ../cake/console/cake bake
```

You are presented with a list of options. You should bake all the Models, then all the controllers, then all the views.

Be sure to read the options carefully and create the assocations properly.

Once you are done, you should end up with a plethora of files in /app/models, /app/controllers and /app/views. You should now also be able to head to http://yoursite.com/blog_posts and see an empty table, that would list blog posts if you had any.

Oooh, Ahh, fancy.

Those URLs look a bit shite.

What you probably want is http://yoursite.com/blog but I managed to stuff it up because I wanted to call it "blog_posts". Grab your routes.php from /app/config/routes.php and underneath the first Router::connect statement, add another one:

```php
Router::connect('/blog/:action/*', array('controller' => 'blog_posts'));
```

This tells the router that if we see "/blog" then what we want to do is route any actions through to the blog_posts controller. This keeps our database and controllers etc the same, but presents as a nice URL.

Go ahead and try browsing to http://yoursite.com/blog. It will give you the same output as /blog_posts. In fact, CakePHP is so clever, it will use these routing rules to rewrite any links you provider later in your code to use the shiney new URL.

As it is, we've got most of the code there ready to go (Thanks CakePHP devs!).

You'll see a few links at the bottom of your page linking to a list of BlogTags, and addition of blog tags. Feel free to head on through them and have a play.

Note we included a "slug" field on the blog posts table. Weird. We want to store slugs? Not really. This is an extra field that we'll store some search engine friendly URL information in, so that we can browse to posts with addresses like /blog/view/my-first-post rather than /blog/view/1 While this is a tutorial to show the basic creation of the site, and the introduction to CakePHP basics from scratch, there are some things that really don't need reinventing. Sluggable behavior is sone of them. Mariano Iglesias has kindly created and open source sluggable behavior for CakePHP. What this means is that its an addition to our BlogPost model, in a MVC friendly manner. We need to tell BlogPosts that it needs to act as a Sluggable model, and the code will deal with the rest.

You can read about the Sluggable Behavior here: http://cake-syrup.sourceforge.net/ingredients/sluggable-behavior/

And its always best to checkout the latest revision from SVN, as Mariano is usually on top of changes with CakePHP versions and has the latest working copy committed there: http://cake-syrup.svn.sourceforge.net/viewvc/cake-syrup/trunk/app/models/behaviors/

Grab the sluggable.php file, and save it into your /app/models/behaviors directory.

Next, edit your blog_posts.php model in /app/models and add the following somewhere near the top:

```php
$actsAs = array('Sluggable');
```

Since we've created our database in the same manner as Mariano had intended, we don't need to do anything more than that, and now as we save and edit posts, the slug field is updated automatically.

The defaults that are included are: Title is the field from which we will generate a slug string. Slug is the field in which it will be stored, and "-" is the separator instead of space.

Another useful behavior that we're going to include is SoftDeletable. This is extremely handy just in case you get delete-happy on your favourite posts, and need to restore them. Soft Delete marks database items as deleted, and excludes them from future queries. You can restore these at any time, by altering the SoftDelete behaviour in your admin section of the controller code, to allow deleted items to be displayed. What I will end up doing is creating a trash section, where I can restore or permanently delete items.

This is yet another Mariano creation, and you can find it at: http://cake-syrup.sourceforge.net/ingredients/soft-deletable-behavior/

Just add another entry to the $actsAs array, so it will end up reading:

```php
$actsAs = array('Sluggable', 'SoftDeletable');
```