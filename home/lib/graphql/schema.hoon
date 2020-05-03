/+  graphql-type-defs

:: Resolvers
|%  
  ++  gql-schema-query
    |=  a/(list tape)
    ^-  query-container:graphql-type-defs
    ?~  a
      !!
    (type-query:graphql-type-defs a)
  ++  gql-schema-book
    |=  a/query-container:graphql-type-defs
    (type-book:graphql-type-defs a)
--