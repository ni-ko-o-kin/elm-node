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


type Msg
    = Start D.Value


type alias RunId =
    String


type Job a
    = Job RunId a


type Input
    = F1Input F1.Input
    | F2Input F2.Input


type Output
    = F1Output F1.Output
    | F2Output F2.Output


run : Job Input -> Result ( RunId, String ) (Job Output)
run (Job runId input) =
    let
        go run_ input_ outputConstructor =
            run_ input_
                |> Result.map outputConstructor
                |> Result.map (Job runId)
                |> Result.mapError (\error -> ( runId, error ))
    in
    case input of
        F1Input input_ ->
            go F1.run input_ F1Output

        F2Input input_ ->
            go F2.run input_ F2Output


update : Msg -> () -> ( (), Cmd Msg )
update (Start value) _ =
    case D.decodeValue decoder value of
        Err _ ->
            ( (), output Nothing )

        Ok job ->
            ( ()
            , job
                |> run
                |> encoder
                |> Just
                |> output
            )


decoder : D.Decoder (Job Input)
decoder =
    D.map2 Job
        (D.field "runId" D.string)
        (D.field "functionId" D.string
            |> D.andThen decodeInput
        )


decodeInput : String -> D.Decoder Input
decodeInput functionId =
    let
        go inpuDecoder inputConstructor =
            D.field "input" inpuDecoder
                |> D.map inputConstructor
    in
    case functionId of
        "f1" ->
            go F1.decoder F1Input

        "f2" ->
            go F2.decoder F2Input

        _ ->
            D.fail "function not supported"


encoder : Result ( RunId, String ) (Job Output) -> E.Value
encoder result =
    let
        go runId outputEncoder output_ =
            E.object
                [ ( "status", E.string "ok" )
                , ( "runId", E.string runId )
                , ( "output", outputEncoder output_ )
                ]
    in
    case result of
        Ok (Job runId out) ->
            case out of
                F1Output output_ ->
                    go runId F1.encoder output_

                F2Output output_ ->
                    go runId F2.encoder output_

        Err ( runId, error ) ->
            E.object
                [ ( "status", E.string "error" )
                , ( "runId", E.string runId )
                , ( "msg", E.string error )
                ]


port start : (D.Value -> msg) -> Sub msg


port output : Maybe E.Value -> Cmd msg
