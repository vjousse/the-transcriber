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
    = DomHeight Dom.Id Int Types.DomType (Result Dom.Error Float)
    | Fetch (Result Http.Error (Array SpeakerTurn))
    | KeyDown Keyboard.KeyCode
    | KeyUp Keyboard.KeyCode
    | MsgAudioPlayer Audio.Player.Msg
    | ReactOk
    | SetLanguage Language
    | SpeakerLoaded TurnContent
    | UpdateTurnContent TurnContent
    | UserScroll Float
