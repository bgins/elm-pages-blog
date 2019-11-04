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
    , (buildPage [ "hebdomad" ])
    , (buildPage [  ])
    , (buildPage [ "minima" ])
    , (buildPage [ "moon-forge" ])
    , (buildPage [ "posts", "hebdomad" ])
    , (buildPage [ "posts" ])
    , (buildPage [ "posts", "mergesort" ])
    , (buildPage [ "posts", "minima-talk" ])
    , (buildPage [ "posts", "minima" ])
    , (buildPage [ "posts", "moonflask" ])
    , (buildPage [ "posts", "nginlog" ])
    , (buildPage [ "posts", "s3-static-pt1" ])
    ]

pages =
    { about = (buildPage [ "about" ])
    , hebdomad = (buildPage [ "hebdomad" ])
    , index = (buildPage [  ])
    , minima = (buildPage [ "minima" ])
    , moonForge = (buildPage [ "moon-forge" ])
    , posts =
        { hebdomad = (buildPage [ "posts", "hebdomad" ])
        , index = (buildPage [ "posts" ])
        , mergesort = (buildPage [ "posts", "mergesort" ])
        , minimaTalk = (buildPage [ "posts", "minima-talk" ])
        , minima = (buildPage [ "posts", "minima" ])
        , moonflask = (buildPage [ "posts", "moonflask" ])
        , nginlog = (buildPage [ "posts", "nginlog" ])
        , s3StaticPt1 = (buildPage [ "posts", "s3-static-pt1" ])
        , directory = directoryWithIndex ["posts"]
        }
    , directory = directoryWithIndex []
    }

images =
    { author =
        { bg = (buildImage [ "author", "bg.png" ])
        , directory = directoryWithoutIndex ["author"]
        }
    , blog =
        { hebdomad =
            { hebdomad = (buildImage [ "blog", "hebdomad", "hebdomad.png" ])
            , directory = directoryWithoutIndex ["blog", "hebdomad"]
            }
        , mergesort =
            { mergesort = (buildImage [ "blog", "mergesort", "mergesort.jpg" ])
            , directory = directoryWithoutIndex ["blog", "mergesort"]
            }
        , minima =
            { minima = (buildImage [ "blog", "minima", "minima.png" ])
            , directory = directoryWithoutIndex ["blog", "minima"]
            }
        , moonflask =
            { moonflask = (buildImage [ "blog", "moonflask", "moonflask.jpg" ])
            , directory = directoryWithoutIndex ["blog", "moonflask"]
            }
        , nginlog =
            { donuts = (buildImage [ "blog", "nginlog", "donuts.png" ])
            , nginlog = (buildImage [ "blog", "nginlog", "nginlog.png" ])
            , responsive = (buildImage [ "blog", "nginlog", "responsive.png" ])
            , directory = directoryWithoutIndex ["blog", "nginlog"]
            }
        , s3StaticPt1 =
            { goodBucketName = (buildImage [ "blog", "s3-static-pt1", "good-bucket-name.png" ])
            , lighthouse = (buildImage [ "blog", "s3-static-pt1", "lighthouse.png" ])
            , publicAccess = (buildImage [ "blog", "s3-static-pt1", "public-access.png" ])
            , s3Static = (buildImage [ "blog", "s3-static-pt1", "s3-static.jpg" ])
            , staticHosting = (buildImage [ "blog", "s3-static-pt1", "static-hosting.png" ])
            , upload = (buildImage [ "blog", "s3-static-pt1", "upload.png" ])
            , directory = directoryWithoutIndex ["blog", "s3StaticPt1"]
            }
        , directory = directoryWithoutIndex ["blog"]
        }
    , iconPng = (buildImage [ "icon-png.png" ])
    , lightWool = (buildImage [ "light-wool.png" ])
    , directory = directoryWithoutIndex []
    }

allImages : List (ImagePath PathKey)
allImages =
    [(buildImage [ "author", "bg.png" ])
    , (buildImage [ "blog", "hebdomad", "hebdomad.png" ])
    , (buildImage [ "blog", "mergesort", "mergesort.jpg" ])
    , (buildImage [ "blog", "minima", "minima.png" ])
    , (buildImage [ "blog", "moonflask", "moonflask.jpg" ])
    , (buildImage [ "blog", "nginlog", "donuts.png" ])
    , (buildImage [ "blog", "nginlog", "nginlog.png" ])
    , (buildImage [ "blog", "nginlog", "responsive.png" ])
    , (buildImage [ "blog", "s3-static-pt1", "good-bucket-name.png" ])
    , (buildImage [ "blog", "s3-static-pt1", "lighthouse.png" ])
    , (buildImage [ "blog", "s3-static-pt1", "public-access.png" ])
    , (buildImage [ "blog", "s3-static-pt1", "s3-static.jpg" ])
    , (buildImage [ "blog", "s3-static-pt1", "static-hosting.png" ])
    , (buildImage [ "blog", "s3-static-pt1", "upload.png" ])
    , (buildImage [ "icon-png.png" ])
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
    , { frontMatter = """{"type":"profile","title":"About","name":"Brian Ginsburg","avatar":"/images/author/bg.png","bio":"Brian Ginsburg is a Software Developer and Instructor at Kinetic Technology Solutions."}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["hebdomad"]
    , { frontMatter = """{"type":"page","title":"Hebdomad has Moved"}
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
  ( ["minima"]
    , { frontMatter = """{"type":"page","title":"Minima has Moved"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["moon-forge"]
    , { frontMatter = """{"type":"page","title":"Moon Forge has Moved"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "hebdomad"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Hebdomad","description":"Hebdomad is a xenharmonic web audio synthesizer","image":"/images/blog/hebdomad/hebdomad.png","draft":false,"published":"2017-01-03"}
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
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Haskell Merge Sort","description":"Haskell merge sort is fun and easy","image":"/images/blog/mergesort/mergesort.jpg","image-attribution":"Kelsie DiPerna","draft":false,"published":"2017-09-11"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "minima-talk"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Speaking: On minima","description":"Preseting Minima at the Functional Programming Study Group","image":"/images/blog/minima/minima.png","draft":false,"published":"2017-09-30"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "minima"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"minima","description":"Minima is a minimalist web audio playground","image":"/images/blog/minima/minima.png","draft":false,"published":"2017-06-20"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "moonflask"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Moon Flask","description":"Moon Flask was my first web project","image":"/images/blog/moonflask/moonflask.jpg","draft":false,"published":"2015-12-19"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "nginlog"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"nginlog","description":"nginlog is an nginx traffic analysis tool","image":"/images/blog/nginlog/nginlog.png","draft":false,"published":"2017-09-09"}
""" , body = Nothing
    , extension = "md"
    } )
  ,
  ( ["posts", "s3-static-pt1"]
    , { frontMatter = """{"type":"blog","author":"Brian Ginsburg","title":"Deploying elm-pages as a S3 Static Site, Part I","description":"We deploy an elm-pages blog to an AWS S3 bucket.","image":"/images/blog/s3-static-pt1/s3-static.jpg","image-attribution":"maxizapata of pixabay","draft":false,"published":"2019-11-02"}
""" , body = Nothing
    , extension = "md"
    } )
  
    ]
