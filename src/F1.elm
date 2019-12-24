module F1 exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias Input =
    List Int


type alias Output =
    Int


run : Input -> Output
run =
    List.length


decoder : D.Decoder Input
decoder =
    D.list D.int


encoder : Output -> E.Value
encoder =
    E.int
