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
  +$  request-body  [request-name=tape item-containers=(list item-container)]
  +$  request-container  [tipe=tape query=(list tape)]
  ++  type-query
    |=  a=(list tape)
    ^-  request-container
    ?~  a
      !!
    ["Query" a]
  ++  type-book
    |=  [a=request-container payload=simple-payload:http]
    ^-  request-body
    ?~  a
      !!
    =+  query=(tail a)
    ?~  query
      !!
    =+  query-name=(head query)
    =/  data-payload-tail  (tail data.payload)
    =/  de-jsonned  (tail (de-json:html q.data-payload-tail))

    ::  You can use getbooks-query-data for testing without using the external endpoint.
    ::  Simply pass it in the line below instead of de-jsonned
    =+  ommed-query-data=((om so) de-jsonned)
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
    ++  type-mutation
      |=  a/(list tape)
      ^-  request-container
      ?~  a
        !!
      ["Mutation" a]
--