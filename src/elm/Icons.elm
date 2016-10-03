module Icons exposing (..)

import Html exposing (Html, i, text)
import Html.Attributes exposing (class)
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, fill, height, viewBox, width)
import Messages exposing (Msg(..))


rainbowIcon : Html Msg
rainbowIcon =
    i [ class "material-icons" ]
        [ text "\xE3FC"
        , svg [ width "48", height "48", viewBox "0 0 48 48" ]
            [ path [ d "M24,20c-7.72,0-14,6.28-14,14h4c0-5.51,4.49-10,10-10s10,4.49,10,10h4C38,26.28,31.721,20,24,20z", fill "#0cc2aa" ] []
            ]
        ]


mapIcon : Html Msg
mapIcon =
    i [ class "material-icons" ]
        [ text "\xE55B"
        ]


locationIcon : Html Msg
locationIcon =
    i [ class "material-icons" ]
        [ text "\xE55C"
        ]
