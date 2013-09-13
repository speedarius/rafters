# Rafters

[![Build Status](https://travis-ci.org/andyhite/rafters.png?branch=master)](https://travis-ci.org/andyhite/rafters)
[![Gem Version](https://badge.fury.io/rb/rafters.png)](http://badge.fury.io/rb/rafters)
[![Code Climate](https://codeclimate.com/github/andyhite/rafters.png)](https://codeclimate.com/github/andyhite/rafters)
[![Coverage Status](https://coveralls.io/repos/andyhite/rafters/badge.png)](https://coveralls.io/r/andyhite/rafters)

Rafters lets you think about each page of your application as a collection of small pieces instead of monolithic, difficult to maintain
views.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rafters'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install rafters
```

## Usage

After you install the Rafters gem, you need to run the following generator:

```sh
$ rails generate rafters:install
```
  
This generator will create an `app/rafters` directory in your application, a `config/initializers/rafters.rb` initializer with some basic configuration, and add the `require_components` directive to your application.css and application.js files.

### Creating a component

When you build out a page using Rafters you're effectively breaking it down into small, easy to digest chunks of code / markup that can optimally be configured and re-used on other pages as well. These bite-sized "views" are called Components, and you can think of them as partials on steroids (with their own "controllers" and templates).

To begin creating a new component, run the following generator:

```sh
$ rails generate rafters:component {name}
```
  
This generator will create the following files:

```
app/rafters/{name}
app/rafters/{name}/{name}_component.rb
app/rafters/{name}/assets/stylesheets/{name}_component.scss
app/rafters/{name}/assets/javascripts/{name}_component.js.coffee
app/rafters/{name}/views/{name}_component.html.erb
```
  
The two most important files generated above are `app/rafters/{name}/{name}_component.rb` and `app/rafters/{name}/views/{name}_component.html.erb`, which are (respectively) our component controller and view.

### Rendering a component

You can render components anywhere - in your view, in your controller, in another component, etc. - but the most common place will (obviously) be in your views. To render a component, call `render_component :component_name, as: "unique-identifier"` in one of your app views. For example:

```erb
...
<div class="main">
  <%= render_component :heading, as: "page-heading" %>
</div>
...
```

### Adding an attribute to a component

Each component exposes `attributes` to it's view as locals. The `attributes` are simply a collection of methods that you explicitly declare as `attributes` in your component, using the `Rafters::Component.attribute` or `Rafters::Component.attributes` methods.

For instance, let's say we have a HeadingComponent that exposes a title attribute:

```ruby
class HeadingComponent
  include Rafters::Component
  
  attribute :title
  
  private
  
  def title
    "Lorem Ipsum"
  end
end
```
  
Since we won't be accessing the `HeadingComponent#title` method directly from within our view, it's recommended to make it a private method. The interface that our component exposes is taken care of behind the scenes.

You can access the method in your component view using the name of the attribute:

```erb
<div class="heading">
  <h1><%= title %></h1>  
</div>
```

### Accessing information from the controller in your components

There will often be times when you need to access data in your component that is only available as an instance variable or method in your controller. Rafters provides a convenience method that lets you get to that data in a uniform way - `Rafters::Component#controller`:

```ruby
class PostController
  ...

  def show
    @post = current_user.posts.find(params[:id])
  end

  private

  def current_user
    @current_user ||= User.authenticate!(...)
  end
  helper_method :current_user
end
```

```ruby
class RelatedPostsComponent
  ...
  
  def related_posts
    @related_posts ||= controller(:post).related_posts.where(author_id: controller(:current_user))
  end
end
```

You can also access the controller's params using this method:

```ruby
controller(:params)[:id]
```
  
### Specifying settings for a component instance

In order to build components in a way that allows for re-use, you'll want to use settings that allow individual instances of the component to be configured. These settings will likely be used throughout your component view and controller for any number of purposes, like values in query conditions, section titles, turning on or off specific features of a component, etc.

Setting values are specified when rendering a component:

```erb
...
<div class="main">
  <%= render_component :posts, as: "published-posts", settings: { published: true } %>
</div>
...
```
  
And can be accessed via the `settings` object in your component view:

```erb
<div class="posts">
  <% if settings.published? %>
    ...
  <% else %>
    ...
  <% end %>
</div>
```
  
Or your component controller:

```ruby
class PostsComponent
  ...

  def posts
    Post.where(published: settings.published)
  end
end
```
  
Default values can be provided for settings using `Rafters::Component.defaults` and `Rafters::Component.default`:
    
```ruby
defaults type: "comment", filter: "none"
default :published, false
```

## Creating a source option for a component

There are often times when a single, general component can be powered by multiple complex data sources. In order to do this Rafters includes to option to create "source" classes that belong to individual components. Each source should expose an interface that can be consumed by the component's template, and options that are set on the component level are accessible at the source level as well.

To create a source, run the following generator:

```ruby
$ rails g rafters:source {component_name} {source_name}
```

This generator will create a file named `{component_name}_{source_name}_source.rb` in the specified component's sources directory.

A source class is a simple Ruby class that includes the `Rafters::Source` module. You can do pretty much anything you want with source classes (including subclassing), as long as they all expose the same public interface methods. When a component is configured to use a specific source, the `#source` method in that component will return an instance of the specified source class.

Here's a basic example - a list-view component with one source:

The component itself:

```ruby
class ListViewComponent
  include Rafters::Component
  
  attribute :items
  
  private
  
  def items
    source.items
  end
end
```

A source for the component:

```ruby
class ListViewCommentSource
  include Rafters::Source
  
  def items
    @items ||= Comment.all
  end
end
```

The component's view template:

```erb
<ul>
  <% items.each do |item| %>
    <li><%= item.body %></li>
  <% end %>
</ul>
```

To render the above component with the `ListViewCommentSource`:

```erb
<div class="main">
  <%= render_component :list_view, as: "comments-list", source: "ListViewCommentSource"
</div>
```

If you want to add another source option for this component, simply create a new source class with the same interface:

```ruby
class ListViewPostSource
  include Rafters::Source
  
  def items
    @items ||= Post.where({
      category_id: settings.category_id
    }).all
  end
end
```

And render the component with the new source (and any settings that it may require):

```erb
<div class="main">
  <%= render_component :list_view, as: "posts-list", source: "ListViewPostSource", {
    category_id: @category.id
  } %>
</div>
```

The `Rafters::Component#controller` and `Rafters::Component#settings` methods are both available within your source classes, and will return the same information that they would in the related component.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
