module Translation.Utils
    exposing
        ( Language(..)
        , TranslationId(..)
        , translate
        )


type alias TranslationSet =
    { english : String
    , french : String
    }


type TranslationId
    = Dashboard
    | Duration
    | ExportTo String
    | Home
    | File { name : String }
    | LastSave String
    | NoSave
    | Save
    | Speakers
    | Words


type Language
    = English
    | French


translate : Language -> TranslationId -> String
translate lang trans =
    let
        translationSet =
            case trans of
                Dashboard ->
                    { english = "Dashboard", french = "Tableau de bord" }

                Duration ->
                    { english = "Duration", french = "Durée" }

                ExportTo val ->
                    { english = ("Export to " ++ val), french = ("Exporter en " ++ val) }

                File val ->
                    { english = ("File: " ++ val.name), french = ("Fichier : " ++ val.name) }

                Home ->
                    { english = "Home", french = "Accueil" }

                LastSave time ->
                    { english = ("Last save: " ++ time ++ " ago")
                    , french = ("Dernière sauvegarde il y a : " ++ time)
                    }

                NoSave ->
                    { english = ("Last save: -")
                    , french = ("Dernière sauvegarde : -")
                    }

                Save ->
                    { english = "Save", french = "Sauvegarder" }

                Speakers ->
                    { english = "Speakers", french = "Locuteurs" }

                Words ->
                    { english = "Words", french = "Mots" }
    in
        case lang of
            English ->
                .english translationSet

            French ->
                .french translationSet
