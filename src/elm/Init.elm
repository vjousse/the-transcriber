module Init exposing (init, Flags)

import Array exposing (Array)
import Dict exposing (Dict)
import Set exposing (Set)


-- App imports

import Audio.Player
import Messages exposing (Msg(..))
import Model exposing (Model)
import Tasks
import Translation.Utils exposing (..)
import Keyboard.Extra


type alias Flags =
    { mediaUrl : String
    , mediaType : String
    }


init : Flags -> ( Model, Cmd Messages.Msg )
init flags =
    let
        ( audioPlayerInit, audioPlayerCmds ) =
            Audio.Player.init
                { mediaUrl = flags.mediaUrl
                , mediaType = flags.mediaType
                , toggleShortcut =
                    [ Keyboard.Extra.Escape ]
                        |> List.map Keyboard.Extra.toCode
                        |> Set.fromList
                , forwardShortcut =
                    [ Keyboard.Extra.Control, Keyboard.Extra.ArrowRight ]
                        |> List.map Keyboard.Extra.toCode
                        |> Set.fromList
                , backwardShortcut =
                    [ Keyboard.Extra.Control, Keyboard.Extra.ArrowLeft ]
                        |> List.map Keyboard.Extra.toCode
                        |> Set.fromList
                }
    in
        { audioPlayer = audioPlayerInit
        , currentLanguage = English
        , keysDown = Set.empty
        , nbSpeakers = Nothing
        , currentSpeakerTurn = Nothing
        , lastSave = Nothing
        , scrollTop = 0
        , speakerTurns = Array.empty
        , speakerTurnsHeight = Nothing
        , visibleIndices = []
        , loadedSpeakerTurns = Dict.empty
        , visibleMargin = 300
        }
            ! [ Cmd.batch
                    [ Cmd.map MsgAudioPlayer audioPlayerCmds
                    , Tasks.getSpeakerData "http://localhost:8080/examples/lcp_q_gov_ckeditor.json"
                      --, Tasks.getSpeakerData "http://localhost/lcp_q_gov_api_sample.json"
                      --, Tasks.getSpeakerData "http://localhost/crb_jeudi_25_fevrier.json"
                      --, Tasks.getSpeakerData "http://localhost/crb_jeudi_25_fevrier_ckeditor.json"
                    ]
              ]
