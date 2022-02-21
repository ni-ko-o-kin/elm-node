module F1 exposing (..)

import Json.Decode as D
import Json.Encode as E


type alias Input =
    List Int


type alias Output =
    Int


run : Input -> Result String Output
run input =
    case input of
        [] ->
            Err "to short"

        _ ->
            let
                go n =
                    if n >= 2000000000 then
                        n

                    else
                        go (n + 1)
            in
            Ok (go 0)



-- Ok <| List.length input


decoder : D.Decoder Input
decoder =
    D.list D.int


encoder : Output -> E.Value
encoder =
    E.int
