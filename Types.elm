module Types exposing (DomType(..), LastLoadedInfo, Milliseconds, SpeakerTurn, TurnContent, VisibleIndices)


type alias TurnContent =
    { index : Int
    , textContent : String
    , htmlContent : String
    }


type alias Milliseconds =
    Int


type alias SpeakerTurn =
    { name : String
    , start : Float
    , end : Float
    , htmlContent : Maybe String
    , textContent : Maybe String
    , divHeight : Maybe Float
    , visible : Bool
    }


type DomType
    = SpeakerTurnDiv
    | SpeakerTurnsDiv


type alias LastLoadedInfo =
    { totalHeight : Float
    , index : Int
    }


type alias VisibleIndices =
    { first : Maybe Int
    , last : Maybe Int
    }
