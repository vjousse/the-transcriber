module Audio.Player exposing (Model, ClickInformation, Msg(..), init, update, subscriptions)

-- Elm modules

import Debug
import Keyboard
import Set exposing (Set)
import Update.Extra
import Types exposing (Milliseconds)


-- Project modules

import Ports


-- MODEL


type alias ClickInformation =
    { offsetX : Int
    , offsetWidth : Int
    , targetCssId : String
    , parentCssId : String
    , parentOffsetWidth : Int
    }


type alias ControlsDisplay =
    { play : Bool
    , pause : Bool
    , slower : Bool
    , faster : Bool
    , resetPlayback : Bool
    , toggle : Bool
    , backward : Bool
    , forward : Bool
    }


type alias Model =
    { mediaUrl : String
    , mediaType : String
    , playing : Bool
    , currentTime : Milliseconds
    , playbackRate : Float
    , playbackStep : Float
    , jumpStep : Milliseconds
    , defaultControls : Bool
    , duration : Maybe Milliseconds
    , controls : ControlsDisplay
    , toggleShortcut : Set Keyboard.KeyCode
    , forwardShortcut : Set Keyboard.KeyCode
    , backwardShortcut : Set Keyboard.KeyCode
    }



-- MSG


type Msg
    = NoOp
    | TimeUpdate Float
    | MoveToCurrentTime Float
    | SetDuration Float
    | SetPlaying
    | SetPaused
    | Slower
    | Faster
    | Play
    | Pause
    | Toggle
    | Forward
    | Backward
    | ResetPlayback
    | Keypress Keyboard.KeyCode
    | ProgressClicked ClickInformation


type alias Flags =
    { mediaUrl : String
    , mediaType : String
    , toggleShortcut : Set Keyboard.KeyCode
    , forwardShortcut : Set Keyboard.KeyCode
    , backwardShortcut : Set Keyboard.KeyCode
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    { mediaUrl = flags.mediaUrl
    , mediaType = flags.mediaType
    , toggleShortcut = flags.toggleShortcut
    , forwardShortcut = flags.forwardShortcut
    , backwardShortcut = flags.backwardShortcut
    , playing = False
    , currentTime = 0
    , playbackRate = 1
    , playbackStep =
        0.1
        -- Milliseconds
    , jumpStep = (10 * 1000)
    , defaultControls = False
    , duration = Nothing
    , controls =
        { play = True
        , pause = True
        , slower = True
        , faster = True
        , resetPlayback = True
        , toggle = True
        , backward = True
        , forward = True
        }
    }
        ! []



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate time ->
            -- we get the time in seconds, and we want it as
            -- milliseconds (Time.Time)
            ( { model | currentTime = ((time * 1000) |> round) }
            , Ports.sendCurrentTime time
            )

        SetDuration time ->
            ( { model | duration = Just ((time * 1000) |> round) }, Cmd.none )

        SetPlaying ->
            ( { model | playing = True }, Cmd.none )

        SetPaused ->
            ( { model | playing = False }, Cmd.none )

        Toggle ->
            if model.playing then
                ( model, Ports.pauseIt )
            else
                ( model, Ports.playIt )

        Backward ->
            ( model, Cmd.none )
                |> Update.Extra.andThen update
                    (MoveToCurrentTime (toFloat (model.currentTime - model.jumpStep) / 1000))

        Forward ->
            ( model, Cmd.none )
                |> Update.Extra.andThen update
                    (MoveToCurrentTime (toFloat (model.currentTime + model.jumpStep) / 1000))

        Slower ->
            let
                newPlaybackRate =
                    model.playbackRate - model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }, Ports.setPlaybackRate newPlaybackRate )

        Faster ->
            let
                newPlaybackRate =
                    model.playbackRate + model.playbackStep
            in
                ( { model | playbackRate = newPlaybackRate }, Ports.setPlaybackRate newPlaybackRate )

        MoveToCurrentTime time ->
            ( model, Ports.setCurrentTime time )

        ResetPlayback ->
            ( model, Ports.setPlaybackRate 1 )

        ProgressClicked clickInformation ->
            let
                percentage =
                    Debug.log "%" (toFloat clickInformation.offsetX / toFloat clickInformation.parentOffsetWidth)

                newTime =
                    case model.duration of
                        Just duration ->
                            (toFloat duration * percentage / 1000) |> round

                        Nothing ->
                            model.currentTime
            in
                ( model, Cmd.none )
                    |> Update.Extra.andThen update (MoveToCurrentTime (toFloat newTime))

        _ ->
            Debug.log "Debug Player Component " ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
