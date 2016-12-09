# The transcriber

Open source transcribing tool. Respects the privacy of your data, can be plugged to many external tools.


# Installation

## Javascript

AHAH, you thought you wouldn't need any javascript stuff. You're screwed.

    npm install


## Hack to use the unpublished Dom.Size module

Install dependencies by running `elm make src/elm/Main.elm`. It should start downloading dependencies and then complain about `Dom.Size` module.

    I cannot find module 'Dom.Size'.

    Module 'Main' is trying to import it.

Open the `elm-stuff/packages/elm-lang/dom/1.1.1/elm-package.json` file and change

```elm
    "exposed-modules": [
        "Dom",
        "Dom.Scroll",
        "Dom.LowLevel"
    ],
```

to

```elm
    "exposed-modules": [
        "Dom",
        "Dom.Scroll",
        "Dom.LowLevel",
        "Dom.Size"
    ],
```

Then open `elm-stuff/packages/elm-lang/dom/1.1.0/src/Dom/Size.elm` and change the first line from :

```elm
module Dom.Size exposing (height, width, Boundary)
```

to

```elm
module Dom.Size exposing (height, width, Boundary(..))
```

Then, the code should compile just fine.

## Compile and run

    npm start

Open [http://localhost:8080/](http://localhost:8080/) in your browser and enjoy.
