/+  *server, default-agent, verb, dbug, graphql-schema, graphql-type-defs, env-vars
/=  getbooks-query-data
/:  /===/lib/graphql/getbooks-query-data  /json/

|%
  +$  card  card:agent:gall
  +$  state-type
    $:  query=(map @ta @t)
    ==
--
=|  state-type
=*  state  -
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
    ++  on-save   !>(state)
    ++  on-load
      |=  =vase
      ^-  (quip card _this)
      :_  this(state !<(state-type vase))
      [[%pass / %arvo %e %connect [~ /'~graphqltest'] dap.bowl] ~]
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?+  mark  (on-poke:def mark vase)
          %handle-http-request
        =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
        :: :_  this
        =^  cards  state
          (poke-handle-http-request:graphql inbound-request eyre-id)
        [cards this]
      ==
    ::
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
    ::  on-arvo is called when I get a response from a system request I've made
    ::  on-arvo will be called when the response from my outgoing GET request comes back
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=([%rest-request @ ~] wire)
        =*  eyre-id  i.t.wire
        ?>  ?=(%http-response +<.sign-arvo)
        :_  this
        (http-response:do eyre-id client-response.sign-arvo)
      (on-arvo:def wire sign-arvo)
    ++  on-fail   on-fail:def
  --
  |_  =bowl:gall
    ++  poke-handle-http-request  
      |=  [req=inbound-request:eyre eyre-id=@ta]
      ^-  (quip card _state)
      ?~  body.request.req
        ~&  %invalid-post-no-body
          !!
      :: =+  db-ip=(~(get by env-vars) %db-ip)
      =+  db-ip='http://167.172.210.199/'
      ~&  "db-ip in poke-handle-http-request below"
      ~&  db-ip
      =+  request-body=q.u.body.request.req
      ~&  "request-body in poke-handle-http-request below"
      ~&  request-body
      :_  state(query (~(put by query) eyre-id request-body))
      (hit-rest-api [db-ip eyre-id])
    ++  parse-graphql-request
      |=  [eyre-id=@ta payload=simple-payload:http]
      :: ^-  [response-tape=@t cards=(list card)]
      ~&  "state in parse-graphql-request below"
      ~&  state
      ~&  "state(query (~(put by query) eyre-id request-body)) in parse-graphql-request below"
      ~&  state(query (~(got by query) eyre-id))
      

      
      (give-simple-payload:app eyre-id payload)
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
      |=  [body=tape replace=tape]
      ^-  @t
      ::  Get the indices of the occurrence of the '{' character
      =+  mutation-fand=(fand ~['{'] body)

      ::  See if the substring between the first two indices of the '{' character contains the character '('
      =+  parens-test-substring=(swag [(snag 0 mutation-fand) (snag 1 mutation-fand)] body)
      =+  contains-opening-parens=(contains [~['('] parens-test-substring])
      =+  contains-closing-parens=(contains [~[')'] parens-test-substring])
      ?:  &(contains-opening-parens contains-closing-parens) 
        (process-mutation-argument [mutation-fand body replace])
      'Error: mutation does not contain argument'
    ++  process-mutation-argument
      |=  [mutation-fand=(list @) body=tape replace=tape]
      ^-  @t
      =+  opening-parens-index=(snag 0 (fand ~['('] body))
      =+  closing-parens-index=(snag 0 (fand ~[')'] body))
      =+  length-of-argument-body=(sub closing-parens-index opening-parens-index)
      ?:  (lte length-of-argument-body 1)
        'Error: mutation argument is empty'
      =+  argument-body=(swag [(add opening-parens-index 1) (sub length-of-argument-body 1)] body)
      (process-mutation-body [body argument-body mutation-fand replace])
    ++  process-mutation-body
      |=  [body=tape argument-body=tape mutation-fand=(list @) replace=tape]
      ^-  @t
      =+  start-cutting-name-here=(add (snag 1 (fand ~[' '] body)) 1)
      =+  end-cutting-name-here=(sub (sub (snag 0 (fand ~['('] body)) (snag 1 (fand ~[' '] body))) 1)
      =+  mutation-name-fand=(swag [start-cutting-name-here end-cutting-name-here] body)
      =+  mutation-name-fand-test=(snag 0 (fand ~['('] body))
      =+  main-body-of-mutation=(swag [(snag 1 mutation-fand) (snag 2 mutation-fand)] body)
      (crip main-body-of-mutation)

    ++  parse-mutation-argument
      |=  argument=tape
      ^-  @t
      (crip argument)
    ++  contains
      |=  [to-check=tape body=tape]
      ?:  (gth (lent (fand to-check body)) 0)
        %.y
      %.n
    ++  item
      %+  knee  *(list cord)  |.  ~+
      %+  ifix  [lob rob]
      %+  ifix  [. .]:(star gah)
      ;~  plug
        name
      ::
        ;~  pose
          ;~(pfix (star gah) item)
          (easy ~)
        ==
      ==
    ++  name  (cook crip (star aln))
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
    ++  test-arm
      |=  [eyre-id=@ta payload=simple-payload:http]
      ~&  "running test-arm"
      ~&  "payload in test-arm"
      ~&  payload
      (give-simple-payload:app eyre-id payload)
    ++  hit-rest-api
      |=  [url=@t eyre-id=@ta]
      ^-  (list card)
      =/  hed  ['Accept' 'application/json']~
      =/  out  *outbound-config:iris
      =/  req=request:http  [%'GET' url hed ~]
      [%pass /rest-request/[eyre-id] %arvo %i %request req out]~
    ++  http-response
      |=  [eyre-id=@ta res=client-response:iris]
      ^-  (list card)
      ?.  ?=(%finished -.res)
        ~
      =/  data=(unit mime-data:iris)  full-file.res
      ?~  data
        ~
      ~&  "data in http-response"
      ~&  data
      =/  payload=simple-payload:http  [[200 ~] [~ data.u.data]]
      :: Store a map in state mapping between eyre-id and query tape
      :: After my data gets back, pass it and my query tape into parse-graphql-request
      (parse-graphql-request [eyre-id payload])
      :: (test-arm [eyre-id payload])
      :: (give-simple-payload:app eyre-id payload)
  --
  