module F1 exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias Input =
    List Int


type alias Output =
    Int


run : Input -> Result String Output
run input =
    case List.length input of
        0 ->
            Err "to short"

        n ->
            Ok n


decoder : D.Decoder Input
decoder =
    D.list D.int


encoder : Output -> E.Value
encoder =
    E.int
