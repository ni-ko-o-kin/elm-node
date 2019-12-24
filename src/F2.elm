module F2 exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias Input =
    String


type alias Output =
    String


run : Input -> Output
run =
    String.reverse


decoder : D.Decoder Input
decoder =
    D.string


encoder : Output -> E.Value
encoder =
    E.string
