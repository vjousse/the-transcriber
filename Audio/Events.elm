module Audio.Events exposing (..)

import Html exposing (Attribute)
import Html.Events exposing (on)
import Json.Decode as Json exposing (..)
import Audio.Player


-- JSON decoders


onPause : msg -> Attribute msg
onPause msg =
    on "pause" (Json.succeed msg)


onPlaying : msg -> Attribute msg
onPlaying msg =
    on "playing" (Json.succeed msg)


onCanPlay : (Float -> msg) -> Attribute msg
onCanPlay msg =
    on "canplay" (Json.map msg (targetFloatProperty "duration"))


onTimeUpdate : (Float -> msg) -> Attribute msg
onTimeUpdate msg =
    on "timeupdate" (Json.map msg (targetFloatProperty "currentTime"))


onClickX : (Audio.Player.ClickInformation -> msg) -> Attribute msg
onClickX msg =
    on "click" (Json.map msg decodeClickInformation)


decodeClickInformation : Decoder Audio.Player.ClickInformation
decodeClickInformation =
    object5 Audio.Player.ClickInformation
        ("offsetX" := int)
        (Json.at [ "target", "offsetWidth" ] Json.int)
        (Json.at [ "target", "id" ] Json.string)
        (Json.at [ "target", "offsetParent", "id" ] Json.string)
        (Json.at [ "target", "offsetParent", "offsetWidth" ] Json.int)


{-| A `Json.Decoder` for grabbing `event.target.currentTime`. We use this to define
`onInput` as follows:

    import Json.Decoder as Json

    onInput : (String -> msg) -> Attribute msg
    onInput tagger =
      on "input" (Json.map tagger targetValue)

You probably will never need this, but hopefully it gives some insights into
how to make custom event handlers.
-}
targetFloatProperty : String -> Json.Decoder Float
targetFloatProperty property =
    Json.at [ "target", property ] Json.float
