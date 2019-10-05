# Jekyll RPG

## Description

Jekyll RPG allows storytellers to create wiki-ish static sites to manage homebrew campaign information.  The site is designed to allow DMs to manage their confidential notes alongside a comprehensive guide to the world for the players.

Through the use of markdown links between pages (for example `[Bethany](/gods/bethany)`) Jekyll RPG builds a map of references between documents, allowing DMs and players to see where a document is referenced.  If a player discovers a magic item, and they navigate to the magic item's page, they may see that the item is linked to a document about the session during which it was found, and also the biography of its previous owner.

When a DM is creating their world, they might make a markdown link to a document that doesn't exist yet.  When creating a tavern they might link to the as-yet unwritten innkeeper's character page.  Jekyll RPG gives the DM a list of pages they have referenced and unwritten, reminding them of areas of the world they may need to add more detail to.  Additionally, links to unwritten pages are rendered with a ~~strikethrough~~ which makes them easy to identify.

Since documents can be marked as DM-eyes-only, it is possible to expose a public site to players.  In this case, DM-only pages will not be shown in the list of links a page has, and they will not be included in the built site.  This makes publishing a safe site for player navigation and consumption easy.

## Configuration

### References

Jekyll RPG comes with two main configuration options - for article references and DM mode.

If you'd like to know what other collection documents reference another - in the document yaml you can set `refs: true`.

This will create a table like this at the bottom of the document:

### Referenced By:
|**Collection** | **Links**                  |
|---------------|----------------------------|
|**Gods**       | - [Bethany](/#)            |
|**History**    | - [Slaying of Bethany](/#) |

Additionally, you can set the `refs` option at a collection level like so:

```
collections:
  gods:
    output: true
    refs: true
```

Or at a site level with `refs: true` in your configuration file.

Each of these options is overridden by the more specific option, so you can choose to show or not show the table on any combination of these levels.  For example, you can choose to render the refs table at the site level, but then not for a particular collection, or for a particular collection but not for one page in that collection.

This refs table is generated and appended to the `content` of each `doc` before it is rendered by jekyll.

### DM Mode

At a site config level, you can set `dm_mode` if this is `true`, only then will documents that have `dm: true` be published, and have the pages they refer to shown in the references table of that page.  Links made to those pages will be rendered with a ~~strikethrough~~ as if they do not exist when `dm_mode` is `false`. Additionally a `dm` block tag can be used to hide text that players are not meant to see by wrapping it like this:

```
{% dm %}
Players cannot see this content
{% enddm %}
```

This text is rendered is the site is in `dm_mode` like so:

> # DM Note:
>> Players cannot see this content

## New data

### On the documents:

`referenced_by` provides a hash of collections with an array of links in that collection that are pages that refer to the document.

### On the site:

`graph` is a nested series of hashes that represents the relationship between documents across the entire site.

`broken_links` is an array of hashes representing a markdown link pointing to a non-existent document.

## Known issues/bug roadmap

* If the first thing on a document is a markdown link, it will not be detected for the `graph` or references.
* `dm: true` does not prevent selection in collections of a document.

## Feature roadmap

* Represent relationship between geographical locations in a hierarchical way for easy navigation.
* Make references table more customizeable and potentially even a template-able thing.
* Set pages as `stub`, generate a list of `stub` pages on the site and have a site-configurable option for what the `stub_default` is

## Development

### Testing

To run tests, run `rspec test`.
