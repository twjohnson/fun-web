# Steps

1. Install *Phoenix* tasks for *Mix*

	```mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez```

2. Create new *Phoenix* application

	```mix phoenix.new secounter --no-ecto```

3. Change directory to newly created project

	```cd secounter```

4. Start *Phoenix* application and open browser at **http://localhost:4000**

	``` mix phoenix.server```
	
5. Create directory for *Elm* source code

	```mkdir web/elm```

6. Install **elm-brunch** as a development dependency

	```npm install --save-dev elm-brunch```

7. Install *Elm* package to support *WebSocket*

	```
	cd web/elm
	elm package install elm-lang/websocket
	```

8. Add watching of **web/elm** directory in **brunch-config.js** in section **watched**. 
	
	

	```
	watched: [
      "web/elm",
      "web/static",
      "test/static"
    ]
	```
	Snippet: **secbrwelm**

9. Add **elmBrunch** plugin in **brunch-config.js** in section **plugins**

	```
	elmBrunch: {
      elmFolder: "web/elm",
      mainModules: ["App.elm"],
      outputFolder: "../static/vendor"
    },
	```
	Snippet: **secbrelm**
	
10. Swap content of **web/templates/page/index.html.eex** to be able to include *Elm* application inside container

	```<div id="elm-container"></div>```
	Snippet: **secappcnt**

11. Swap content of **web/templates/layout/app.html.eex** to change look and feel of application

	Snippet: **secapphtml**

12. Activate channel support in *Phoenix* - open file **secounter/web/static/js/app.js** and uncomment ```import socket from "./socket"```

13. Restart *Phoenix* application, open developer console in browser and refresh it to see following error

	```
	Unable to join 
	Object {reason: "unmatched topic"}
	reason: "unmatched topic"__proto__: Object
	```
	This is because JS tries to connect to non existing topic inside *Phoenix*

14. Let's change channel name to the right one in **secounter/web/static/js/socket.js** file

	```
	let channel = socket.channel("counter:lobby", {})
	```

15. Let's create *Phoenix* channel handler

	```
	mix phoenix.gen.channel Counter
	```
16. Register created channel in **secounter/web/channels/user_socket.ex** file
	```
	channel "counter:*", Secounter.CounterChannel
	```
	Snippet: **secexregcn**

17. Create file **secounter/web/elm/App.elm** with next initial content

	```
	module SecounterApp exposing (..)
	
	import Html exposing (..)
	import Html.App as App
	import Html.Attributes exposing (..)
	import Html.Events exposing (..)
	import WebSocket
	import Json.Encode as Encode
	import Json.Decode exposing (..)
	import String
	

	main =
    App.beginnerProgram { model = 0, view = view, update = update }


	type MsgType
    	= Increment
	    | Decrement


	update : MsgType -> number -> number
	update msg model =
    	case msg of
        	Increment ->
            	model + 1

	        Decrement ->
    	        model - 1


	view : a -> Html MsgType
	view model =
    	div [ style [ ( "margin", "10px" ) ] ]
        	[ button [ onClick Decrement ] [ text "-" ]
	        , strong [ style [ ( "margin", "10px" ) ] ] [ text (toString model) ]
    	    , button [ onClick Increment ] [ text "+" ]
        	, div [ style [ ( "font-weight", "bold" ), ( "padding-top", "10px" ) ] ] [ text "Debug:" ]
        ]

	```
	
	Snippet: **secelmapp**
	
18. Attach application to be able to view it in file **secounter/web/static/js/app.js**

	```
	// Set up Elm App
	const elmDiv = document.querySelector("#elm-container");
	const elmApp = Elm.SecounterApp.embed(elmDiv);

	```
	Snippet: **secattcnt**

19. Let's write some code to allow increment/decrement functionalty over *Phoenix* channels starting from channel message type

	```
	type alias ChannelMsg =
        { topic : String
        , event : String
        , payload : String
        , ref : String
        }

	```
	Snippet: **secelmappcnmsg**

