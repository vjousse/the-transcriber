module Tasks exposing (..)

import Array exposing (Array)
import Dom
import Dom.Size exposing (Boundary(..))
import Dom.Scroll
import Http
import Json.Decode as Json exposing ((:=))
import Task


-- App import

import Messages exposing (Msg(..))
import Types exposing (SpeakerTurn, DomType(..))


getDomHeight : Dom.Id -> Int -> DomType -> Cmd Messages.Msg
getDomHeight id index domType =
    Task.perform (DomHeightFailed id) (DomHeightSucceed id index domType) (Dom.Size.height Dom.Size.VisibleContentWithBordersAndMargins id)


getSpeakerData : String -> Cmd Messages.Msg
getSpeakerData url =
    Task.perform FetchFail FetchSucceed (Http.get decodeSpeakerResponse url)


decodeSpeakerTurn : Json.Decoder SpeakerTurn
decodeSpeakerTurn =
    Json.object5 speakerTurnBuilder
        ("name" := Json.string)
        ("start" := Json.float)
        ("end" := Json.float)
        (Json.maybe ("htmlContent" := Json.string))
        (Json.maybe ("textContent" := Json.string))


speakerTurnBuilder : String -> Float -> Float -> Maybe String -> Maybe String -> SpeakerTurn
speakerTurnBuilder name start end htmlContent textContent =
    SpeakerTurn name start end htmlContent textContent Nothing False


decodeSpeakerResponse : Json.Decoder (Array SpeakerTurn)
decodeSpeakerResponse =
    Json.array decodeSpeakerTurn
