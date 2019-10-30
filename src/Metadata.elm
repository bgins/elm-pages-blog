module Metadata exposing (ArticleMetadata, Metadata(..), PageMetadata, decoder)

import Data.Author
import Date exposing (Date)
import Dict exposing (Dict)
import Element exposing (Element)
import Json.Decode as Decode exposing (Decoder)
import List.Extra
import Pages
import Pages.ImagePath as ImagePath exposing (ImagePath)


type Metadata
    = Page PageMetadata
    | Article ArticleMetadata
    | Profile ProfileMetadata
    | BlogIndex


type alias PageMetadata =
    { title : String }


type alias ArticleMetadata =
    { title : String
    , description : String
    , published : Date
    , author : Data.Author.Author
    , image : ImagePath Pages.PathKey
    , imageAttribution : Maybe String
    , draft : Bool
    }


type alias ProfileMetadata =
    { title : String
    , name : String
    , avatar : ImagePath Pages.PathKey
    , bio : String
    }


decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\pageType ->
                case pageType of
                    "page" ->
                        Decode.field "title" Decode.string
                            |> Decode.map (\title -> Page { title = title })

                    "blog-index" ->
                        Decode.succeed BlogIndex

                    "profile" ->
                        Decode.map4 ProfileMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "name" Decode.string)
                            (Decode.field "avatar" imageDecoder)
                            (Decode.field "bio" Decode.string)
                            |> Decode.map Profile

                    "blog" ->
                        Decode.map7 ArticleMetadata
                            (Decode.field "title" Decode.string)
                            (Decode.field "description" Decode.string)
                            (Decode.field "published"
                                (Decode.string
                                    |> Decode.andThen
                                        (\isoString ->
                                            case Date.fromIsoString isoString of
                                                Ok date ->
                                                    Decode.succeed date

                                                Err error ->
                                                    Decode.fail error
                                        )
                                )
                            )
                            (Decode.field "author" Data.Author.decoder)
                            (Decode.field "image" imageDecoder)
                            (Decode.field "image-attribution" Decode.string
                                |> Decode.maybe
                            )
                            (Decode.field "draft" Decode.bool
                                |> Decode.maybe
                                |> Decode.map (Maybe.withDefault False)
                            )
                            |> Decode.map Article

                    _ ->
                        Decode.fail <| "Unexpected page type " ++ pageType
            )


imageDecoder : Decoder (ImagePath Pages.PathKey)
imageDecoder =
    Decode.string
        |> Decode.andThen
            (\imageAssetPath ->
                case findMatchingImage imageAssetPath of
                    Nothing ->
                        Decode.fail "Couldn't find image."

                    Just imagePath ->
                        Decode.succeed imagePath
            )


findMatchingImage : String -> Maybe (ImagePath Pages.PathKey)
findMatchingImage imageAssetPath =
    Pages.allImages
        |> List.Extra.find
            (\image ->
                ImagePath.toString image
                    == imageAssetPath
            )
