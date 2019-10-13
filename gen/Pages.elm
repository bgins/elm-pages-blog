port module Pages exposing (PathKey, allPages, allImages, application, images, isValidRoute, pages)

import Color exposing (Color)
import Head
import Html exposing (Html)
import Json.Decode
import Json.Encode
import Mark
import Pages.Platform
import Pages.ContentCache exposing (Page)
import Pages.Manifest exposing (DisplayMode, Orientation)
import Pages.Manifest.Category as Category exposing (Category)
import Url.Parser as Url exposing ((</>), s)
import Pages.Document as Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Directory as Directory exposing (Directory)


type PathKey
    = PathKey


buildImage : List String -> ImagePath PathKey
buildImage path =
    ImagePath.build PathKey ("images" :: path)



buildPage : List String -> PagePath PathKey
buildPage path =
    PagePath.build PathKey path


directoryWithIndex : List String -> Directory PathKey Directory.WithIndex
directoryWithIndex path =
    Directory.withIndex PathKey allPages path


directoryWithoutIndex : List String -> Directory PathKey Directory.WithoutIndex
directoryWithoutIndex path =
    Directory.withoutIndex PathKey allPages path


port toJsPort : Json.Encode.Value -> Cmd msg


application :
    { init : ( userModel, Cmd userMsg )
    , update : userMsg -> userModel -> ( userModel, Cmd userMsg )
    , subscriptions : userModel -> Sub userMsg
    , view : userModel -> List ( PagePath PathKey, metadata ) -> Page metadata view PathKey -> { title : String, body : Html userMsg }
    , head : metadata -> List (Head.Tag PathKey)
    , documents : List ( String, Document.DocumentHandler metadata view )
    , manifest : Pages.Manifest.Config PathKey
    , canonicalSiteUrl : String
    }
    -> Pages.Platform.Program userModel userMsg metadata view
application config =
    Pages.Platform.application
        { init = config.init
        , view = config.view
        , update = config.update
        , subscriptions = config.subscriptions
        , document = Document.fromList config.documents
        , content = content
        , toJsPort = toJsPort
        , head = config.head
        , manifest = config.manifest
        , canonicalSiteUrl = config.canonicalSiteUrl
        , pathKey = PathKey
        }



allPages : List (PagePath PathKey)
allPages =
    [ (buildPage [ "about" ])
    , (buildPage [  ])
    , (buildPage [ "posts", "hebdomad" ])
    , (buildPage [ "posts" ])
    , (buildPage [ "posts", "mergesort" ])
    , (buildPage [ "posts", "minima-talk" ])
    , (buildPage [ "posts", "minima" ])
    , (buildPage [ "posts", "moonflask" ])
    , (buildPage [ "posts", "nginlog" ])
    , (buildPage [ "posts", "two-years" ])
    ]

pages =
    { about = (buildPage [ "about" ])
    , index = (buildPage [  ])
    , posts =
        { hebdomad = (buildPage [ "posts", "hebdomad" ])
        , index = (buildPage [ "posts" ])
        , mergesort = (buildPage [ "posts", "mergesort" ])
        , minimaTalk = (buildPage [ "posts", "minima-talk" ])
        , minima = (buildPage [ "posts", "minima" ])
        , moonflask = (buildPage [ "posts", "moonflask" ])
        , nginlog = (buildPage [ "posts", "nginlog" ])
        , twoYears = (buildPage [ "posts", "two-years" ])
        , directory = directoryWithIndex ["posts"]
        }
    , directory = directoryWithIndex []
    }

