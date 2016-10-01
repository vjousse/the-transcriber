module Layout exposing (..)

import Array exposing (Array)
import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (alt, attribute, class, contenteditable, id, href, placeholder, src, type', style)
import Html.Events exposing (onClick, on)
import Json.Decode as Json exposing ((:=))
import List
import String


-- App import

import Audio.View
import DateTime.Utils exposing (formatTimeInfo)
import Icons
import Messages exposing (Msg(..))
import Model exposing (Model)
import Translation.Utils exposing (..)
import Types exposing (SpeakerTurn, SpeakerTurn)
import Utils


asideView : Model -> Html Msg
asideView model =
    div
        [ id "aside"
        , class ("app-aside modal fade nav-dropdown")
        ]
        [ div [ class "left navside dark dk" ]
            [ div [ class "navbar no-radius" ]
                [ a [ class "navbar-brand" ]
                    [ img [ src "images/logo.png" ] []
                    , span [ class "hidden-folded inline" ] [ text "STT studio" ]
                    ]
                ]
            , div [ class "hide-scroll", attribute "flex" "" ]
                [ nav [ class "scroll nav-light" ]
                    [ ul [ class "nav" ]
                        [ li [ class "nav-header hidden-folded" ] [ small [ class "text-muted" ] [ text <| translate model.currentLanguage Dashboard ] ]
                        , li []
                            [ a [ href "#" ]
                                [ span [ class "nav-icon" ] [ Icons.locationIcon ]
                                , span [ class "nav-text" ] [ text <| translate model.currentLanguage Home ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


contentView : Model -> Html Msg
contentView model =
    div [ id "content", class "app-content box-shadow-z0" ]
        [ headerView model
        , bodyView model
        ]


headerView : Model -> Html Msg
headerView model =
    div [ class "app-header" ]
        [ App.map MsgAudioPlayer (Audio.View.view model.audioPlayer)
        ]


sumWords : SpeakerTurn -> Int -> Int
sumWords speakerTurn acc =
    case speakerTurn.textContent of
        Just textContent ->
            (String.words textContent |> List.length) + acc

        Nothing ->
            acc


bodyView : Model -> Html Msg
bodyView model =
    div
        [ class "app-body"
        , id "view"
        ]
        [ div [ class "dker p-x" ]
            [ div [ class "row" ]
                [ div [ class "col-sm-6 col-sm-push-6" ]
                    [ div [ class "p-y text-center text-sm-right" ]
                        [ a [ class "inline p-x text-center" ]
                            [ span [ class "h4 block m-a-0" ]
                                [ Array.length model.speakerTurns
                                    |> toString
                                    |> text
                                ]
                            , small [ class "text-xs text-muted" ]
                                [ text <| translate model.currentLanguage Speakers ]
                            ]
                        , a [ class "inline p-x b-l b-r text-center" ]
                            [ span [ class "h4 block m-a-0" ]
                                [ text (toString (Array.foldl sumWords 0 model.speakerTurns))
                                ]
                            , small [ class "text-xs text-muted" ]
                                [ text <| translate model.currentLanguage Words ]
                            ]
                        , a [ class "inline p-x text-center" ]
                            [ span [ class "h4 block m-a-0" ]
                                [ text
                                    (case model.audioPlayer.duration of
                                        Just duration ->
                                            let
                                                config =
                                                    { hSeparator = "h "
                                                    , mSeparator = "m "
                                                    , sSeparator = "s"
                                                    , displayEmpty = False
                                                    }
                                            in
                                                formatTimeInfo config duration

                                        Nothing ->
                                            "-"
                                    )
                                ]
                            , small [ class "text-xs text-muted" ]
                                [ text <| translate model.currentLanguage Duration ]
                            ]
                        ]
                    ]
                ]
            ]
        , div [ class "padding" ]
            [ div [ class "row" ]
                [ div
                    [ class "col-sm-8 col-lg-9"
                    , id "speaker-turns"
                    , onScroll UserScroll
                    ]
                    [ div [ class "streamline b-l m-b m-l" ]
                        [ speakerTurns model ]
                    ]
                , div [ class "col-sm-4 col-lg-3" ]
                    [ div []
                        [ div [ class "box" ]
                            [ div [ class "box-header" ]
                                [ h3 [] [ text <| translate model.currentLanguage Save ]
                                , small []
                                    (case model.lastSave of
                                        Just lastSave ->
                                            [ text <| translate model.currentLanguage (LastSave "2 min")
                                            , i [ class "fa fa-fw fa-clock-o" ] []
                                            ]

                                        Nothing ->
                                            [ text <| translate model.currentLanguage (NoSave) ]
                                    )
                                ]
                            , div [ class "box-divider m-a-0" ] []
                            , ul [ class "list no-border p-b" ]
                                [ exportItem model (translate model.currentLanguage (ExportTo "TXT")) ".txt" "fa-file-text"
                                , exportItem model (translate model.currentLanguage (ExportTo "SRT")) ".srt" "fa-file-video-o"
                                , exportItem model (translate model.currentLanguage (ExportTo "WebVTT")) ".vtt" "fa-file-video-o"
                                , exportItem model (translate model.currentLanguage (ExportTo "XML")) ".xml" "fa-file-code-o"
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


exportItem : Model -> String -> String -> String -> Html Msg
exportItem model title extension icon =
    li [ class "list-item" ]
        [ a [ class "list-left" ]
            [ button [ class "btn btn-icon white" ]
                [ i [ class ("fa " ++ icon) ] [] ]
            ]
        , div [ class "list-body" ]
            [ div []
                [ a [] [ text title ] ]
            , small [ class "text-muted text-ellipsis" ] [ text extension ]
            ]
        ]


speakerTurns : Model -> Html Msg
speakerTurns model =
    div [] (List.map speakerTurn (Array.toIndexedList model.speakerTurns))


speakerTurn : ( Int, SpeakerTurn ) -> Html Msg
speakerTurn ( index, speakerTurn ) =
    let
        timeConfig =
            { hSeparator = ":"
            , mSeparator = ":"
            , sSeparator = ""
            , displayEmpty = True
            }
    in
        div
            [ class "sl-item"
            , id <| Utils.speakerIndexContainerToCssId index
            ]
            [ div [ class "sl-left" ] [ span [ class "w-40 circle green avatar" ] [ text <| String.left 1 speakerTurn.name ] ]
            , div [ class "sl-content" ]
                [ div [ class "sl-date text-muted" ]
                    [ round speakerTurn.start |> (*) 1000 |> formatTimeInfo timeConfig |> text
                    , text " "
                    , case speakerTurn.divHeight of
                        Just height ->
                            height |> toString |> text

                        Nothing ->
                            "N/C" |> text
                    ]
                , div [ class "sl-author" ]
                    [ a [] [ text speakerTurn.name ] ]
                , div [ class "box p-a m-b-md" ]
                    [ div
                        [ class "summernote note-air-editor note-editable panel-body"
                        , id <| Utils.speakerIndexToCssId index
                        ]
                        [ div [ class "speaker-pace-activity" ] []
                        ]
                    ]
                ]
            ]


onScroll : (Float -> msg) -> Html.Attribute msg
onScroll tagger =
    on "scroll" <| Json.map tagger scrollTop


scrollTop : Json.Decoder Float
scrollTop =
    Json.at [ "target", "scrollTop" ] Json.float
