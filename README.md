# the-transcriber
Open source transcribing tool. Respects the privacy of your data, can be plugged to many external tools.


# Installation

## Javascript

AHAH, you thought you wouldn't need any javascript stuff. You're screwed.

    npm install --save-dev babel-cli babel-preset-latest


## Hack to use the unpublished Dom.Size module

Go to `src/` directory and install dependencies by running `elm make Main.elm`. It should start downloading dependencies and the complain about `Dom.Size` module.

    I cannot find module 'Dom.Size'.

    Module 'Main' is trying to import it.

Inside the `src/` folder, open the `elm-stuff/packages/elm-lang/dom/1.1.0/elm-package.json` file and change

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

## Compile

Go to `src/` dir and then compile using:

    elm make Main.elm --output=../public/elm.js

## Run

Compile and then open `public/index.html`

## Elm live

Go to `src/` directory and then launch:

    elm-live Main.elm --dir=../public/ --output=../public/js/elm.js

Now, open your browser to [http://localhost:8000/](http://localhost:8000/).