images =
    { articleCovers =
        { canyonDeChelly = (buildImage [ "article-covers", "canyon-de-chelly.jpg" ])
        , hebdomad = (buildImage [ "article-covers", "hebdomad.png" ])
        , hello = (buildImage [ "article-covers", "hello.jpg" ])
        , map = (buildImage [ "article-covers", "map.png" ])
        , minima = (buildImage [ "article-covers", "minima.png" ])
        , moonflask = (buildImage [ "article-covers", "moonflask.jpg" ])
        , mountains = (buildImage [ "article-covers", "mountains.jpg" ])
        , directory = directoryWithoutIndex ["articleCovers"]
        }
    , author =
        { bg = (buildImage [ "author", "bg.png" ])
        , directory = directoryWithoutIndex ["author"]
        }
    , blog =
        { donuts = (buildImage [ "blog", "donuts.png" ])
        , responsive = (buildImage [ "blog", "responsive.png" ])
        , directory = directoryWithoutIndex ["blog"]
        }
    , elmLogo = (buildImage [ "elm-logo.svg" ])
    , github = (buildImage [ "github.svg" ])
    , iconPng = (buildImage [ "icon-png.png" ])
    , icon = (buildImage [ "icon.svg" ])
    , lightWool = (buildImage [ "light-wool.png" ])
    , directory = directoryWithoutIndex []
    }

allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "article-covers", "canyon-de-chelly.jpg" ])
    , (buildImage [ "article-covers", "hebdomad.png" ])
    , (buildImage [ "article-covers", "hello.jpg" ])
    , (buildImage [ "article-covers", "map.png" ])
    , (buildImage [ "article-covers", "minima.png" ])
    , (buildImage [ "article-covers", "moonflask.jpg" ])
    , (buildImage [ "article-covers", "mountains.jpg" ])
    , (buildImage [ "author", "bg.png" ])
    , (buildImage [ "blog", "donuts.png" ])
    , (buildImage [ "blog", "responsive.png" ])
    , (buildImage [ "elm-logo.svg" ])
    , (buildImage [ "github.svg" ])
    , (buildImage [ "icon-png.png" ])
    , (buildImage [ "icon.svg" ])
    , (buildImage [ "light-wool.png" ])
    ]


isValidRoute : String -> Result String ()
isValidRoute route =
    let
        validRoutes =
            List.map PagePath.toString allPages
    in
    if
        (route |> String.startsWith "http://")
            || (route |> String.startsWith "https://")
            || (route |> String.startsWith "#")
            || (validRoutes |> List.member route)
    then
        Ok ()

    else
        ("Valid routes:\n"
            ++ String.join "\n\n" validRoutes
        )
            |> Err


content : List ( List String, { extension: String, frontMatter : String, body : Maybe String } )
content =
    [ 
  ( ["about"]
    , { frontMatter = """{"title":"about","type":"page"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( []
    , { frontMatter = """{"title":"elm-pages blog","type":"blog-index"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "hebdomad"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Hebdomad","description":"Hebdomad is a xenharmonic web audio synthesizer","image":"/images/article-covers/hebdomad.png","draft":false,"published":"2017-01-03"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts"]
    , { frontMatter = """{"title":"elm-pages blog","type":"blog-index"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "mergesort"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Haskell Merge Sort","description":"Haskell merge sort is fun and easy","image":"/images/article-covers/canyon-de-chelly.jpg","image-attribution":"Kelsie DiPerna","draft":false,"published":"2017-09-11"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "minima-talk"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Speaking on minima","description":"Preseting Minima at the Functional Programming Study Group","image":"/images/article-covers/minima.png","draft":false,"published":"2017-09-30"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "minima"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"minima","description":"Minima is a minimalist web audio playground","image":"/images/article-covers/minima.png","draft":false,"published":"2017-06-20"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "moonflask"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Moon Flask","description":"Moon Flask was my first web project","image":"/images/article-covers/moonflask.jpg","draft":false,"published":"2015-12-19"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "nginlog"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"nginlog","description":"nginlog is an nginx traffic analysis tool","image":"/images/article-covers/map.png","draft":false,"published":"2017-09-09"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "two-years"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Two years in summary","description":"Much has happened over the last two years","image":"/images/article-covers/map.png","draft":true,"published":"2019-10-13"}
""" , body = Nothing
    , extension = "md"
    } )
  
    ]
