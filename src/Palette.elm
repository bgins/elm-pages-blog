module Palette exposing (blogHeading, color, heading)

import Element exposing (Element)
import Element.Font as Font
import Element.Region


color =
    { primary = Element.rgb255 143 25 47
    , secondary = Element.rgb255 0 242 96
    }


heading : Int -> List (Element msg) -> Element msg
heading level content =
    Element.paragraph
        ([ Font.bold
         , Font.family [ Font.typeface "Galdeano" ]
         , Element.Region.heading level
         ]
            ++ (case level of
                    1 ->
                        [ Font.size 36 ]

                    2 ->
                        [ Font.size 24 ]

                    _ ->
                        [ Font.size 20 ]
               )
        )
        content


blogHeading : String -> Element msg
blogHeading title =
    Element.paragraph
        [ Font.bold
        , Font.family [ Font.typeface "Galdeano" ]
        , Element.Region.heading 1
        , Font.size 40

        -- , Font.center
        ]
        [ Element.text title ]
