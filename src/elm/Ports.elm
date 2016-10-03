port module Ports exposing (..)

import Types exposing (SpeakerTurn, TurnContent)
import Array exposing (Array)


-- INCOMING SUBSCRIPTIONS


port getSpeakerTurnContent : (TurnContent -> msg) -> Sub msg


port speakerLoaded : (TurnContent -> msg) -> Sub msg


port reactOk : (() -> msg) -> Sub msg



-- OUTGOING PORTS


port sendSpeakerTurns : Array SpeakerTurn -> Cmd msg


port sendSpeakerTurn : { index : Int, speakerTurn : SpeakerTurn } -> Cmd msg


port sendCurrentTime : Float -> Cmd msg


port setCurrentTime : Float -> Cmd msg


port setPlaybackRate : Float -> Cmd msg


port play : () -> Cmd msg


port pause : () -> Cmd msg


playIt : Cmd msg
playIt =
    play ()


pauseIt : Cmd msg
pauseIt =
    pause ()
