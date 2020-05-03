/+  graphql-type-defs

:: Resolvers
|%  
  ++  gql-schema-query
    |=  a=(list tape)
    ^-  request-container:graphql-type-defs
    ?~  a
      !!
    (type-query:graphql-type-defs a)
  ++  gql-schema-book
    |=  [a=request-container:graphql-type-defs payload=simple-payload:http]
    :: TODO: add reducer so that the response returned to user is prettier and more useful
    (type-book:graphql-type-defs a payload)
  ++  gql-schema-mutation
    |=  a=(list tape)
    ^-  request-container:graphql-type-defs
    (type-mutation:graphql-type-defs a)
--