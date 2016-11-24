module Tasks exposing (..)

import Array exposing (Array)
import Dom
import Dom.Size exposing (Boundary(..))
import Http
import Json.Decode as Json
import Task


-- App import

import Messages exposing (Msg(..))
import Types exposing (SpeakerTurn, DomType(..))


getDomHeight : Dom.Id -> Int -> DomType -> Cmd Messages.Msg
getDomHeight id index domType =
    Task.attempt (DomHeight id index domType) (Dom.Size.height Dom.Size.VisibleContentWithBordersAndMargins id)


getSpeakerData : String -> Cmd Messages.Msg
getSpeakerData url =
    Http.send Fetch (Http.get url decodeSpeakerResponse)


decodeSpeakerTurn : Json.Decoder SpeakerTurn
decodeSpeakerTurn =
    Json.map5 speakerTurnBuilder
        (Json.field "name" Json.string)
        (Json.field "start" Json.float)
        (Json.field "end" Json.float)
        (Json.maybe (Json.field "htmlContent" Json.string))
        (Json.maybe (Json.field "textContent" Json.string))


speakerTurnBuilder : String -> Float -> Float -> Maybe String -> Maybe String -> SpeakerTurn
speakerTurnBuilder name start end htmlContent textContent =
    SpeakerTurn name start end htmlContent textContent Nothing False


decodeSpeakerResponse : Json.Decoder (Array SpeakerTurn)
decodeSpeakerResponse =
    Json.array decodeSpeakerTurn
