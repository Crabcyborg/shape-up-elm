port module Main exposing (..)

import Browser
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Json.Decode
import List exposing (..)

type alias Model =
    { height : Int
    , width : Int
    , grid : List Cell
    }

type alias Flags =
    { height : Int
    , width : Int
    , grid : Json.Decode.Value
    }

type alias Cell =
    { x : Int
    , y : Int
    , color : String
    }

-- MAIN
main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

init : Flags -> ( Model, Cmd msg )
init flags =
    case Json.Decode.decodeValue gridDecoder flags.grid of
        Ok grid ->
            ({ height = flags.height, width = flags.width, grid = grid }, Cmd.none)

        Err err ->
            ({ height = 0, width = 0, grid = []}, Cmd.none)

gridDecoder : Json.Decode.Decoder (List Cell)
gridDecoder =
    Json.Decode.list cellDecoder

cellDecoder : Json.Decode.Decoder Cell
cellDecoder =
    Json.Decode.map3 Cell
        (Json.Decode.field "x" Json.Decode.int)
        (Json.Decode.field "y" Json.Decode.int)
        (Json.Decode.field "color" Json.Decode.string)

-- UPDATE

type Msg
  = ReceivedDataFromJS Model -- Maybe Flags

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ReceivedDataFromJS data ->
      ( data, Cmd.none )

port receiveData : (Model -> msg) -> Sub msg

-- VIEW

renderCell: Cell -> Svg msg
renderCell cell =
    rect
        [ x (String.fromInt (cell.x * 10))
        , y (String.fromInt (cell.y * 10))
        , width "10"
        , height "10"
        , fill cell.color
        ]
        []

view : Model -> Html msg
view model =
  svg
    [ viewBox "0 0 400 400"
    , width "400"
    , height "400"
    ]
    (List.map renderCell model.grid)
    
-- SUBSRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveData ReceivedDataFromJS