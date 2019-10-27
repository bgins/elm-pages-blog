module Palette exposing (blogHeading, color, heading)

import Element exposing (Element)
import Element.Font as Font
import Element.Region


color =
    { primary = Element.rgb255 143 25 47
    }


heading : Int -> List (Element msg) -> Element msg
heading level content =
    Element.paragraph
        ([ Font.bold
         , Font.family [ Font.typeface "Rosario" ]
         , Element.Region.heading level
         ]
            ++ (case level of
                    1 ->
                        [ Font.size 36 ]

                    2 ->
                        [ Font.size 28 ]

                    _ ->
                        [ Font.size 18 ]
               )
        )
        content


blogHeading : String -> Element msg
blogHeading title =
    heading 1 [ Element.text title ]
