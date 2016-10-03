module Keyboard.Extra
    exposing
        ( subscriptions
        , update
        , init
        , isPressed
        , arrows
        , wasd
        , arrowsDirection
        , wasdDirection
        , pressedDown
        , Direction(..)
        , Key(..)
        , Model
        , Msg
        , targetKey
        , stringFromCode
        , toCode
        )

{-| Convenience helpers for working with keyboard inputs.

# Helpers
@docs isPressed, pressedDown

# Directions
@docs arrows, wasd, Direction, arrowsDirection, wasdDirection

# Wiring
@docs Model, Msg, subscriptions, init, update

# Decoder
@docs targetKey

# Keyboard keys
@docs Key
-}

import Keyboard exposing (KeyCode)
import Dict exposing (Dict)
import Set exposing (Set)
import Json.Decode as Json exposing ((:=))
import Keyboard.Arrows as Arrows exposing (Arrows)


{-| The message type `Keyboard.Extra` uses.
-}
type Msg
    = Down KeyCode
    | Up KeyCode


{-| You will need to add this to your program's subscriptions.
-}
subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Keyboard.downs Down
        , Keyboard.ups Up
        ]


{-| The internal representation of `Keyboard.Extra`. Useful for type annotation.
-}
type alias Model =
    { keysDown : Set KeyCode }


{-| Use this to initialize the component.
-}
init : ( Model, Cmd Msg )
init =
    ( Model Set.empty, Cmd.none )


