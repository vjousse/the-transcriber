module Main exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (div, text, Html)
import Html.Attributes exposing (id, class)
import Keyboard
import List.Extra as LE
import Set exposing (Set)


-- App imports

import Audio.Player exposing (Msg(Backward, Forward, Toggle))
import Init
import Layout
import Messages exposing (Msg(..))
import Model exposing (Model)
import Tasks
import Types exposing (DomType(..), LastLoadedInfo, SpeakerTurn, TurnContent, VisibleIndices)
import Utils


main : Program Init.Flags Model Messages.Msg
main =
    Html.programWithFlags
        { init = Init.init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


update : Messages.Msg -> Model -> ( Model, Cmd Messages.Msg )
update msg model =
    case Debug.log "[Elm::Main Update] " msg of
        --case msg of
        DomHeight id index divType (Err domError) ->
            let
                debug =
                    Debug.log "[Elm::DomHeightFailed]" domError
            in
                model ! []

        DomHeight id index divType (Ok height) ->
            case divType of
                Types.SpeakerTurnsDiv ->
                    ( model, Cmd.none )
                        |> updateSpeakerTurnsDivHeight index height

                Types.SpeakerTurnDiv ->
                    ( model, Cmd.none )
                        |> updateSpeakerDivHeight index height

        --|> loadMoreSpeakersIfNeeded
        Fetch (Ok speakerTurns) ->
            ( { model | speakerTurns = speakerTurns }
              --, Ports.sendSpeakerTurns speakerTurns
            , Cmd.none
            )

        Fetch (Err error) ->
            let
                debug =
                    Debug.log "[Elm] FetchFail" error
            in
                ( model, Cmd.none )

        KeyDown code ->
            let
                keysDown =
                    Set.insert code model.keysDown

                message =
                    checkKeyPressedForShortcuts keysDown model
            in
                case message of
                    Just aMessage ->
                        let
                            ( audioPlayerModel, audioPlayerCmds ) =
                                Audio.Player.update aMessage model.audioPlayer
                        in
                            ( { model | audioPlayer = audioPlayerModel, keysDown = keysDown }
                            , Cmd.map MsgAudioPlayer audioPlayerCmds
                            )

                    Nothing ->
                        ( { model | keysDown = keysDown }, Cmd.none )

        KeyUp code ->
            let
                keysDown =
                    Set.remove code model.keysDown
            in
                ( { model | keysDown = keysDown }, Cmd.none )

        MsgAudioPlayer aMessage ->
            let
                ( audioPlayerModel, audioPlayerCmds ) =
                    Audio.Player.update aMessage model.audioPlayer
            in
                ( { model | audioPlayer = audioPlayerModel }
                , Cmd.map MsgAudioPlayer audioPlayerCmds
                )

        SetLanguage lang ->
            ( { model | currentLanguage = lang }, Cmd.none )

        UpdateTurnContent turnContent ->
            ( model, Cmd.none )
                |> updateSpeakerTurnTextContent turnContent
                |> getDivHeight turnContent.index

        UserScroll scrollTop ->
            let
                debug =
                    Debug.log "[Elm::firstLastVisibleIndexes]" (firstLastVisibleIndexes model)
            in
                ( { model | scrollTop = scrollTop }, Cmd.none )



--|> loadMoreSpeakersIfNeeded
{--
loadSpeakerIndexCmd : Int -> Array SpeakerTurn -> Cmd Messages.Msg
loadSpeakerIndexCmd index speakerTurns =
    case (Array.get index speakerTurns) of
        Just speakerTurn ->
            Ports.sendSpeakerTurn { index = index, speakerTurn = speakerTurn }

        Nothing ->
            Cmd.none
--}
{--
Compute the height of the first loaded elements if any

An element is considered loaded if it has a divHeight
--}


infoOfLastLoaded : Array SpeakerTurn -> Maybe Types.LastLoadedInfo
infoOfLastLoaded speakerTurns =
    let
        loadedSpeakersList =
            loadedSpeakers speakerTurns

        loadedSpeakersHeight =
            List.foldl (\turn acc -> (Maybe.withDefault 0 turn.divHeight) + acc)
                0
                loadedSpeakersList
    in
        if List.length loadedSpeakersList > 0 then
            Just
                { index = (List.length loadedSpeakersList) - 1
                , totalHeight = loadedSpeakersHeight
                }
        else
            Nothing


loadedSpeakers : Array SpeakerTurn -> List SpeakerTurn
loadedSpeakers speakerTurns =
    -- Let's say that the loaded speakers are the speakers with a div height
    -- that is not Nothing
    Array.toList speakerTurns
        |> LE.takeWhile
            (\turn ->
                case turn.divHeight of
                    Just _ ->
                        True

                    Nothing ->
                        False
            )


isVisibleAreaLoaded : Model -> Bool
isVisibleAreaLoaded model =
    let
        loadedSpeakersInfo =
            infoOfLastLoaded model.speakerTurns
    in
        case model.speakerTurnsHeight of
            Just speakerTurnsHeight ->
                case loadedSpeakersInfo of
                    Just loadedInfo ->
                        -- Load a little more than just the visible area
                        -- add visibleMargin to it
                        if (speakerTurnsHeight + model.visibleMargin) >= (loadedInfo.totalHeight - model.scrollTop) then
                            False
                        else
                            True

                    Nothing ->
                        False

            Nothing ->
                False


firstLastVisibleIndexes : Model -> Types.VisibleIndices
firstLastVisibleIndexes model =
    let
        -- Compute the positions of every div from the start
        -- in an Array, indexes are the same than the speakers one,
        -- values are the Maybe accumulated heights
        positions =
            Array.foldl
                (\current ( totalHeight, array ) ->
                    case current.divHeight of
                        Just height ->
                            ( totalHeight + height, Array.push (Just ( totalHeight, height )) array )

                        Nothing ->
                            ( totalHeight, Array.push Nothing array )
                )
                ( 0, Array.empty )
                model.speakerTurns
                |> Tuple.second

        positionsList =
            Array.toList positions

        firstIndex =
            case model.speakerTurnsHeight of
                Just speakerTurnsHeight ->
                    LE.findIndex
                        (\maybePosition ->
                            case maybePosition of
                                Just ( position, height ) ->
                                    (position
                                        > model.scrollTop
                                        || (position <= model.scrollTop && (position + height >= model.scrollTop + speakerTurnsHeight))
                                    )

                                Nothing ->
                                    False
                        )
                        positionsList

                Nothing ->
                    Nothing

        lastIndex =
            case model.speakerTurnsHeight of
                Just speakerTurnsHeight ->
                    LE.findIndex
                        (\maybePosition ->
                            case maybePosition of
                                Just ( position, height ) ->
                                    (position + height > (model.scrollTop + model.visibleMargin + speakerTurnsHeight))

                                Nothing ->
                                    False
                        )
                        positionsList

                Nothing ->
                    Nothing
    in
        { first = firstIndex, last = lastIndex }


updateSpeakerTurnTextContent : TurnContent -> ( Model, Cmd Messages.Msg ) -> ( Model, Cmd Messages.Msg )
updateSpeakerTurnTextContent turnContent ( model, messages ) =
    let
        oldSpeakerTurn =
            Array.get turnContent.index model.speakerTurns

        newSpeakerTurns =
            case oldSpeakerTurn of
                Just speakerTurn ->
                    Array.set turnContent.index
                        { speakerTurn
                            | textContent =
                                Just turnContent.textContent
                                -- Once we get some text content back from reactjs
                                -- we should not need the rawContent anymore
                                -- let's see how it goes in the future
                            , htmlContent = Just turnContent.htmlContent
                        }
                        model.speakerTurns

                Nothing ->
                    model.speakerTurns
    in
        ( { model | speakerTurns = newSpeakerTurns }, messages )


updateSpeakerDivHeight : Int -> Float -> ( Model, Cmd Messages.Msg ) -> ( Model, Cmd Messages.Msg )
updateSpeakerDivHeight index height ( model, messages ) =
    let
        newSpeakerTurns =
            case (Array.get index model.speakerTurns) of
                Just speakerTurn ->
                    Array.set index
                        { speakerTurn
                            | divHeight = Just height
                        }
                        model.speakerTurns

                Nothing ->
                    model.speakerTurns
    in
        ( { model | speakerTurns = newSpeakerTurns }, messages )



{--

loadMoreSpeakersIfNeeded : ( Model, Cmd Messages.Msg ) -> ( Model, Cmd Messages.Msg )
loadMoreSpeakersIfNeeded ( model, messages ) =
    let
        lastLoadedInfo =
            Debug.log "[Elm::infoOfLastLoaded]" (infoOfLastLoaded model.speakerTurns)

        visibleAreaLoaded =
            Debug.log "[Elm::visibleAreaLoaded]" (isVisibleAreaLoaded model)
    in
        -- Everything is loaded in visible area, that's cool!
        if visibleAreaLoaded then
            ( model, Cmd.none )
            -- We need to load more data
        else
            case lastLoadedInfo of
                Just loadedInfo ->
                    if
                        loadedInfo.index
                            >= 0
                            && loadedInfo.index
                            < ((Array.length model.speakerTurns) - 1)
                        -- If we are in the speaker range, let's try to load
                        -- the next one
                    then
                        ( model, loadSpeakerIndexCmd (loadedInfo.index + 1) model.speakerTurns )
                    else
                        ( model, loadSpeakerIndexCmd 0 model.speakerTurns )

                -- Doesn't make any sense as we are here because a speaker
                -- was already, but who knows. Let's try to reload the first
                -- one
                Nothing ->
                    ( model, loadSpeakerIndexCmd 0 model.speakerTurns )

--}


updateSpeakerTurnsDivHeight : Int -> Float -> ( Model, Cmd Messages.Msg ) -> ( Model, Cmd Messages.Msg )
updateSpeakerTurnsDivHeight index height ( model, messages ) =
    ( { model
        | speakerTurnsHeight = Just height
        , loadedSpeakerTurns = Dict.insert index height model.loadedSpeakerTurns
      }
    , messages
    )


getDivHeight : Int -> ( Model, Cmd Messages.Msg ) -> ( Model, Cmd Messages.Msg )
getDivHeight index ( model, messages ) =
    let
        debug =
            Debug.log "[UpdateDivHeight] " index
    in
        ( model
        , Cmd.batch
            [ messages
            , Tasks.getDomHeight (Utils.speakerIndexContainerToCssId index)
                index
                Types.SpeakerTurnDiv
            ]
        )


checkKeyPressedForShortcuts : Set Keyboard.KeyCode -> Model -> Maybe Audio.Player.Msg
checkKeyPressedForShortcuts keysDown model =
    if (Set.intersect keysDown model.audioPlayer.toggleShortcut) == model.audioPlayer.toggleShortcut then
        Just Toggle
    else if (Set.intersect keysDown model.audioPlayer.forwardShortcut) == model.audioPlayer.forwardShortcut then
        Just Forward
    else if (Set.intersect keysDown model.audioPlayer.backwardShortcut) == model.audioPlayer.backwardShortcut then
        Just Backward
    else
        Nothing



-- VIEW


view : Model -> Html Messages.Msg
view model =
    div
        [ id "main"
        ]
        [ div [ class "app", id "app" ]
            [ --Layout.asideView model
              Layout.contentView model
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Messages.Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        ]
