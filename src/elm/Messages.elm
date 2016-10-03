module Messages exposing (Msg(..))

import Array exposing (Array)
import Dom
import Http
import Keyboard


-- App imports

import Audio.Player
import Translation.Utils exposing (..)
import Types exposing (SpeakerTurn, TurnContent)


type Msg
    = DomHeightSucceed Dom.Id Int Types.DomType Float
    | DomHeightFailed Dom.Id Dom.Error
    | FetchSucceed (Array SpeakerTurn)
    | FetchFail Http.Error
    | KeyDown Keyboard.KeyCode
    | KeyUp Keyboard.KeyCode
    | MsgAudioPlayer Audio.Player.Msg
    | ReactOk
    | SetLanguage Language
    | SpeakerLoaded TurnContent
    | UpdateTurnContent TurnContent
    | UserScroll Float
