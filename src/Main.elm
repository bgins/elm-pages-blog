module Main exposing (main)

import Color
import Data.Author as Author
import Date
import DocumentSvg
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Region
import Head
import Head.Seo as Seo
import Html exposing (Html)
import Html.Attributes as Attr
import Index
import Json.Decode
import Markdown
import MarkdownRenderer exposing (..)
import Metadata exposing (Metadata)
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Palette


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.social, Pages.Manifest.Category.business ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "Brian Ginsburg's Blog"
    , iarcRatingId = Nothing
    , name = "Brian Ginsburg"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Just "Brian Ginsburg"
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Element Msg


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents = [ markdownDocument ]
        , head = head
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        }


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body = MarkdownRenderer.view
        }


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( Model, Cmd.none )


type alias Msg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        () ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Html Msg }
view model siteMetadata page =
    let
        { title, body } =
            pageView model siteMetadata page
    in
    { title = title
    , body =
        body
            |> Element.layout
                [ Element.width Element.fill
                , Element.height Element.fill
                , Element.Background.color (Element.rgb255 255 254 254)
                , Element.behindContent
                    (Element.column
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        , Element.Background.tiled "/images/light-wool.png"
                        ]
                        []
                    )
                , Font.size 18
                , Font.family [ Font.typeface "Lato" ]
                , Font.color (Element.rgba255 0 0 0 0.8)
                ]
    }


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> Page Metadata Rendered Pages.PathKey -> { title : String, body : Element Msg }
pageView model siteMetadata page =
    case page.metadata of
        Metadata.Page metadata ->
            { title = metadata.title
            , body =
                Element.column [ Element.width Element.fill, Element.height Element.fill ]
                    [ header page.path
                    , Element.column
                        [ Element.height Element.fill
                        , Element.paddingXY 30 40
                        , Element.spacing 20
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        , Element.Background.color (Element.rgb255 255 255 255)
                        ]
                        [ Element.paragraph
                            []
                            [ Palette.heading 1 [ Element.text metadata.title ] ]
                        , page.view
                        ]

                    -- [ if PagePath.toString page.path == "/" then
                    -- [ if page.path == Pages.pages.index then
                    --     Index.view siteMetadata
                    --   else
                    --     page.view
                    -- ]
                    ]
            }

        Metadata.Article metadata ->
            { title = metadata.title
            , body =
                Element.column [ Element.width Element.fill, Element.height Element.fill ]
                    [ header page.path
                    , Element.column
                        [ Element.height Element.fill
                        , Element.paddingXY 30 40
                        , Element.spacing 20
                        , Element.Region.mainContent
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        , Element.Background.color (Element.rgb255 255 255 255)
                        ]
                        (Element.column []
                            [ Element.column
                                [ Element.spacing 25
                                ]
                                [ Element.column [ Element.spacing 10 ]
                                    [ Palette.blogHeading metadata.title
                                    , publishedDateView metadata
                                        |> Element.el [ Font.size 16, Font.color (Element.rgba255 0 0 0 0.6) ]
                                    ]
                                , articleImageView metadata.image metadata.imageAttribution
                                ]
                            ]
                            :: [ page.view ]
                        )
                    ]
            }

        Metadata.Author author ->
            { title = author.name
            , body =
                Element.column
                    [ Element.width Element.fill
                    ]
                    [ header page.path
                    , Element.column
                        [ Element.Region.mainContent
                        , Element.padding 30
                        , Element.spacing 20
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        ]
                        [ Palette.blogHeading author.name
                        , Author.view [] author
                        , Element.paragraph [ Element.centerX, Font.center ] [ page.view ]
                        ]
                    ]
            }

        Metadata.BlogIndex ->
            { title = "Blog"
            , body =
                Element.column [ Element.width Element.fill, Element.height Element.fill ]
                    [ header page.path
                    , Element.column
                        [ Element.Region.mainContent
                        , Element.paddingXY 30 40
                        , Element.spacing 20
                        , Element.width (Element.fill |> Element.maximum 800)
                        , Element.centerX
                        , Element.Background.color (Element.rgb255 255 255 255)
                        ]
                        [ Element.paragraph
                            [ Element.paddingXY 14 0 ]
                            [ Palette.heading 1 [ Element.text "Blog" ] ]
                        , Index.view siteMetadata
                        ]
                    ]
            }


articleImageView : ImagePath Pages.PathKey -> Maybe String -> Element msg
articleImageView articleImage imageAttribution =
    Element.column [ Element.spacing 7 ]
        [ Element.image [ Element.width Element.fill ]
            { src = ImagePath.toString articleImage
            , description = "Blog post cover photo"
            }
        , case imageAttribution of
            Just attribution ->
                Element.row
                    [ Font.size 16
                    , Font.italic
                    , Font.color (Element.rgba 0 0 0 0.5)
                    ]
                    [ Element.text ("Image by " ++ attribution)
                    ]

            Nothing ->
                Element.none
        ]


header : PagePath Pages.PathKey -> Element msg
header currentPath =
    Element.column [ Element.width Element.fill ]
        [ Element.el
            [ Element.height (Element.px 4)
            , Element.width Element.fill
            , Element.Background.color Palette.color.primary
            ]
            Element.none
        , Element.row
            [ Element.Region.navigation
            , Element.width Element.fill
            , Element.paddingXY 25 20
            , Element.spaceEvenly
            , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Element.Border.color (Element.rgba255 40 60 40 0.3)
            , Font.family [ Font.typeface "Rosario" ]
            ]
            [ Element.link []
                { url = PagePath.toString pages.index
                , label =
                    Element.row [ Font.size 28 ]
                        [ Element.text "Syntactic Overdrive"
                        ]
                }
            , Element.row [ Element.spacing 15 ]
                [ pageLink pages.index "Blog"
                , pageLink pages.about "About"
                ]
            ]
        ]


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    case metadata of
        Metadata.Page meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "Syntactic Overdrive"
                , image =
                    { url = images.iconPng
                    , alt = "BG logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.website

        Metadata.Article meta ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "Syntactic Overdrive"
                , image =
                    { url = meta.image
                    , alt = meta.description
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.description
                , locale = Nothing
                , title = meta.title
                }
                |> Seo.article
                    { tags = []
                    , section = Nothing
                    , publishedTime = Just (Date.toIsoString meta.published)
                    , modifiedTime = Nothing
                    , expirationTime = Nothing
                    }

        Metadata.Author meta ->
            let
                ( firstName, lastName ) =
                    case meta.name |> String.split " " of
                        [ first, last ] ->
                            ( first, last )

                        [ first, middle, last ] ->
                            ( first ++ " " ++ middle, last )

                        [] ->
                            ( "", "" )

                        _ ->
                            ( meta.name, "" )
            in
            Seo.summary
                { canonicalUrlOverride = Nothing
                , siteName = "Syntactic Overdrive"
                , image =
                    { url = meta.avatar
                    , alt = meta.name ++ "'s articles."
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = meta.bio
                , locale = Nothing
                , title = meta.name ++ "'s articles."
                }
                |> Seo.profile
                    { firstName = firstName
                    , lastName = lastName
                    , username = Nothing
                    }

        Metadata.BlogIndex ->
            Seo.summaryLarge
                { canonicalUrlOverride = Nothing
                , siteName = "Syntactic Overdrive"
                , image =
                    { url = images.iconPng
                    , alt = "BG logo"
                    , dimensions = Nothing
                    , mimeType = Nothing
                    }
                , description = siteTagline
                , locale = Nothing
                , title = "Blog"
                }
                |> Seo.website


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://brianginsburg.com/"


siteTagline : String
siteTagline =
    "A blog about progamming and music"


publishedDateView metadata =
    Element.text
        (metadata.published
            |> Date.format "MMMM ddd, yyyy"
        )


pageLink : PagePath Pages.PathKey -> String -> Element msg
pageLink path label =
    Element.link []
        { url = PagePath.toString path
        , label = Element.text label
        }
