module Model exposing (..)

import Array exposing (Array)
import Keyboard
import Set exposing (Set)
import ISO8601


-- Program imports

import Audio.Player
import Translation.Utils exposing (..)
import Types exposing (Milliseconds, SpeakerTurn)


-- MODEL


type alias Model =
    { currentLanguage : Language
    , audioPlayer : Audio.Player.Model
    , keysDown : Set Keyboard.KeyCode
    , lastSave : Maybe ISO8601.Time
    , scrollTop : Float
    , speakerTurnsHeight : Maybe Float
    , speakerTurns : Array SpeakerTurn
    , visibleMargin : Float
    }
