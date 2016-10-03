'use strict';

var _editor = require('./editor');

var _main = require('./main');

var _main2 = _interopRequireDefault(_main);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

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

var elmDiv = document.querySelector('#elm-target');

// ELM


var appState = {};
appState.turns = {};
appState.turns.currentTurn = -1;
appState.turns.speakerTurns = [];

if (elmDiv) {
  var app;

  (function () {
    app = _main2.default.Main.embed(elmDiv, {
      //mediaUrl: "http://localhost/lcp_q_gov.mp3"
      mediaUrl: "http://localhost/resumemo.mp3",
      mediaType: "audio/mp3"
    });


    var speakerTurnEditor = new _editor.SpeakerTurnEditor(app, function (newState) {
      //Merge new state into old one
      for (var attrname in newState) {
        appState.turns[attrname] = newState[attrname];
      }
    });

    app.ports.setCurrentTime.subscribe(function (time) {
      var audio = document.getElementById('audio-player');
      console.log("Time: " + time, audio);

      audio.currentTime = time;
    });

    app.ports.setPlaybackRate.subscribe(function (rate) {
      var audio = document.getElementById('audio-player');
      console.log("Rate: " + rate, audio);

      audio.playbackRate = rate;
    });

    app.ports.play.subscribe(function () {
      var audio = document.getElementById('audio-player');
      console.log("Play: ", audio);

      audio.play();
    });

    app.ports.pause.subscribe(function () {
      var audio = document.getElementById('audio-player');
      console.log("Pause: ", audio);

      audio.pause();
    });

    app.ports.sendCurrentTime.subscribe(function (timestamp) {
      speakerTurnEditor.highlightWord(appState.turns, timestamp);
    });

    app.ports.sendSpeakerTurn.subscribe(function (_ref) {
      var index = _ref.index;
      var speakerTurn = _ref.speakerTurn;

      console.log(speakerTurn);
      speakerTurnEditor.loadSpeaker(appState.turns, index, speakerTurn);

      app.ports.reactOk.send(null);
    });
  })();
}