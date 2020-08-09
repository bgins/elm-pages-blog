module MarkdownRenderer exposing (view)

import Element exposing (Element)
import Element.Font as Font
import Element.Region
import Html exposing (Attribute)
import Html.Attributes exposing (property)
import Json.Encode as Encode
import Markdown.Html
import Markdown.Parser
import Oembed
import Palette


view : String -> Result String (Element msg)
view markdown =
    case
        markdown
            |> Markdown.Parser.parse
    of
        Ok okAst ->
            case Markdown.Parser.render renderer okAst of
                Ok rendered ->
                    Element.column
                        [ Element.spacing 20
                        , Element.htmlAttribute (Html.Attributes.attribute "id" "markdown-content")
                        ]
                        rendered
                        |> Ok

                Err errors ->
                    Err errors

        Err error ->
            Err (error |> List.map Markdown.Parser.deadEndToString |> String.join "\n")


renderer : Markdown.Parser.Renderer (Element msg)
renderer =
    { heading = heading
    , raw =
        Element.paragraph
            []
    , thematicBreak = Element.none
    , plain = Element.text
    , bold = \content -> Element.el [ Font.bold ] (Element.text content)
    , italic = \content -> Element.el [ Font.italic ] (Element.text content)
    , code = code
    , link =
        \link body ->
            -- Pages.isValidRoute link.destination
            --     |> Result.map
            --         (\() ->
            Element.newTabLink
                [ Element.htmlAttribute (Html.Attributes.style "display" "inline-flex")
                ]
                { url = link.destination
                , label =
                    Element.paragraph
                        [ Font.color Palette.color.primary
                        , Element.htmlAttribute (Html.Attributes.attribute "class" "markdown-link")
                        ]
                        body
                }
                |> Ok

    -- )
    , image =
        \image body ->
            -- Pages.isValidRoute image.src
            --     |> Result.map
            -- (\() ->
            Element.image [ Element.width Element.fill ] { src = image.src, description = body }
                |> Ok

    -- )
    , list =
        \items ->
            Element.column [ Element.spacing 10 ]
                (items
                    |> List.map
                        (\itemBlocks ->
                            Element.row [ Element.spacing 7, Element.paddingXY 15 0 ]
                                [ Element.el
                                    [ Element.alignTop ]
                                    (Element.text "•")
                                , itemBlocks
                                ]
                        )
                )
    , codeBlock = codeBlock
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "Oembed"
                (\url children ->
                    Oembed.view [] Nothing url
                        |> Maybe.map Element.html
                        |> Maybe.withDefault Element.none
                        |> Element.el [ Element.centerX ]
                )
                |> Markdown.Html.withAttribute "url"
            , Markdown.Html.tag "CertificateRow"
                (\children ->
                    Element.row [ Element.paddingXY 15 0 ] (children |> List.reverse)
                )
            , Markdown.Html.tag "Link"
                (\url children ->
                    Element.newTabLink []
                        { url = url
                        , label =
                            Element.column [] children
                        }
                )
                |> Markdown.Html.withAttribute "url"
            ]
    }


rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " ""


heading : { level : Int, rawText : String, children : List (Element msg) } -> Element msg
heading { level, rawText, children } =
    Element.paragraph
        [ Element.Region.heading level
        , Element.htmlAttribute
            (Html.Attributes.attribute "name" (rawTextToId rawText))
        , Element.htmlAttribute
            (Html.Attributes.id (rawTextToId rawText))
        , Element.paddingEach
            { top = 10
            , right = 0
            , bottom = 0
            , left = 0
            }
        , Font.size
            (case level of
                1 ->
                    36

                2 ->
                    28

                _ ->
                    18
            )
        , Font.family [ Font.typeface "Rosario" ]
        , Font.bold
        ]
        children


code : String -> Element msg
code snippet =
    Element.el
        [ Font.family [ Font.typeface "Cousine" ]
        , Font.size 18
        ]
        (Element.text snippet)


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock details =
    Html.node "code-editor"
        [ editorValue details.body
        , Maybe.withDefault "elm" details.language
            |> editorLanguage
        , Html.Attributes.style "white-space" "normal"
        ]
        []
        |> Element.html
        |> Element.el
            [ Element.width Element.fill
            ]


editorValue : String -> Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorValue"


editorLanguage : String -> Attribute msg
editorLanguage value =
    value
        |> String.trim
        |> Encode.string
        |> property "editorLanguage"
