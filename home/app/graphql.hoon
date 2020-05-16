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
        :_  this
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
      =+  db-ip=(~(get by env-vars) %db-ip)
      ~&  "db-ip in poke-handle-http-request below"
      ~&  db-ip
      =+  request-body=q.u.body.request.req
      ~&  "request-body in poke-handle-http-request below"
      ~&  request-body
      :_  state(query (~(put by query) eyre-id request-body))
      (hit-rest-api [db-ip eyre-id])
    ++  parse-graphql-request
      |=  [query=@t eyre-id=@ta]
      ^-  [response-tape=@t cards=(list card)]
      =,  dejs:format

      ::  Take the query, which is a cord, and turn it into a tape
      =/  query-tape  (trip query)

      ::  Replace instances of certain tapes in query-tap, turn it back into a cord and parse it as JSON
      =+  to-json=(de-json:html (crip (replace-all (replace-all query-tape "\\n" "") "  " " ")))

      ::  Turn to-json to a unit with need
      ::  Then parse (with om) the object inside as a map
      ::  And (with so) the string inside that as a cord
      ::  The final output of om-so-need-to-json is a map
      ::  See ++om:dejs:format and ++so:dejs:format in zuse.hoon
      =+  om-so-need-to-json=((om so) (need to-json))

      ::  Access the value at the 'query' key in the om-so-need-to-json map using +-got:by
      ::  See https://urbit.org/docs/reference/library/2i/#got-by
      =+  my-body-tape=(trip (~(got by om-so-need-to-json) 'query'))

      ::  Remove duplicate spaces from my-body-tape
      =+  my-body-tape=(remove-duplicate-spaces my-body-tape)

      ::  Create a list of indices of every occurence of the ' ' in my-body-tape
      =+  fand-spaces=(fand ~[' '] my-body-tape)

      ::  Create a cell with the first two elements of the fand-spaces list
      ::  This corresponds to the first two occurences of the ' ' in my-body-tape
      =+  fand-items-1=[(snag 0 fand-spaces) (snag 1 fand-spaces)]

      ::  Get the number of characters between the first two spaces in the tape
      ::  These will be used to get the first word, i.e. "query" or "mutation"
      =+  substring-range-1=(sub (sub (tail fand-items-1) (head fand-items-1)) 1)

      ::  Create a cell that will passed as a sample to swag, which makes a substring from a longer string
      ::  The head of that cell is the inclusive index at which to start
      ::  The tail of that cell is the number of following characters to include in the substring
      ::  We add 1 to the head so it begins on the character after the first space in the tape
      =+  swag-cell-1=[(add (head fand-items-1) 1) substring-range-1]

      ::  Use swag to determine if the first word in the tape is "query" or "mutation"
      ::  TODO: Add error handling for misspelled request that do not start with "query" or "mutation"
      =/  query-or-mutation=tape  (swag swag-cell-1 my-body-tape)

      ::  Create a cell with the indices of the third and four spaces in the tape
      =+  fand-items-2=[(snag 2 fand-spaces) (snag 3 fand-spaces)]

      ::  Get the number of characters between the third and fourth spaces in the tape
      ::  These will be used to get the second word, i.e. "getBooks"
      =+  substring-range-2=(sub (sub (tail fand-items-2) (head fand-items-2)) 1)

      ::  Create a cell that will passed as a sample to swag
      ::  We add 1 to the head so it begins on the character after the third space in the tape
      =+  swag-cell-2=[(add (head fand-items-2) 1) substring-range-2]

      ::  Make a tape of the second word in the tape, i.e. "getBooks"
      =/  query-or-mutation-name=tape  (swag swag-cell-2 my-body-tape)

      ::  Make a list of all indices of the character { in the tape and reverse it
      =+  first-flop=(flop (fand ~['{'] my-body-tape))

      ::  Make a tape of everything after the last occurrence of {
      =+  slagged=(slag (head first-flop) my-body-tape)

      :: =+  db-ip=(~(get by env-vars) %db-ip)
      :: ~&  "db-ip below"
      :: ~&  db-ip

      :: =/  rest-api-request  (hit-rest-api [db-ip eyre-id])
      :: ~&  "rest-api-request below"
      :: ~&  rest-api-request
      ::  Get rid of remaining characters we don't want
      =/  replace
        %^  replace-all
          %^  replace-all
            %^  replace-all  slagged  " "  ""
          "}"  ""
        "\{"  ""
      ~&  "replace below"
      ~&  replace

      ::  If it's a mutation, go to the process-mutation arm
      ?:  =(query-or-mutation "mutation")
        [(process-mutation [my-body-tape replace]) rest-api-request]

      ::  If it's a query, go to the process-query arm
      ?:  =(query-or-mutation "query")
        [(process-query [query-or-mutation-name replace]) rest-api-request]
      
      ::  Else return an error (just a cord rather than formal error for now)
      ['Request is not valid' rest-api-request]
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
      ~&  "query in http-response below"
      ~&  query
      :: Store a map in state mapping between eyre-id and query tape
      :: After my data gets back, pass it and my query tape into parse-graphql-request
      (give-simple-payload:app eyre-id payload)
  --
  