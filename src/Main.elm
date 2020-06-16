module Main exposing (..)

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
    , subscriptions = (\_ -> Sub.none)
    }

-- MODEL

init : Flags -> ( Model, Cmd msg )
init flags =
    case Json.Decode.decodeValue gridDecoder flags.grid of
        Ok grid ->
            ({ height = flags.height, width = flags.width, grid = grid }, Cmd.none)

        Err err ->
            Debug.todo "Invalid JSON"

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
  = Redraw

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Redraw  ->
      ( model, Cmd.none )

-- VIEW

renderCell: Cell -> Svg msg
renderCell cell =
    rect
        [ x (String.fromInt (cell.x * 20))
        , y (String.fromInt (cell.y * 20))
        , width "20"
        , height "20"
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
    