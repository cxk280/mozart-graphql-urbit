/+  *server, default-agent, verb, dbug, graphql-schema, graphql-type-defs, env-vars
/=  getbooks-query-data
/:  /===/lib/graphql/getbooks-query-data  /json/

|%
  +$  card  card:agent:gall
--
^-  agent:gall
=<
  |_  =bowl:gall
    +*  this  .
      graphql-core    +>
      graphql    ~(. graphql-core bowl)
      def   ~(. (default-agent this %|) bowl) 
    ::  Use on-init for initial registration (REQUIRED FOR HTTP)
    ++  on-init
      ^-  (quip card _this)
      :_  this
      [[%pass / %arvo %e %connect [~ /'~graphqltest'] dap.bowl] ~]
    ++  on-save   on-save:def
    ++  on-load
      |=  =vase
      ^-  (quip card _this)
      :_  this
      [[%pass / %arvo %e %connect [~ /'~graphqltest'] dap.bowl] ~]
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      :: ?.  ?=(%noun mark)  [~ this]
      ::: ~&  [%poked-with-a-noun !<(* vase)]
      :: [~ this]
      ?+  mark  (on-poke:def mark vase)
          %handle-http-request
        =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
        :_  this
        %+  give-simple-payload:app  eyre-id

        :: With authorization
        :: %+  require-authorization:app  inbound-request
        :: poke-handle-http-request:graphql

        :: Without authorization
        (poke-handle-http-request:graphql inbound-request)
      ==

    ::  +simple-payload: a simple, one event response used for generators
    ::
    :: +$  simple-payload
      :: $:  ::  response-header: status code, etc
          ::
          :: =response-header
          ::  data: the data returned as the body
          ::
          :: data=(unit octs)
      :: ==
    :: --

    ::  Use on-watch for handling/accepting initial subscription for each request (REQUIRED FOR HTTP)
    ++  on-watch
      |=  =path
      ^-  (quip card:agent:gall _this)
      ?:  ?=([%http-response *] path)
        `this
      (on-watch:def path)
    ++  on-leave  on-leave:def
    ++  on-peek   on-peek:def
    ++  on-agent  on-agent:def
    ++  on-arvo   on-arvo:def
    ++  on-fail   on-fail:def
  --
  |_  =bowl:gall
    ++  poke-handle-http-request   
      |=  req=inbound-request:eyre
      ^-  simple-payload:http
      ?~  body.request.req
        ~&  %invalid-post-no-body
          !!
      =+  request-body=q.u.body.request.req
      =/  parsed-payload  (trip (parse-graphql-request `@t`request-body))
      [[200 ~] [~ (as-octt:mimes:html parsed-payload)]]
    ++  parse-graphql-request
      |=  query=@t
      ^-  @t
      =,  dejs:format
      =,  gql-schema-query=gql-schema-query:graphql-schema
      =,  gql-schema-book=gql-schema-book:graphql-schema
      =/  query-tape  (trip query)
      =+  to-json=(de-json:html (crip (replace-all (replace-all query-tape "\\n" "") "  " " ")))
      =+  my-query-body-tape=(trip (~(got by ((om so) (need to-json))) 'query'))
      =+  fand-items=[(snag 0 (fand ~[' '] my-query-body-tape)) (snag 1 (fand ~[' '] my-query-body-tape))]
      =+  substring-range=(sub (sub (tail fand-items) (head fand-items)) 1)
      =+  swag-cell=[(add (head fand-items) 1) substring-range]
      =/  query-section=tape  (swag swag-cell my-query-body-tape)
      =+  first-flop=(flop (fand ~['{'] my-query-body-tape))
      =/  replace-all-final-input=tape  (tail (slag (head first-flop) my-query-body-tape))
      ~&  "replace-all-final-input below"
      ~&  replace-all-final-input
      ~&  "(lent (fand ~[' '] replace-all-final-input)) below"
      ~&  (lent (fand ~[' '] replace-all-final-input))
      ~&  "env-vars %one below"
      ~&  (~(get by env-vars) %one)
      ::  TODO: Add a trap to run replace-all until there are no instances of multiple spaces
      =/  replace
        %^  replace-all
          %^  replace-all  replace-all-final-input  " "  ""
        "}"  ""
      =+  query-resolver-output=(gql-schema-query ~[query-section replace])
      ?:  =((head (tail query-resolver-output)) "getBooks")
        =+  book-resolver-output=(gql-schema-book query-resolver-output)
        (crip ~(ram re >book-resolver-output<))
      'Query is not valid'
    ++  replace-all
      |=  [input=tape find=tape replace=tape]
      ^-  tape
      %+  roll
        %+  scan  input
        %-  star
        ;~  pose
          %+  cold  (crip replace)
            (jest (crip find))
          next
        ==
      |=  {p/cord c/tape}
      ^-  tape
      (weld c (trip p))
  --
  