{-| You need to call this to have the component update.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Down code ->
            let
                keysDown =
                    Set.insert code model.keysDown
            in
                { model | keysDown = keysDown } ! []

        Up code ->
            let
                keysDown =
                    Set.remove code model.keysDown
            in
                { model | keysDown = keysDown } ! []


{-| Gives the arrow keys' pressed down state as follows:

- `{ x = 0, y = 0 }` when pressing no arrows.
- `{ x =-1, y = 0 }` when pressing the left arrow.
- `{ x = 1, y = 1 }` when pressing the up and right arrows.
- `{ x = 0, y =-1 }` when pressing the down, left, and right arrows (left and right cancel out).
-}
arrows : Model -> Arrows
arrows model =
    Arrows.determineArrows model.keysDown


{-| Similar to `arrows`, gives the W, A, S and D keys' pressed down state.

- `{ x = 0, y = 0 }` when pressing none of W, A, S and D.
- `{ x =-1, y = 0 }` when pressing A.
- `{ x = 1, y = 1 }` when pressing W and D.
- `{ x = 0, y =-1 }` when pressing A, S and D (A and D cancel out).
-}
wasd : Model -> Arrows
wasd model =
    Arrows.determineWasd model.keysDown


{-| Type representation of the arrows.
-}
type Direction
    = North
    | NorthEast
    | East
    | SouthEast
    | South
    | SouthWest
    | West
    | NorthWest
    | NoDirection


{-| Gives the arrow keys' pressed down state as follows:

- `None` when pressing no arrows.
- `West` when pressing the left arrow.
- `NorthEast` when pressing the up and right arrows.
- `South` when pressing the down, left, and right arrows (left and right cancel out).
-}
arrowsDirection : Model -> Direction
arrowsDirection =
    arrowsToDir << arrows


{-| Similar to `arrows`, gives the W, A, S and D keys' pressed down state.

- `None` when pressing none of W, A, S and D.
- `West` when pressing A.
- `NorthEast` when pressing W and D.
- `South` when pressing A, S and D (A and D cancel out).
-}
wasdDirection : Model -> Direction
wasdDirection =
    arrowsToDir << wasd


arrowsToDir : Arrows -> Direction
arrowsToDir { x, y } =
    case ( x, y ) of
        ( 0, 1 ) ->
            North

        ( 1, 1 ) ->
            NorthEast

        ( 1, 0 ) ->
            East

        ( 1, -1 ) ->
            SouthEast

        ( 0, -1 ) ->
            South

        ( -1, -1 ) ->
            SouthWest

        ( -1, 0 ) ->
            West

        ( -1, 1 ) ->
            NorthWest

        _ ->
            NoDirection


{-| Check the pressed down state of any `Key`.
-}
isPressed : Key -> Model -> Bool
isPressed key model =
    Set.member (toCode key) model.keysDown


{-| Get the full list of keys that are currently pressed down.
-}
pressedDown : Model -> List Key
pressedDown model =
    model.keysDown
        |> Set.toList
        |> List.map keyFromCode


keyFromCode : KeyCode -> Key
keyFromCode code =
    codeDict
        |> Dict.get code
        |> Maybe.withDefault ( Other, Nothing )
        |> fst


maybeStringFromCode : KeyCode -> Maybe String
maybeStringFromCode code =
    codeDict
        |> Dict.get code
        |> Maybe.withDefault ( Other, Nothing )
        |> snd


stringFromCode : String -> KeyCode -> String
stringFromCode default code =
    codeDict
        |> Dict.get code
        |> Maybe.withDefault ( Other, Nothing )
        |> snd
        |> Maybe.withDefault default


toCode : Key -> KeyCode
toCode key =
    codeBook
        |> List.filter (\n -> key == (n |> snd |> fst))
        |> List.map fst
        |> List.head
        |> Maybe.withDefault 0


{-| A `Json.Decoder` for grabbing `event.keyCode` and turning it into a `Key`

    import Json.Decode as Json

    onKey : (Key -> msg) -> Attribute msg
    onKey tagger =
      on "keydown" (Json.map tagger targetKey)
-}
targetKey : Json.Decoder Key
targetKey =
    Json.map keyFromCode ("keyCode" := Json.int)


{-| These are all the keys that have names in `Keyboard.Extra`.
-}
type Key
    = Cancel
    | Help
    | BackSpace
    | Tab
    | Clear
    | Enter
    | Shift
    | Control
    | Alt
    | Pause
    | CapsLock
    | Escape
    | Convert
    | NonConvert
    | Accept
    | ModeChange
    | Space
    | PageUp
    | PageDown
    | End
    | Home
    | ArrowLeft
    | ArrowUp
    | ArrowRight
    | ArrowDown
    | Select
    | Print
    | Execute
    | PrintScreen
    | Insert
    | Delete
    | Number0
    | Number1
    | Number2
    | Number3
    | Number4
    | Number5
    | Number6
    | Number7
    | Number8
    | Number9
    | Colon
    | Semicolon
    | LessThan
    | Equals
    | GreaterThan
    | QuestionMark
    | At
    | CharA
    | CharB
    | CharC
    | CharD
    | CharE
    | CharF
    | CharG
    | CharH
    | CharI
    | CharJ
    | CharK
    | CharL
    | CharM
    | CharN
    | CharO
    | CharP
    | CharQ
    | CharR
    | CharS
    | CharT
    | CharU
    | CharV
    | CharW
    | CharX
    | CharY
    | CharZ
    | Super
    | ContextMenu
    | Sleep
    | Numpad0
    | Numpad1
    | Numpad2
    | Numpad3
    | Numpad4
    | Numpad5
    | Numpad6
    | Numpad7
    | Numpad8
    | Numpad9
    | Multiply
    | Add
    | Separator
    | Subtract
    | Decimal
    | Divide
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12
    | F13
    | F14
    | F15
    | F16
    | F17
    | F18
    | F19
    | F20
    | F21
    | F22
    | F23
    | F24
    | NumLock
    | ScrollLock
    | Circumflex
    | Exclamation
    | DoubleQuote
    | Hash
    | Dollar
    | Percent
    | Ampersand
    | Underscore
    | OpenParen
    | CloseParen
    | Asterisk
    | Plus
    | Pipe
    | HyphenMinus
    | OpenCurlyBracket
    | CloseCurlyBracket
    | Tilde
    | VolumeMute
    | VolumeDown
    | VolumeUp
    | Comma
    | Minus
    | Period
    | Slash
    | BackQuote
    | OpenBracket
    | BackSlash
    | CloseBracket
    | Quote
    | Meta
    | Altgr
    | Other


codeDict : Dict KeyCode ( Key, Maybe String )
codeDict =
    Dict.fromList codeBook


codeBook : List ( KeyCode, ( Key, Maybe String ) )
codeBook =
    [ ( 3, ( Cancel, Nothing ) )
    , ( 6, ( Help, Nothing ) )
    , ( 8, ( BackSpace, Nothing ) )
    , ( 9, ( Tab, Nothing ) )
    , ( 12, ( Clear, Nothing ) )
    , ( 13, ( Enter, Nothing ) )
    , ( 16, ( Shift, Just "Shift" ) )
    , ( 17, ( Control, Just "Ctrl" ) )
    , ( 18, ( Alt, Just "Alt" ) )
    , ( 19, ( Pause, Nothing ) )
    , ( 20, ( CapsLock, Nothing ) )
    , ( 27, ( Escape, Just "Esc" ) )
    , ( 28, ( Convert, Nothing ) )
    , ( 29, ( NonConvert, Nothing ) )
    , ( 30, ( Accept, Nothing ) )
    , ( 31, ( ModeChange, Nothing ) )
    , ( 32, ( Space, Just "⎵" ) )
    , ( 33, ( PageUp, Nothing ) )
    , ( 34, ( PageDown, Nothing ) )
    , ( 35, ( End, Nothing ) )
    , ( 36, ( Home, Nothing ) )
    , ( 37, ( ArrowLeft, Just "⬅" ) )
    , ( 38, ( ArrowUp, Just "⬆" ) )
    , ( 39, ( ArrowRight, Just "➡" ) )
    , ( 40, ( ArrowDown, Just "⬇" ) )
    , ( 41, ( Select, Nothing ) )
    , ( 42, ( Print, Nothing ) )
    , ( 43, ( Execute, Nothing ) )
    , ( 44, ( PrintScreen, Nothing ) )
    , ( 45, ( Insert, Nothing ) )
    , ( 46, ( Delete, Nothing ) )
    , ( 48, ( Number0, Just "0" ) )
    , ( 49, ( Number1, Just "1" ) )
    , ( 50, ( Number2, Just "2" ) )
    , ( 51, ( Number3, Just "3" ) )
    , ( 52, ( Number4, Just "4" ) )
    , ( 53, ( Number5, Just "5" ) )
    , ( 54, ( Number6, Just "6" ) )
    , ( 55, ( Number7, Just "7" ) )
    , ( 56, ( Number8, Just "8" ) )
    , ( 57, ( Number9, Just "9" ) )
    , ( 58, ( Colon, Nothing ) )
    , ( 59, ( Semicolon, Nothing ) )
    , ( 60, ( LessThan, Nothing ) )
    , ( 61, ( Equals, Nothing ) )
    , ( 62, ( GreaterThan, Nothing ) )
    , ( 63, ( QuestionMark, Nothing ) )
    , ( 64, ( At, Nothing ) )
    , ( 65, ( CharA, Nothing ) )
    , ( 66, ( CharB, Nothing ) )
    , ( 67, ( CharC, Nothing ) )
    , ( 68, ( CharD, Nothing ) )
    , ( 69, ( CharE, Nothing ) )
    , ( 70, ( CharF, Nothing ) )
    , ( 71, ( CharG, Nothing ) )
    , ( 72, ( CharH, Nothing ) )
    , ( 73, ( CharI, Nothing ) )
    , ( 74, ( CharJ, Nothing ) )
    , ( 75, ( CharK, Nothing ) )
    , ( 76, ( CharL, Nothing ) )
    , ( 77, ( CharM, Nothing ) )
    , ( 78, ( CharN, Nothing ) )
    , ( 79, ( CharO, Nothing ) )
    , ( 80, ( CharP, Nothing ) )
    , ( 81, ( CharQ, Nothing ) )
    , ( 82, ( CharR, Nothing ) )
    , ( 83, ( CharS, Nothing ) )
    , ( 84, ( CharT, Nothing ) )
    , ( 85, ( CharU, Nothing ) )
    , ( 86, ( CharV, Nothing ) )
    , ( 87, ( CharW, Nothing ) )
    , ( 88, ( CharX, Nothing ) )
    , ( 89, ( CharY, Nothing ) )
    , ( 90, ( CharZ, Nothing ) )
    , ( 91, ( Super, Nothing ) )
    , ( 93, ( ContextMenu, Nothing ) )
    , ( 95, ( Sleep, Nothing ) )
    , ( 96, ( Numpad0, Nothing ) )
    , ( 97, ( Numpad1, Nothing ) )
    , ( 98, ( Numpad2, Nothing ) )
    , ( 99, ( Numpad3, Nothing ) )
    , ( 100, ( Numpad4, Nothing ) )
    , ( 101, ( Numpad5, Nothing ) )
    , ( 102, ( Numpad6, Nothing ) )
    , ( 103, ( Numpad7, Nothing ) )
    , ( 104, ( Numpad8, Nothing ) )
    , ( 105, ( Numpad9, Nothing ) )
    , ( 106, ( Multiply, Nothing ) )
    , ( 107, ( Add, Nothing ) )
    , ( 108, ( Separator, Nothing ) )
    , ( 109, ( Subtract, Nothing ) )
    , ( 110, ( Decimal, Nothing ) )
    , ( 111, ( Divide, Nothing ) )
    , ( 112, ( F1, Just "F1" ) )
    , ( 113, ( F2, Just "F2" ) )
    , ( 114, ( F3, Just "F3" ) )
    , ( 115, ( F4, Just "F4" ) )
    , ( 116, ( F5, Just "F5" ) )
    , ( 117, ( F6, Just "F6" ) )
    , ( 118, ( F7, Just "F7" ) )
    , ( 119, ( F8, Just "F8" ) )
    , ( 120, ( F9, Just "F9" ) )
    , ( 121, ( F10, Just "F10" ) )
    , ( 122, ( F11, Just "F11" ) )
    , ( 123, ( F12, Just "F12" ) )
    , ( 124, ( F13, Just "F13" ) )
    , ( 125, ( F14, Just "F14" ) )
    , ( 126, ( F15, Just "F15" ) )
    , ( 127, ( F16, Just "F16" ) )
    , ( 128, ( F17, Just "F17" ) )
    , ( 129, ( F18, Just "F18" ) )
    , ( 130, ( F19, Just "F19" ) )
    , ( 131, ( F20, Just "F20" ) )
    , ( 132, ( F21, Just "F21" ) )
    , ( 133, ( F22, Just "F22" ) )
    , ( 134, ( F23, Just "F23" ) )
    , ( 135, ( F24, Just "F24" ) )
    , ( 144, ( NumLock, Nothing ) )
    , ( 145, ( ScrollLock, Nothing ) )
    , ( 160, ( Circumflex, Nothing ) )
    , ( 161, ( Exclamation, Nothing ) )
    , ( 162, ( DoubleQuote, Nothing ) )
    , ( 163, ( Hash, Nothing ) )
    , ( 164, ( Dollar, Nothing ) )
    , ( 165, ( Percent, Nothing ) )
    , ( 166, ( Ampersand, Nothing ) )
    , ( 167, ( Underscore, Nothing ) )
    , ( 168, ( OpenParen, Nothing ) )
    , ( 169, ( CloseParen, Nothing ) )
    , ( 170, ( Asterisk, Nothing ) )
    , ( 171, ( Plus, Nothing ) )
    , ( 172, ( Pipe, Nothing ) )
    , ( 173, ( HyphenMinus, Nothing ) )
    , ( 174, ( OpenCurlyBracket, Nothing ) )
    , ( 175, ( CloseCurlyBracket, Nothing ) )
    , ( 176, ( Tilde, Nothing ) )
    , ( 181, ( VolumeMute, Nothing ) )
    , ( 182, ( VolumeDown, Nothing ) )
    , ( 183, ( VolumeUp, Nothing ) )
    , ( 186, ( Semicolon, Nothing ) )
    , ( 187, ( Equals, Nothing ) )
    , ( 188, ( Comma, Nothing ) )
    , ( 189, ( Minus, Nothing ) )
    , ( 190, ( Period, Nothing ) )
    , ( 191, ( Slash, Nothing ) )
    , ( 192, ( BackQuote, Nothing ) )
    , ( 219, ( OpenBracket, Nothing ) )
    , ( 220, ( BackSlash, Nothing ) )
    , ( 221, ( CloseBracket, Nothing ) )
    , ( 222, ( Quote, Nothing ) )
    , ( 224, ( Meta, Nothing ) )
    , ( 225, ( Altgr, Nothing ) )
    ]
