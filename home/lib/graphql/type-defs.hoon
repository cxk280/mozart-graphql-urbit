/=  getbooks-query-data
/:  /===/lib/graphql/getbooks-query-data  /json/
=,  dejs:format

::
:: A traditional description of the types for easy human reference
::
:: type Query {
::  getBooks: Book
:: }
::
:: type Book {
::  title: String
::  author: String
:: }
::

|%
  +$  item-body  [item-key=tape item-value=tape]
  +$  item-container  [tipe=tape item-bodies=(list item-body)]
  +$  query-body  [query-name=tape item-containers=(list item-container)]
  +$  query-container  [tipe=tape query=(list tape)]
  ++  type-query
    |=  a/(list tape)
    ^-  query-container
    ?~  a
      !!
    ["Query" a]
  ++  type-book
    |=  a/query-container
    ^-  query-body
    ?~  a
      !!
    =+  query=(tail a)
    ?~  query
      !!
    =+  query-name=(head query)
    =+  ommed-query-data=((om so) getbooks-query-data)
    =+  name-and-title=[(trip (~(got by ommed-query-data) 'author')) (trip (~(got by ommed-query-data) 'title'))]
    =+  output=*(list item-container)
    =+  iterator=0
    =+  iterator-target=(sub (div (lent ommed-query-data) 2) 1)
    |-
      ?:  (gte iterator iterator-target)
        [query-name output]
      ?:  =(["author" ~] t.query)
        $(output (snoc output ["Book" [["author" (head name-and-title)] ~]]), iterator (add iterator 1))
      ?:  =(["title" ~] t.query)
        $(output (snoc output ["Book" [["title" (tail name-and-title)] ~]]), iterator (add iterator 1))
      ?:  =(["author" "title" ~] t.query)
        $(output (snoc output ["Book" [["author" (head name-and-title)] ["title" (tail name-and-title)] ~]]), iterator (add iterator 1))
    !!
--