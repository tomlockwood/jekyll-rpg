# Jekyll RPG

## Description

A jekyll plugin to help DMs manage campaign information.

Reads markdown links to build a map of relationships between things that are in collections.

Writes a table of where a thing is referenced to every thing's page, if desired.

Generates a list of pages that a link has been made to, but which don't yet exist.

Allows certain pages marked as only for the DM to not be published, so you can expose a public site to your players!

## Configuration

Jekyll RPG comes with two main configuration options - for article references and DM mode.

If you'd like to know what other pages reference a page - in the page yaml you can set `refs: true`.

This will create a table like this:

## Referenced By:

|**Collection** | **Links**                  |
|---------------|----------------------------|
|**Gods**       | - [Bethany](/#)            |
|**History**    | - [Slaying of Bethany](/#) |
