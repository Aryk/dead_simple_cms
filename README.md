Dead Simple CMS
======

Dead Simple CMS is a library for modifying different parts of your website without the overhead of having a
fullblown CMS. The idea with this library is simple: provide an easy way to hook into different parts of your
application (not only views) by defining the different parts to modify in an easy, straight-forward DSL.

The basic components of this library include:

 * A DSL to define the changeable values in your app
 * Form generators based on SimpleForm (with or without Bootstrap) and default rails FormBuilder
 * Expandable storage mechanisms so you can store the data in different locations
   * Currently supported: Redis, Database, Memcache, even Memory (for testing)
 * Presenters/renderers so you can take groups of variables and render them into your views (ie image_tag)

What it doesn't have:

 * Versioning - be able to look at old versions of the content
 * Timing - set start and end time for different content
 * Page builder tools - this is not the right tool if you want to design full pages

Setup
------------

If you're Redis store isn't persistence, you can use the default option of using the database.
If you decide to use the database, you can create the schema with this:

```ruby
  create_table :dead_simple_cms, :force => true do |t|
    t.string :key
    t.text :value
    t.timestamps
  end
  add_index :dead_simple_cms, :key, :unique => true
```

Configuration
-------------


Setup
-----

For now, you'll have to create the migration on your own:

```ruby
class CreateDeadSimpleCMS < ActiveRecord::Migration
  def self.up
    create_table :dead_simple_cms do |t|
      t.string :key
      t.index :key, :unique => true
      t.text :value
      t.blob :data
      t.timestamps
    end
  end

  def self.down
    drop_table :dead_simple_cms
  end
end
```

Meta
----

Dead Simple CMS was originally written in two days and came out of the real business
needs of [mixbook.com](http://www.mixbook.com).

We're based in Palo Alto (near California Ave) and we're hiring. We like dogs, beer, and music. If you're passionate
(read: anal) about creating high quality products that makes people happy, please reach out to us at jobs@mixbook.com.


Author
------

Aryk Grosz :: aryk.grosz@gmail.com :: @arykg