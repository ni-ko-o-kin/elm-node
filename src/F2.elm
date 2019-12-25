module F2 exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias Input =
    String


type alias Output =
    String


run : Input -> Result String Output
run input =
    case String.length input of
        0 ->
            Err "to short"

        _ ->
            Ok (String.reverse input)


decoder : D.Decoder Input
decoder =
    D.string


encoder : Output -> E.Value
encoder =
    E.string
