module Audio.View exposing (view)

import Html exposing (a, audio, button, div, h1, h2, i, li, span, text, ul, Attribute, Html)
import Html.Attributes exposing (class, controls, href, id, type_, src, style)
import Html.Events exposing (on, onClick)
import Set exposing (Set)
import String
import DateTime.Utils exposing (formatTimeInfo)


-- App imports

import Audio.Player
    exposing
        ( Model
        , Msg
            ( Backward
            , Faster
            , Forward
            , ProgressClicked
            , SetPaused
            , SetPlaying
            , SetDuration
            , Slower
            , TimeUpdate
            , Toggle
            )
        )
import Audio.Events
    exposing
        ( onPause
        , onPlaying
        , onCanPlay
        , onTimeUpdate
        , onClickX
        )
import Keyboard.Extra


-- VIEW


view : Model -> Html Msg
view model =
    div
        [ id "elm-audio-player"
        , style [ ( "width", "100%" ) ]
        ]
        [ audio
            [ src model.mediaUrl
            , type_ model.mediaType
            , controls model.defaultControls
            , onTimeUpdate TimeUpdate
            , onPause SetPaused
            , onPlaying SetPlaying
            , onCanPlay SetDuration
            , id "audio-player"
            ]
            []
        , div [ class "app-header white box-shadow" ]
            [ div
                [ class "navbar"
                , style [ ( "width", "100%" ) ]
                ]
                [ ul
                    [ class "nav navbar-nav navbar-nav-inline text-center pull-right m-r text-blue-hover"
                    ]
                    (audioControls model)
                , ul
                    [ class "nav navbar-nav navbar-nav-inline text-center pull-right m-r text-blue-hover"
                    , style [ ( "width", "60%" ) ]
                    ]
                    [ progressBar model ]
                ]
            ]
        ]


audioControls : Model -> List (Html Msg)
audioControls model =
    [ controlButton model.controls.toggle
        Toggle
        (model.toggleShortcut |> Set.toList |> List.map (Keyboard.Extra.stringFromCode "") |> String.join "+")
        (if model.playing then
            "\xE036"
         else
            "\xE039"
        )
    , controlButton model.controls.backward Backward (model.backwardShortcut |> Set.toList |> List.map (Keyboard.Extra.stringFromCode "") |> String.join "+") "\xE020"
    , controlButton model.controls.forward Forward (model.forwardShortcut |> Set.toList |> List.map (Keyboard.Extra.stringFromCode "") |> String.join "+") "\xE01F"
    , controlButton model.controls.slower Slower (model.slowerShortcut |> Set.toList |> List.map (Keyboard.Extra.stringFromCode "") |> String.join "+") "\xE15B"
    , controlButton model.controls.faster Faster (model.fasterShortcut |> Set.toList |> List.map (Keyboard.Extra.stringFromCode "") |> String.join "+") "\xE145"
    ]


progressBar : Model -> Html Msg
progressBar model =
    let
        progress =
            case model.duration of
                Just duration ->
                    (toFloat (model.currentTime) * 100 / toFloat (duration)) |> round |> toString

                Nothing ->
                    "0"
    in
        li
            [ class "nav-item"
            , style [ ( "width", "100%" ) ]
            ]
            [ span
                [ class "nav-text"
                , style [ ( "width", "100%" ) ]
                ]
                [ a
                    [ class "nav-link"
                    , id "progress-link"
                    , style [ ( "width", "100%" ) ]
                    ]
                    [ div
                        [ class "progress nav-text"
                        , id "progress-wrapper"
                        , style
                            [ ( "width", "100%" )
                            , ( "margin-bottom", "0" )
                            ]
                        , onClickX ProgressClicked
                        ]
                        [ div
                            [ class "progress-bar success nav-text"
                            , id "progress-bar"
                            , style [ ( "width", progress ++ "%" ), ( "padding-top", "2px" ) ]
                            ]
                            [ text (progress ++ "%") ]
                        ]
                    ]
                , span [ class "text-xs", id "time-info" ] [ viewTimeInfo model ]
                ]
            ]


viewTimeInfo : Model -> Html Msg
viewTimeInfo model =
    case model.duration of
        Just duration ->
            let
                config =
                    { hSeparator = ":"
                    , mSeparator = ":"
                    , sSeparator = ""
                    , displayEmpty = True
                    }
            in
                text (formatTimeInfo config model.currentTime ++ "/" ++ formatTimeInfo config duration)

        Nothing ->
            text "Loading file…"


controlButton : Bool -> Msg -> String -> String -> Html Msg
controlButton display msg label iconUtf8 =
    if display then
        li [ class "nav-item" ]
            [ a
                [ class "nav-link"
                , onClick msg
                ]
                [ span [ class "nav-text" ]
                    [ i [ class "material-icons" ]
                        [ text iconUtf8
                        ]
                    , span [ class "text-xs" ] [ text label ]
                    ]
                ]
            ]
    else
        text ""
