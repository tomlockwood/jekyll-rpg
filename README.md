# Jekyll RPG

## Description

A jekyll plugin to help DMs manage campaign information.

Reads markdown links (for example `[Bethany](/gods/bethany)`) to build a map of relationships between things that are in collections.

Writes a table of where a thing is referenced to every thing's page, if desired.  Allows for quick navigation.

Generates a list of pages that a link has been made to, but which don't yet exist.  Useful for remembering what needs to be fleshed out.

Allows certain pages marked as only for the DM to not be published, so you can expose a public site to your players!

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

Each of these options is overridden by the more specific option, so you can choose to show or not show the table on any combination of these levels.

This refs table is generated and appended to the `content` of each `doc` before it is rendered by jekyll.

### DM Mode

At a site config level, you can set `dm_mode` if this is `true`, only then will documents that have `dm: true` be published, and have the pages they refer to shown in the references table of that page.  Additionally, `dm_mode` can be used to hide text that players are not meant to see by wrapping it like this:

```
{% if site.dm_mode %}
Players cannot see this content
{% endif %}
```

In future I intend that to highlight and be a bit less clunky.

## New data

### On the documents:

`referenced_by` provides a hash of collections with links to pages that refer to the document

### On the site:

`graph` is a nested series of hashes that represents the relationship between documents

`broken_links` is an array of hashes representing a markdown link pointing to a non-existent page

## Known issues/bug roadmap

* If the first thing on a document is a markdown link, it will not be detected for the `graph` or references.
* `dm: true` does not prevent selection in collections of a document.
* Code style/quality is not great. Tests needed.

## Feature roadmap

* Represent relationship between geographical locations in a hierarchical way for easy navigation.
* Make a DM block filter and clearly highlight DM only content in boxes or similar.
* Make references table more customizeable.

## Development

### Testing

To run tests, run `rspec test`.
