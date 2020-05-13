/+  graphql-type-defs

:: Resolvers
|%  
  ++  gql-schema-query
    |=  a/(list tape)
    ^-  request-container:graphql-type-defs
    ~&  "a in gql-schema-query below"
    ~&  a
    ?~  a
      !!
    (type-query:graphql-type-defs a)
  ++  gql-schema-book
    |=  a/request-container:graphql-type-defs
    (type-book:graphql-type-defs a)
  ++  gql-schema-mutation
    |=  a/(list tape)
    ^-  request-container:graphql-type-defs
    (type-mutation:graphql-type-defs a)
--