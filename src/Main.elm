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


type alias JobId =
    String


type Job a
    = Job JobId a


type Input
    = F1Input F1.Input
    | F2Input F2.Input


type Output
    = F1Output F1.Output
    | F2Output F2.Output


run : Job Input -> Result ( JobId, String ) (Job Output)
run (Job jobId input) =
    let
        go run_ input_ outputConstructor =
            run_ input_
                |> Result.map outputConstructor
                |> Result.map (Job jobId)
                |> Result.mapError (\error -> ( jobId, error ))
    in
    case input of
        F1Input input_ ->
            go F1.run input_ F1Output

        F2Input input_ ->
            go F2.run input_ F2Output


update : Msg -> () -> ( (), Cmd Msg )
update (Start value) _ =
    case D.decodeValue decodeJobId value of
        Err e ->
            ( ()
            , output
                (E.object
                    [ ( "status", E.string "error" )
                    , ( "msg", E.string (D.errorToString e) )
                    ]
                )
            )

        Ok jobId ->
            case D.decodeValue decoder value of
                Err e ->
                    ( ()
                    , output
                        (E.object
                            [ ( "status", E.string "error" )
                            , ( "jobId", E.string jobId )
                            , ( "msg", E.string (D.errorToString e) )
                            ]
                        )
                    )

                Ok job ->
                    ( ()
                    , job
                        |> run
                        |> encoder
                        |> output
                    )


decodeJobId : D.Decoder String
decodeJobId =
    D.field "jobId" D.string
        |> D.andThen
            (\jobId ->
                if String.length jobId == 32 then
                    D.succeed jobId

                else
                    D.fail "invalid jobId length; only 32 chars allowed"
            )


decoder : D.Decoder (Job Input)
decoder =
    D.map2 Job
        decodeJobId
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


encoder : Result ( JobId, String ) (Job Output) -> E.Value
encoder result =
    let
        go jobId outputEncoder output_ =
            E.object
                [ ( "status", E.string "ok" )
                , ( "jobId", E.string jobId )
                , ( "output", outputEncoder output_ )
                ]
    in
    case result of
        Ok (Job jobId out) ->
            case out of
                F1Output output_ ->
                    go jobId F1.encoder output_

                F2Output output_ ->
                    go jobId F2.encoder output_

        Err ( jobId, error ) ->
            E.object
                [ ( "status", E.string "error" )
                , ( "jobId", E.string jobId )
                , ( "msg", E.string error )
                ]


port start : (D.Value -> msg) -> Sub msg


port output : E.Value -> Cmd msg
