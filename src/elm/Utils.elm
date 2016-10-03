module Utils exposing (..)


speakerIndexToCssId : Int -> String
speakerIndexToCssId index =
    "S" ++ (index |> toString)


speakerIndexContainerToCssId : Int -> String
speakerIndexContainerToCssId index =
    "C" ++ speakerIndexToCssId index
