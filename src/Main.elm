port module Main exposing (main)

import F1
import F2
import Json.Decode as D
import Json.Encode as E
import Platform exposing (worker)


type Msg
    = Start D.Value


type alias RunId =
    String


main : Program () () Msg
main =
    worker
        { init = always ( (), Cmd.none )
        , update = update
        , subscriptions = always (start Start)
        }


type Input
    = F1Input RunId F1.Input
    | F2Input RunId F2.Input


type Output
    = F1Output RunId F1.Output
    | F2Output RunId F2.Output


run : Input -> Output
run input =
    case input of
        F1Input runId input_ ->
            F1.run input_ |> F1Output runId

        F2Input runId input_ ->
            F2.run input_ |> F2Output runId


update : Msg -> () -> ( (), Cmd Msg )
update (Start value) _ =
    case D.decodeValue decoder value of
        Err _ ->
            ( (), output Nothing )

        Ok input ->
            ( ()
            , input
                |> run
                |> encoder
                |> Just
                |> output
            )


decoder =
    D.field "functionId" D.string
        |> D.andThen functionSelector


functionSelector : String -> D.Decoder Input
functionSelector function =
    let
        go inputConstructor inputDecoder =
            D.map2 inputConstructor
                (D.field "runId" D.string)
                (D.field "input" inputDecoder)
    in
    case function of
        "f1" ->
            go F1Input F1.decoder

        "f2" ->
            go F2Input F2.decoder

        _ ->
            D.fail "function not supported"


encoder : Output -> E.Value
encoder out =
    let
        go runId result outputEncoder =
            E.object
                [ ( "status", E.string "ok" )
                , ( "runId", E.string runId )
                , ( "output", outputEncoder result )
                ]
    in
    case out of
        F1Output runId result ->
            go runId result F1.encoder

        F2Output runId result ->
            go runId result F2.encoder


port start : (D.Value -> msg) -> Sub msg


port output : Maybe E.Value -> Cmd msg
