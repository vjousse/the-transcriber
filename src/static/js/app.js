// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
require( '../css/theme/bootstrap/dist/css/bootstrap.css' );
require( '../css/theme/styles/app.css' );
require( '../css/theme/styles/font.css' );
require( '../css/fonts/font-awesome.css' );
require( '../css/fonts/material-design-icons.css' );
require( '../css/app.css' );

import {SpeakerTurnEditor} from './editor';


// ELM
var Elm = require( '../../elm/Main' );
const elmDiv = document.querySelector('#elm-target');

let appState = {};
appState.turns = {};
appState.turns.currentTurn = -1;
appState.turns.speakerTurns = [];


if (elmDiv) {

  var app = Elm.Main.embed(elmDiv, {
      //mediaUrl: "http://localhost/lcp_q_gov.mp3"
      mediaUrl: "http://localhost/resumemo.mp3"
    , mediaType: "audio/mp3"
  });

  let speakerTurnEditor = new SpeakerTurnEditor(
    app
    , (newState) => {
      //Merge new state into old one
      for (var attrname in newState) { appState.turns[attrname] = newState[attrname]; }
    }
  );

}
