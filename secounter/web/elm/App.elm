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



-- TYPES


type MsgType
    = Increment
    | Decrement


type alias ChannelMsg =
    { topic : String
    , event : String
    , payload : String
    , ref : String
    }



-- UPDATE


update : MsgType -> number -> number
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


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



-- VIEW


view : a -> Html MsgType
view model =
    div [ style [ ( "margin", "10px" ) ] ]
        [ button [ onClick Decrement ] [ text "-" ]
        , strong [ style [ ( "margin", "10px" ) ] ] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        , div [ style [ ( "font-weight", "bold" ), ( "padding-top", "10px" ) ] ] [ text "Debug:" ]
        ]
