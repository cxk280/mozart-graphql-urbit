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
      ~&  "my-body-tape below after remove-duplicate-spaces"
      ~&  my-body-tape

      ::  Create a list of indices of every occurence of the ' ' in my-body-tape
      =+  fand-spaces=(fand ~[' '] my-body-tape)
      ~&  "fand-spaces below"
      ~&  fand-spaces

      ::  Create a cell with the first two elements of the fand-spaces list
      ::  This corresponds to the first two occurences of the ' ' in my-body-tape
      =+  fand-items-1=[(snag 0 fand-spaces) (snag 1 fand-spaces)]
      ~&  "fand-items-1 below"
      ~&  fand-items-1

      ::  Get the number of characters between the first two spaces in the tape
      ::  These will be used to get the first word, i.e. "query" or "mutation"
      =+  substring-range-1=(sub (sub (tail fand-items-1) (head fand-items-1)) 1)
      ~&  "substring-range-1 below"
      ~&  substring-range-1

      ::  Create a cell that will passed as a sample to swag, which makes a substring from a longer string
      ::  The head of that cell is the inclusive index at which to start
      ::  The tail of that cell is the number of following characters to include in the substring
      ::  We add 1 to the head so it begins on the character after the first space in the tape
      =+  swag-cell-1=[(add (head fand-items-1) 1) substring-range-1]
      ~&  "swag-cell-1 below"
      ~&  swag-cell-1

      ::  Use swag to determine if the first word in the tape is "query" or "mutation"
      ::  TODO: Add error handling for misspelled request that do not start with "query" or "mutation"
      =/  query-or-mutation=tape  (swag swag-cell-1 my-body-tape)
      ~&  "query-or-mutation below"
      ~&  query-or-mutation

      ::  Create a cell with the indices of the third and four spaces in the tape
      =+  fand-items-2=[(snag 2 fand-spaces) (snag 3 fand-spaces)]
      ~&  "fand-items-2 below"
      ~&  fand-items-2

      ::  Get the number of characters between the third and fourth spaces in the tape
      ::  These will be used to get the second word, i.e. "getBooks"
      =+  substring-range-2=(sub (sub (tail fand-items-2) (head fand-items-2)) 1)
      ~&  "substring-range-2 below"
      ~&  substring-range-2

      ::  Create a cell that will passed as a sample to swag
      ::  We add 1 to the head so it begins on the character after the third space in the tape
      =+  swag-cell-2=[(add (head fand-items-2) 1) substring-range-2]
      ~&  "swag-cell-2 below"
      ~&  swag-cell-2

      ::  Make a tape of the second word in the tape, i.e. "getBooks"
      =/  query-or-mutation-name=tape  (swag swag-cell-2 my-body-tape)
      ~&  "query-or-mutation-name below"
      ~&  query-or-mutation-name

      ::  Make a list of all indices of the character { in the tape and reverse it
      =+  first-flop=(flop (fand ~['{'] my-body-tape))
      ~&  "first-flop below"
      ~&  first-flop

      ::  Make a tape of everything after the last occurrence of {
      =+  slagged=(slag (head first-flop) my-body-tape)
      ~&  "slagged below"
      ~&  slagged

      :: ~&  "env-vars %one below"
      :: ~&  (~(get by env-vars) %one)
      :: ~&  "(hit-rest-api 'http://167.172.210.199/') below"
      :: ~&  (hit-rest-api 'http://167.172.210.199/')

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
        (process-mutation [my-body-tape replace])

      ::  If it's a query, go to the process-query arm
      ?:  =(query-or-mutation "query")
        (process-query [query-or-mutation-name replace])
      
      ::  Else return an error (just a cord rather than formal error for now)
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
      |=  [body=tape replace=tape]
      ^-  @t
      ~&  "body in process-mutation below"
      ~&  body
      ~&  "replace in process-mutation below"
      ~&  replace
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
      ~&  "[mutation-fand body] below"
      ~&  [mutation-fand body]
      ?:  &(contains-opening-parens contains-closing-parens) 
        (process-mutation-argument [mutation-fand body replace])
        :: (process-mutation-argument body)
      'Error: mutation does not contain argument'
    ++  process-mutation-argument
      :: |=  body=tape
      |=  [mutation-fand=(list @) body=tape replace=tape]
      ^-  @t
      ~&  "mutation-fand in process-mutation-argument below"
      ~&  mutation-fand
      ~&  "body in process-mutation-argument below"
      ~&  body
      ~&  "replace in process-mutation-argument below"
      ~&  replace
      =+  opening-parens-index=(snag 0 (fand ~['('] body))
      ~&  "opening-parens-index in process-mutation-argument below"
      ~&  opening-parens-index
      =+  closing-parens-index=(snag 0 (fand ~[')'] body))
      ~&  "closing-parens-index in process-mutation-argument below"
      ~&  closing-parens-index
      =+  length-of-argument-body=(sub closing-parens-index opening-parens-index)
      ?:  (lte length-of-argument-body 1)
        'Error: mutation argument is empty'
      ~&  "length-of-argument-body in process-mutation-argument below"
      ~&  length-of-argument-body
      =+  argument-body=(swag [(add opening-parens-index 1) (sub length-of-argument-body 1)] body)
      ~&  "(crip argument-body) in process-mutation-argument below"
      ~&  (crip argument-body)
      (process-mutation-body [body argument-body mutation-fand replace])
      :: (crip (zing ~["Mutation contains the following argument: " argument-body]))
    ++  process-mutation-body
      |=  [body=tape argument-body=tape mutation-fand=(list @) replace=tape]
      ^-  @t
      ~&  "body in process-mutation-body below"
      ~&  body
      ~&  "argument-body in process-mutation-body below"
      ~&  argument-body
      ~&  "mutation-fand in process-mutation-body below"
      ~&  mutation-fand
      ~&  "replace in process-mutation-body below"
      ~&  replace
      =+  start-cutting-name-here=(add (snag 1 (fand ~[' '] body)) 1)
      =+  end-cutting-name-here=(sub (sub (snag 0 (fand ~['('] body)) (snag 1 (fand ~[' '] body))) 1)
      =+  mutation-name-fand=(swag [start-cutting-name-here end-cutting-name-here] body)
      =+  mutation-name-fand-test=(snag 0 (fand ~['('] body))
      ~&  "(crip mutation-name-fand) in process-mutation-body below"
      ~&  (crip mutation-name-fand)
      :: ~&  "(crip mutation-name-fand-test) in process-mutation-body below"
      :: ~&  (crip mutation-name-fand-test)
      ~&  "mutation-name-fand-test in process-mutation-body below"
      ~&  mutation-name-fand-test
      =+  main-body-of-mutation=(swag [(snag 1 mutation-fand) (snag 2 mutation-fand)] body)
      ~&  "(crip main-body-of-mutation) in process-mutation-body below"
      ~&  (crip main-body-of-mutation)
      (crip main-body-of-mutation)
      :: (crip body)
      :: (crip argument-body)

      :: Need to pass in something like the following to gql-schema-mutation below: [i="getBooks" t=<<"author">>]
      :: =,  gql-schema-mutation=gql-schema-mutation:graphql-schema
      :: =+  mutation-resolver-output=(gql-schema-mutation ~[query-name replace])

    ++  parse-mutation-argument
      |=  argument=tape
      ^-  @t
      (crip argument)
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
  