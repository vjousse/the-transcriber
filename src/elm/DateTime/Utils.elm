module DateTime.Utils exposing (..)

import ISO8601
import String


type alias Config =
    { hSeparator : String
    , mSeparator : String
    , sSeparator : String
    , displayEmpty : Bool
    }


formatTimeInfo : Config -> Int -> String
formatTimeInfo config millisecondsTimestamp =
    let
        date =
            millisecondsTimestamp |> ISO8601.fromTime

        hourString =
            if not config.displayEmpty && date.hour == 0 then
                ""
            else
                (date.hour |> toString |> String.padLeft 2 '0') ++ config.hSeparator

        monthString =
            if not config.displayEmpty && date.hour == 0 && date.minute == 0 then
                ""
            else
                (date.minute |> toString |> String.padLeft 2 '0') ++ config.mSeparator

        secondString =
            if not config.displayEmpty && date.hour == 0 && date.minute == 0 && date.second == 0 then
                "-"
            else
                (date.second |> toString |> String.padLeft 2 '0') ++ config.sSeparator
    in
        hourString ++ monthString ++ secondString
