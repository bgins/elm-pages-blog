module Index exposing (view)

import Data.Author
import Date
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Element msg
view posts =
    Element.column [ Element.paddingXY 0 0, Element.spacing 20 ]
        (posts
            |> List.filterMap
                (\( path, metadata ) ->
                    case metadata of
                        Metadata.Page meta ->
                            Nothing

                        Metadata.Author _ ->
                            Nothing

                        Metadata.Article meta ->
                            if meta.draft then
                                Nothing

                            else
                                Just ( path, meta )

                        Metadata.BlogIndex ->
                            Nothing
                )
            |> List.sortWith dateComparison
            |> List.map postSummary
        )


dateComparison :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Order
dateComparison a b =
    Date.compare (Tuple.second b |> .published) (Tuple.second a |> .published)


postSummary :
    ( PagePath Pages.PathKey, Metadata.ArticleMetadata )
    -> Element msg
postSummary ( postPath, post ) =
    articleIndex post
        |> linkToPost postPath


linkToPost : PagePath Pages.PathKey -> Element msg -> Element msg
linkToPost postPath content =
    Element.link
        [ Element.width Element.fill
        , Element.Background.color (Element.rgb255 255 255 255)
        ]
        { url = PagePath.toString postPath, label = content }


title : String -> Element msg
title text =
    [ Element.text text ]
        |> Element.paragraph
            [ Element.Font.size 36

            -- , Element.Font.center
            , Element.Font.family [ Element.Font.typeface "Galdeano" ]
            , Element.Font.semiBold

            -- , Element.padding 16
            ]


articleIndex : Metadata.ArticleMetadata -> Element msg
articleIndex metadata =
    Element.el
        [ Element.centerX
        , Element.width (Element.maximum 800 Element.fill)
        , Element.padding 10
        , Element.spacing 10
        , Element.Border.widthEach
            { bottom = 0
            , left = 4
            , right = 0
            , top = 0
            }
        , Element.Border.color (Element.rgba255 0 0 0 0)
        , Element.mouseOver
            [ Element.Border.color (Element.rgba255 143 25 47 0.75)
            ]
        ]
        (postPreview metadata)



-- readMoreLink =
--     Element.text "Continue reading >>"
--         |> Element.el
--             [ Element.centerX
--             , Element.Font.size 18
--             , Element.alpha 0.6
--             , Element.mouseOver [ Element.alpha 1 ]
--             , Element.Font.underline
--             , Element.Font.center
--             ]


postPreview : Metadata.ArticleMetadata -> Element msg
postPreview post =
    Element.textColumn
        [ Element.centerX
        , Element.width Element.fill
        , Element.Font.size 18
        , Element.spacing 7
        ]
        [ title post.title
        , Element.paragraph [ Element.Font.color (Element.rgba255 0 0 0 0.8) ] [ Element.text (post.published |> Date.format "MMMM ddd, yyyy") ]

        -- , Element.row [ Element.spacing 5, Element.centerX ]
        --     [ Element.text (post.published |> Date.format "MMMM ddd, yyyy")
        --     ]
        -- [ Data.Author.view [ Element.width (Element.px 40) ] post.author
        -- , Element.text post.author.name
        -- , Element.text "•"
        -- , Element.text (post.published |> Date.format "MMMM ddd, yyyy")
        -- ]
        -- , post.description
        --     |> Element.text
        --     |> List.singleton
        --     |> Element.paragraph
        --         [ Element.Font.size 22
        --         , Element.Font.center
        --         , Element.Font.family [ Element.Font.typeface "Gentium Basic" ]
        --         ]
        -- , readMoreLink
        ]
