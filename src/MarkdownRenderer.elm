module MarkdownRenderer exposing (view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes
import Json.Encode as Encode
import Markdown.Block exposing (HeadingLevel(..))
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import Oembed
import Palette


view : String -> Result String (Element msg)
view markdown =
    case
        markdown
            |> Markdown.Parser.parse
    of
        Ok okAst ->
            case Markdown.Renderer.render renderer okAst of
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


renderer : Markdown.Renderer.Renderer (Element msg)
renderer =
    { heading = heading
    , paragraph = paragraph []
    , hardLineBreak = html <| Html.br [] []
    , blockQuote =
        paragraph
            [ Border.widthEach { top = 0, right = 0, bottom = 0, left = 4 }
            , padding 10
            , Border.color Palette.color.primary
            , Background.color (rgb255 251 249 249)
            ]
    , strong =
        \children ->
            paragraph
                [ Font.bold
                , htmlAttribute
                    (Html.Attributes.style "display" "inline-block")
                ]
                children
    , emphasis =
        \children ->
            paragraph
                [ Font.italic
                , htmlAttribute
                    (Html.Attributes.style "display" "inline-block")
                ]
                children
    , strikethrough =
        \children ->
            paragraph
                [ Font.strike
                , htmlAttribute
                    (Html.Attributes.style "display" "inline-block")
                ]
                children
    , codeSpan = codeSpan
    , link =
        \link content ->
            newTabLink
                [ htmlAttribute (Html.Attributes.style "display" "inline-flex")
                ]
                { url = link.destination
                , label =
                    paragraph
                        [ Font.color Palette.color.primary
                        , htmlAttribute (Html.Attributes.attribute "class" "markdown-link")
                        ]
                        content
                }
    , image =
        \imageInfo ->
            image [ width fill ] { src = imageInfo.src, description = imageInfo.alt }
    , text = text
    , unorderedList =
        \items ->
            column [ spacing 10 ]
                (items
                    |> List.map
                        (\item ->
                            case item of
                                Markdown.Block.ListItem task children ->
                                    row [ spacing 7, paddingXY 15 0 ]
                                        [ el
                                            [ alignTop ]
                                            (text "•")
                                        , paragraph [] children
                                        ]
                        )
                )
    , orderedList =
        \startingIndex items ->
            column [ spacing 10 ]
                (items
                    |> List.indexedMap
                        (\index children ->
                            row [ spacing 7, paddingXY 15 0 ]
                                [ el [ alignTop ]
                                    (text (String.fromInt (index + startingIndex) ++ "."))
                                , paragraph [] children
                                ]
                        )
                )
    , html =
        Markdown.Html.oneOf
            [ Markdown.Html.tag "oembed"
                (\url children ->
                    Oembed.view [] Nothing url
                        |> Maybe.map html
                        |> Maybe.withDefault none
                        |> el [ centerX ]
                )
                |> Markdown.Html.withAttribute "url"
            , Markdown.Html.tag "certificate-row"
                (\children ->
                    row [ paddingXY 15 0 ] (children |> List.reverse)
                )
            , Markdown.Html.tag "link"
                (\url children ->
                    newTabLink []
                        { url = url
                        , label =
                            column [] children
                        }
                )
                |> Markdown.Html.withAttribute "url"
            ]
    , codeBlock = codeBlock
    , thematicBreak =
        paragraph
            [ width fill, paddingXY 0 20 ]
            [ html <|
                Html.hr
                    [ Html.Attributes.style "border-top" "1px solid #d1c7c7" ]
                    []
            ]
    , table = paragraph []
    , tableHeader = paragraph []
    , tableBody = paragraph []
    , tableRow = paragraph []
    , tableHeaderCell = \maybeAlignment attrs -> none
    , tableCell = \maybeAlignment attrs -> none
    }


rawTextToId rawText =
    rawText
        |> String.toLower
        |> String.replace " " ""


heading : { level : HeadingLevel, rawText : String, children : List (Element msg) } -> Element msg
heading { level, rawText, children } =
    paragraph
        [ Region.heading (Markdown.Block.headingLevelToInt level)
        , htmlAttribute
            (Html.Attributes.attribute "name" (rawTextToId rawText))
        , htmlAttribute
            (Html.Attributes.id (rawTextToId rawText))
        , paddingEach
            { top = 10
            , right = 0
            , bottom = 0
            , left = 0
            }
        , Font.size
            (case level of
                H1 ->
                    36

                H2 ->
                    28

                H3 ->
                    24

                _ ->
                    18
            )
        , Font.family [ Font.typeface "Rosario" ]
        , Font.bold
        ]
        children


codeSpan : String -> Element msg
codeSpan snippet =
    el
        [ padding 3
        , Font.family [ Font.typeface "Cousine" ]
        , Font.size 18
        , Background.color (rgb255 251 249 249)
        ]
        (text snippet)


codeBlock : { body : String, language : Maybe String } -> Element msg
codeBlock details =
    Html.node "code-editor"
        [ editorValue details.body
        , Maybe.withDefault "elm" details.language
            |> editorLanguage
        , Html.Attributes.style "white-space" "normal"
        ]
        []
        |> html
        |> el
            [ width fill
            ]


editorValue : String -> Html.Attribute msg
editorValue value =
    value
        |> String.trim
        |> Encode.string
        |> Html.Attributes.property "editorValue"


editorLanguage : String -> Html.Attribute msg
editorLanguage value =
    value
        |> String.trim
        |> Encode.string
        |> Html.Attributes.property "editorLanguage"
