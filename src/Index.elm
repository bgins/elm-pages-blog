module Index exposing (view)

import Date
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Metadata exposing (Metadata)
import Pages
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Palette


view :
    List ( PagePath Pages.PathKey, Metadata )
    -> Element msg
view posts =
    Element.column [ Element.spacing 10 ]
        (posts
            |> List.filterMap
                (\( path, metadata ) ->
                    case metadata of
                        Metadata.Page meta ->
                            Nothing

                        Metadata.Profile _ ->
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
        ]
        { url = PagePath.toString postPath, label = content }


articleIndex : Metadata.ArticleMetadata -> Element msg
articleIndex metadata =
    Element.el
        [ Element.width (Element.maximum 800 Element.fill)
        , Element.padding 10
        , Element.spacing 10
        , Element.centerX
        , Element.Border.widthEach
            { bottom = 0
            , left = 4
            , right = 0
            , top = 0
            }
        , Element.Border.color (Element.rgba255 255 255 255 0)
        , Element.mouseOver
            [ Element.Border.color (Element.rgba255 143 25 47 0.75)
            ]
        ]
        (postPreview metadata)


postPreview : Metadata.ArticleMetadata -> Element msg
postPreview post =
    Element.textColumn
        [ Element.width Element.fill
        , Element.centerX
        , Element.spacing 5
        ]
        [ Palette.heading 2 [ Element.text post.title ]
        , Element.paragraph
            [ Font.size 16, Font.color (Element.rgba255 0 0 0 0.7) ]
            [ Element.text (post.published |> Date.format "MMMM ddd, yyyy") ]
        ]
