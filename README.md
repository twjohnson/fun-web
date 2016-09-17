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


