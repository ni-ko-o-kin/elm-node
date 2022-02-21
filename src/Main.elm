port module Main exposing (main)

import F1
import F2
import Json.Decode as D
import Json.Encode as E
import Platform exposing (worker)


main : Program () () Msg
main =
    worker
        { init = always ( (), Cmd.none )
        , update = update
        , subscriptions = always (start Start)
        }


update : Msg -> () -> ( (), Cmd Msg )
update (Start value) _ =
    ( (), initiate value )


type Msg
    = Start D.Value


type alias JobResult =
    Result String Output


type Input
    = F1Input F1.Input
    | F2Input F2.Input


type Output
    = F1Output F1.Output
    | F2Output F2.Output


run : Input -> JobResult
run input =
    let
        go run_ input_ outputConstructor =
            run_ input_
                |> Result.map outputConstructor
                |> Result.mapError (\error -> error)
    in
    case input of
        F1Input input_ ->
            go F1.run input_ F1Output

        F2Input input_ ->
            go F2.run input_ F2Output


decodeInput : String -> D.Decoder Input
decodeInput functionId =
    let
        go inputDecoder inputConstructor =
            D.field "input" inputDecoder
                |> D.map inputConstructor
    in
    case functionId of
        "f1" ->
            go F1.decoder F1Input

        "f2" ->
            go F2.decoder F2Input

        _ ->
            D.fail "function not supported"


encodeOutput : E.Value -> JobResult -> E.Value
encodeOutput value result =
    let
        go outputEncoder output_ =
            E.object
                [ ( "status", E.string "ok" )
                , ( "output", outputEncoder output_ )
                , ( "input", value )
                ]
    in
    case result of
        Ok out ->
            case out of
                F1Output output_ ->
                    go F1.encoder output_

                F2Output output_ ->
                    go F2.encoder output_

        Err error ->
            E.object
                [ ( "status", E.string "error" )
                , ( "msg", E.string error )
                , ( "input", value )
                ]


initiate : E.Value -> Cmd Msg
initiate value =
    case D.decodeValue decoder value of
        Err e ->
            output
                (E.object
                    [ ( "status", E.string "error" )
                    , ( "msg", E.string (D.errorToString e) )
                    , ( "input", value )
                    ]
                )

        Ok job ->
            job
                |> run
                |> encodeOutput value
                |> output


decoder : D.Decoder Input
decoder =
    D.field "functionId" D.string
        |> D.andThen decodeInput


port start : (D.Value -> msg) -> Sub msg


port output : E.Value -> Cmd msg
