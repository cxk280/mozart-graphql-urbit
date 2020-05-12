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
      do    ~(. +> bowl) 
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
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=(%http-response +<.sign-arvo)
        :_  this
        (http-response:do client-response.sign-arvo)
      (on-arvo:def wire sign-arvo)
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
      ~&  "query raw argument below"
      ~&  query
      =/  query-tape  (trip query)
      =+  to-json=(de-json:html (crip (replace-all (replace-all query-tape "\\n" "") "  " " ")))
      :: ~&  "to-json below"
      :: ~&  to-json
      =+  om-so-need-to-json=((om so) (need to-json))
      =+  my-body-tape=(trip (~(got by om-so-need-to-json) 'query'))
      =+  my-body-tape=(remove-duplicate-spaces my-body-tape)
      ~&  "my-body-tape below after remove-duplicate-spaces"
      ~&  my-body-tape
      =+  fand-spaces=(fand ~[' '] my-body-tape)
      :: ~&  "fand-spaces below"
      :: ~&  fand-spaces
      =+  fand-items-1=[(snag 0 fand-spaces) (snag 1 fand-spaces)]
      :: ~&  "fand-items-1 below"
      :: ~&  fand-items-1
      =+  substring-range-1=(sub (sub (tail fand-items-1) (head fand-items-1)) 1)
      :: ~&  "substring-range-1 below"
      :: ~&  substring-range-1
      =+  swag-cell-1=[(add (head fand-items-1) 1) substring-range-1]
      :: ~&  "swag-cell-1 below"
      :: ~&  swag-cell-1
      =/  query-or-mutation=tape  (swag swag-cell-1 my-body-tape)
      :: ~&  "query-or-mutation below"
      :: ~&  query-or-mutation
      =+  fand-items-2=[(snag 2 fand-spaces) (snag 3 fand-spaces)]
      :: ~&  "fand-items-2 below"
      :: ~&  fand-items-2
      =+  substring-range-2=(sub (sub (tail fand-items-2) (head fand-items-2)) 1)
      :: ~&  "substring-range-2 below"
      :: ~&  substring-range-2
      =+  swag-cell-2=[(add (head fand-items-2) 1) substring-range-2]
      :: ~&  "swag-cell-2 below"
      :: ~&  swag-cell-2
      =/  query-or-mutation-name=tape  (swag swag-cell-2 my-body-tape)
      :: ~&  "query-or-mutation-name below"
      :: ~&  query-or-mutation-name
      ?:  =(query-or-mutation "mutation")
        (process-mutation my-body-tape)
      ::  Later add error handling for misspelled request that do not start with "query" or "mutation"
      =+  first-flop=(flop (fand ~['{'] my-body-tape))
      :: ~&  "first-flop below"
      :: ~&  first-flop
      =/  replace-all-final-input=tape  (tail (slag (head first-flop) my-body-tape))
      :: ~&  "replace-all-final-input below"
      :: ~&  replace-all-final-input
      :: ~&  "env-vars %one below"
      :: ~&  (~(get by env-vars) %one)
      :: ~&  "(hit-rest-api 'http://167.172.210.199/') below"
      :: ~&  (hit-rest-api 'http://167.172.210.199/')
      :: ~&  "(hit-rest-api 'http://google.com/') below"
      :: ~&  (hit-rest-api 'http://google.com/')
      =/  replace
        %^  replace-all
          %^  replace-all  replace-all-final-input  " "  ""
        "}"  ""
      ~&  "replace below"
      ~&  replace
      ?:  =(query-or-mutation "query")
        (process-query [query-or-mutation-name replace])
      'Request is not valid'
    ++  process-query
      |=  [query-name=tape replace=tape]
      ^-  @t
      =,  gql-schema-query=gql-schema-query:graphql-schema
      =,  gql-schema-book=gql-schema-book:graphql-schema
      =+  query-resolver-output=(gql-schema-query ~[query-name replace])
      :: Below, there should be a conditional for each valid query. This should later be abstracted to a separate file
      ?:  =((head (tail query-resolver-output)) "getBooks")
        =+  book-resolver-output=(gql-schema-book query-resolver-output)
        (crip ~(ram re >book-resolver-output<))
      'Query is not valid'
    ++  process-mutation
      |=  body=tape
      ^-  @t
      ~&  "body in process-mutation below"
      ~&  body
      ::  Get the indices of the occurrence of the '{' character
      =+  mutation-fand=(fand ~['{'] body)
      ~&  "mutation-fand below"
      ~&  mutation-fand
      ::  See if the substring between the first two indices of the '{' character contains the character '('
      =+  parens-test-substring=(swag [(snag 0 mutation-fand) (snag 1 mutation-fand)] body)
      =+  contains-opening-parens=(contains [~['('] parens-test-substring])
      ~&  "contains-opening-parens below"
      ~&  contains-opening-parens
      =+  contains-closing-parens=(contains [~[')'] parens-test-substring])
      ~&  "contains-closing-parens below"
      ~&  contains-closing-parens
      ?:  &(contains-opening-parens contains-closing-parens) 
        (process-mutation-argument body)
      'Mutation does not contain argument'
    ++  process-mutation-argument
      |=  body=tape
      ^-  @t
      ~&  "body in process-mutation-argument below"
      ~&  body
      'Mutation contains argument'
    ++  contains
      |=  [to-check=tape body=tape]
      ?:  (gth (lent (fand to-check body)) 0)
        %.y
      %.n
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
    ++  remove-duplicate-spaces
      |=  input=tape
      ^-  tape
      =+  output=input
      |-
      ?:  =((lent (fand "  " output)) 0)
        output
      $(output (replace-all output "  " " "))
    ++  hit-rest-api
      |=  url=@t
      :: ^-  request:http
      :: =/  hed  [['Accept' 'application/json']]~
      :: =/  req/request:http  [%'GET' url hed *(unit octs)]
      :: =/  out  *outbound-config:iris
      :: =/  req  [%'GET' 'https://google.com' ['Accept' 'application/json']~ ~]
      :: [%pass /my-request-wire/[(scot %da now.bowl)] %arvo %i %request req *outbound-config:iris]
      ^-  (list card)
      =/  hed  ['Accept' 'application/json']~
      =/  out  *outbound-config:iris
      =/  req=request:http  [%'GET' url hed ~]
      [%pass /my-request-wire/[(scot %da now.bowl)] %arvo %i %request req out]~
    ++  http-response
      |=  res=client-response:iris
      ^-  (list card)
      ::  ignore all but %finished
      ?.  ?=(%finished -.res)
        ~
      =/  data=(unit mime-data:iris)  full-file.res
      ?~  data
        ~
      ~&  "data in http-response"
      ~&  data
      [%pass / %arvo %d %flog %text (trip q.data.u.data)]~
  --
  