20. Now let's add some utility code to handle message conversion and sending to channel

	```
	sendChannelMsg : ChannelMsg -> Cmd a
    sendChannelMsg msg =
        WebSocket.send sockerUrl (encodeChannelMsg msg)


    prepareChannelMsg : String -> Int -> ChannelMsg
    prepareChannelMsg action counter =
        ChannelMsg "counter:lobby" action (toString counter) action


    encodeChannelMsg : ChannelMsg -> String
    encodeChannelMsg msg =
        Encode.object
            [ ( "topic", Encode.string msg.topic )
            , ( "event", Encode.string msg.event )
            , ( "payload", Encode.object [ ( "body", Encode.string msg.payload ) ] )
            , ( "ref", Encode.string msg.ref )
            ]
            |> Encode.encode 0


    decodeChannelMsg : Decoder ChannelMsg
    decodeChannelMsg =
        object4 ChannelMsg
            ("topic" := string)
            ("event" := string)
            ("payload" := oneOf [ at [ "body" ] string, succeed "" ])
            (oneOf [ "ref" := string, succeed "" ])


    sockerUrl : String
    sockerUrl =
        "ws://localhost:4000/socket/websocket"
	```
	Snippet: **secelmapputils**
	
21. Now let's join *Phoenix* channel from *Elm*

	```
	type MsgType
	    = Increment
    	| Decrement
    	| Join
	```
	Snippet: **secelmappcnmsg**	
	
22. Now let's fix compilation error related to add new MsgType Join by redefining update function

	```
update : MsgType -> Model -> ( Model, Cmd MsgType )
update msg { counter, message } =
    case msg of
        Join ->
            ( Model counter message
            , sendChannelMsg (ChannelMsg "counter:lobby" "phx_join" "rooms:lobby" "ui")
            )

        Increment ->
            ( Model counter message
            , sendChannelMsg (prepareChannelMsg "increment" counter)
            )

        Decrement ->
            ( Model counter message
            , sendChannelMsg (prepareChannelMsg "decrement" counter)
            )
    ```
	Snippet: ****	
	
23. Now let's define our model to handle application state

	```
	type alias Model =
    	{ counter : Int
	    , message : String
    	}
	```
	Snippet: ****		

24. Now let's redefine main function

	```
	main =
    App.program
        { init = init Join
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
	```
	Snippet: ****			

25. Now let's define init function and subscription, during init we're going to join *Phoenix* channel and subscriptions will receive messages from channel

	```
	init : MsgType -> ( Model, Cmd MsgType )
	init action =
    	(update action (Model 0 ""))

	subscriptions : Model -> Sub MsgType
	subscriptions model =
    	WebSocket.listen sockerUrl Receive
	```
	Snippet: ****			
	
26. Now let's add new MsgType to handle messages from channel by updating our application UI

	```
	type MsgType
    	= Increment
	    | Decrement
    	| Join
	    | Receive String
    ```
	Snippet: ****		

27. Now we need to align out update function by adding code to handle Receive MsgType. Now after refresh we can see a response from *Phoenix* on successful established connection to channel

	```
	Receive msgFromChannel ->
            case decodeString decodeChannelMsg msgFromChannel of
                Err msg ->
                    ( Model counter (msg ++ msgFromChannel), Cmd.none )

                Ok value ->
                    ( Model (Result.withDefault counter (String.toInt value.payload)) msgFromChannel, Cmd.none )    	```
	Snippet: ****		

28. Now let's fix our view function to interpret changes happened to model. After that UI looks ok, however we did not alignn our changes at backend to handle increment/decrement

	```
	view : Model -> Html MsgType
	view model =
    	div [ style [ ( "padding", "10px" ) ] ]
        	[ button [ onClick Decrement ] [ text "-" ]
	        , strong [ style [ ( "padding", "10px" ) ] ] [ text (toString model.counter) ]
    	    , button [ onClick Increment ] [ text "+" ]
        	, div [ style [ ( "font-weight", "bold" ), ( "padding", "10px" ) ] ] [ text "Debug:" ]
	        , div [] [ text model.message ]
        	]
    ```
	Snippet: ****		

29. Now let's add some *Elixir* code

	```
	  def handle_in("increment", payload, socket) do
	    broadcast! socket, "increment", %{"body" => "#{String.to_integer(payload["body"]) + 1}"}
    	{:noreply, socket}
	  end
  
	  def handle_in("decrement", payload, socket) do
    	broadcast! socket, "decrement", %{"body" => "#{String.to_integer(payload["body"]) - 1}"}
	    {:noreply, socket}
	  end
    ```
	Snippet: ****		
	