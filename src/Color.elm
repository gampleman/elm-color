module Color exposing
    ( Color
    , fromRgba
    , rgba, rgb, rgb255
    , fromHex
    , toRgba
    , toHex
    , red, orange, yellow, green, blue, purple, brown
    , lightRed, lightOrange, lightYellow, lightGreen, lightBlue, lightPurple, lightBrown
    , darkRed, darkOrange, darkYellow, darkGreen, darkBlue, darkPurple, darkBrown
    , white, lightGrey, grey, darkGrey, lightCharcoal, charcoal, darkCharcoal, black
    , lightGray, gray, darkGray
    )

{-| Module for working with colors. Allows creating colors via either
[sRGB](https://en.wikipedia.org/wiki/RGB_color_model) values
[HSL](http://en.wikipedia.org/wiki/HSL_and_HSV) values, or
[Hex strings](https://en.wikipedia.org/wiki/Web_colors#Hex_triplet).


# Types

@docs Color


# Creating colors

All color construction functions guarantee to only construct valid color values for you.
If you happen to pass channel values that are out of range, then they will be clamped between
0.0 and 1.0, or 0 and 255 respectively.

@docs fromRgba
@docs rgba, rgb, rgb255
@docs fromHex


# Extracing values back out of colors

@docs toRgba
@docs toHex


# Built-in Colors

These colors come from the [Tango palette](http://tango.freedesktop.org/Tango_Icon_Theme_Guidelines)
which provides aesthetically reasonable defaults for colors.
Each color also comes with a light and dark version.


## Standard

@docs red, orange, yellow, green, blue, purple, brown


## Light

@docs lightRed, lightOrange, lightYellow, lightGreen, lightBlue, lightPurple, lightBrown


## Dark

@docs darkRed, darkOrange, darkYellow, darkGreen, darkBlue, darkPurple, darkBrown


## Eight Shades of Grey

These colors are a compatible series of shades of grey, fitting nicely
with the Tango palette.

@docs white, lightGrey, grey, darkGrey, lightCharcoal, charcoal, darkCharcoal, black

These are identical to the _grey_ versions. It seems the spelling is regional, but
that has never helped me remember which one I should be writing.

@docs lightGray, gray, darkGray

-}

import Bitwise exposing (shiftLeftBy)


{-| Represents a color.
-}
type Color
    = RgbaSpace Float Float Float Float


{-| Creates a color from a record of RGBA values (red, green, blue, alpha) between 0.0 and 1.0 (inclusive).

The RGB values are interpreted in the [sRGB](https://en.wikipedia.org/wiki/SRGB) color space,
which is the standard for the Internet (HTML, CSS, and SVG), as well as digital images and printing.

See also: [`rgba`](#rgba)

-}
fromRgba : { red : Float, green : Float, blue : Float, alpha : Float } -> Color
fromRgba components =
    RgbaSpace components.red components.green components.blue components.alpha


{-| Creates a `Color` from RGBA (red, green, blue, alpha) values between 0.0 and 1.0 (inclusive).

This is a convenience function for making a color value without needing to use a record.

See also: [`fromRgba`](#fromRgba)

-}
rgba : Float -> Float -> Float -> Float -> Color
rgba r g b a =
    RgbaSpace r g b a


{-| Creates a color from RGB (red, green, blue) values between 0.0 and 1.0 (inclusive).

This is a convenience function for making a color value with full opacity.

See also: [`rgba`](#rgba)

-}
rgb : Float -> Float -> Float -> Color
rgb r g b =
    RgbaSpace r g b 1.0


{-| Creates a color from RGB (red, green, blue) 8-bit integer values between 0 and 255.

This is a convenience function if you find passing RGB channels as integers scaled to 255 more intuitive.

Note that this is less fine-grained than passing the channels as `Float` between 0.0 and 1.0, since
there are only 2^8=256 possible values for each channel.

See also: [`rgba`](#rgba)

-}
rgb255 : Int -> Int -> Int -> Color
rgb255 r g b =
    rgb (scaleChannel r) (scaleChannel g) (scaleChannel b)


scaleChannel : Int -> Float
scaleChannel c =
    toFloat c / 255


{-| Extract the RGBA (red, green, blue, alpha) components out of a `Color` value.
The component values will be between 0.0 and 1.0 (inclusive).

The RGB values are interpreted in the [sRGB](https://en.wikipedia.org/wiki/SRGB) color space,
which is the standard for the Internet (HTML, CSS, and SVG), as well as digital images and printing.

-}
toRgba : Color -> { red : Float, green : Float, blue : Float, alpha : Float }
toRgba (RgbaSpace r g b a) =
    { red = r, green = g, blue = b, alpha = a }


{-| This function is meant for convenience of specifying colors,
and so always returns a valid color.
If the string given is not a valid 3-, 4-, 6-, or 8-digit hex string,
then this function will return `rgba 0 0 0 1`
-}
fromHex : String -> Color
fromHex hexString =
    Maybe.withDefault (RgbaSpace 0 0 0 0) <|
        case String.toList hexString of
            [ '#', r, g, b ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( 'f', 'f' )

            [ r, g, b ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( 'f', 'f' )

            [ '#', r, g, b, a ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( a, a )

            [ r, g, b, a ] ->
                fromHex8 ( r, r ) ( g, g ) ( b, b ) ( a, a )

            [ '#', r1, r2, g1, g2, b1, b2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( 'f', 'f' )

            [ r1, r2, g1, g2, b1, b2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( 'f', 'f' )

            [ '#', r1, r2, g1, g2, b1, b2, a1, a2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 )

            [ r1, r2, g1, g2, b1, b2, a1, a2 ] ->
                fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 )

            _ ->
                Nothing


fromHex8 : ( Char, Char ) -> ( Char, Char ) -> ( Char, Char ) -> ( Char, Char ) -> Maybe Color
fromHex8 ( r1, r2 ) ( g1, g2 ) ( b1, b2 ) ( a1, a2 ) =
    Maybe.map4
        (\r g b a ->
            RgbaSpace
                (toFloat r / 255)
                (toFloat g / 255)
                (toFloat b / 255)
                (toFloat a / 255)
        )
        (hex2ToInt r1 r2)
        (hex2ToInt g1 g2)
        (hex2ToInt b1 b2)
        (hex2ToInt a1 a2)


hex2ToInt : Char -> Char -> Maybe Int
hex2ToInt c1 c2 =
    Maybe.map2 (\v1 v2 -> shiftLeftBy 4 v1 + v2) (hexToInt c1) (hexToInt c2)


hexToInt : Char -> Maybe Int
hexToInt char =
    case Char.toLower char of
        '0' ->
            Just 0

        '1' ->
            Just 1

        '2' ->
            Just 2

        '3' ->
            Just 3

        '4' ->
            Just 4

        '5' ->
            Just 5

        '6' ->
            Just 6

        '7' ->
            Just 7

        '8' ->
            Just 8

        '9' ->
            Just 9

        'a' ->
            Just 10

        'b' ->
            Just 11

        'c' ->
            Just 12

        'd' ->
            Just 13

        'e' ->
            Just 14

        'f' ->
            Just 15

        _ ->
            Nothing


{-| This function will convert a color to a 6-digit hexadecimal string in the format `#rrggbb`.
-}
toHex : Color -> { hex : String, alpha : Float }
toHex c =
    let
        components =
            toRgba c
    in
    { hex =
        [ components.red, components.green, components.blue ]
            |> List.map ((*) 255)
            |> List.map round
            |> List.map int255ToHex
            |> String.concat
            |> (++) "#"
    , alpha = components.alpha
    }


int255ToHex : Int -> String
int255ToHex n =
    if n < 0 then
        "00"

    else if n > 255 then
        "ff"

    else
        unsafeInt255Digits n
            |> Tuple.mapBoth unsafeIntToChar unsafeIntToChar
            |> (\( a, b ) -> String.cons a (String.cons b ""))


unsafeInt255Digits : Int -> ( Int, Int )
unsafeInt255Digits n =
    let
        digit1 =
            n // 16

        digit0 =
            if digit1 /= 0 then
                modBy (digit1 * 16) n

            else
                n
    in
    ( digit1, digit0 )


unsafeIntToChar : Int -> Char
unsafeIntToChar i =
    if i < 10 then
        String.fromInt i
            |> String.uncons
            |> Maybe.map Tuple.first
            |> Maybe.withDefault '0'

    else
        case i of
            10 ->
                'a'

            11 ->
                'b'

            12 ->
                'c'

            13 ->
                'd'

            14 ->
                'e'

            15 ->
                'f'

            _ ->
                '0'



--
-- Built-in colors
--


{-| -}
lightRed : Color
lightRed =
    RgbaSpace (239 / 255) (41 / 255) (41 / 255) 1.0


{-| -}
red : Color
red =
    RgbaSpace (204 / 255) (0 / 255) (0 / 255) 1.0


{-| -}
darkRed : Color
darkRed =
    RgbaSpace (164 / 255) (0 / 255) (0 / 255) 1.0


{-| -}
lightOrange : Color
lightOrange =
    RgbaSpace (252 / 255) (175 / 255) (62 / 255) 1.0


{-| -}
orange : Color
orange =
    RgbaSpace (245 / 255) (121 / 255) (0 / 255) 1.0


{-| -}
darkOrange : Color
darkOrange =
    RgbaSpace (206 / 255) (92 / 255) (0 / 255) 1.0


{-| -}
lightYellow : Color
lightYellow =
    RgbaSpace (255 / 255) (233 / 255) (79 / 255) 1.0


{-| -}
yellow : Color
yellow =
    RgbaSpace (237 / 255) (212 / 255) (0 / 255) 1.0


{-| -}
darkYellow : Color
darkYellow =
    RgbaSpace (196 / 255) (160 / 255) (0 / 255) 1.0


{-| -}
lightGreen : Color
lightGreen =
    RgbaSpace (138 / 255) (226 / 255) (52 / 255) 1.0


{-| -}
green : Color
green =
    RgbaSpace (115 / 255) (210 / 255) (22 / 255) 1.0


{-| -}
darkGreen : Color
darkGreen =
    RgbaSpace (78 / 255) (154 / 255) (6 / 255) 1.0


{-| -}
lightBlue : Color
lightBlue =
    RgbaSpace (114 / 255) (159 / 255) (207 / 255) 1.0


{-| -}
blue : Color
blue =
    RgbaSpace (52 / 255) (101 / 255) (164 / 255) 1.0


{-| -}
darkBlue : Color
darkBlue =
    RgbaSpace (32 / 255) (74 / 255) (135 / 255) 1.0


{-| -}
lightPurple : Color
lightPurple =
    RgbaSpace (173 / 255) (127 / 255) (168 / 255) 1.0


{-| -}
purple : Color
purple =
    RgbaSpace (117 / 255) (80 / 255) (123 / 255) 1.0


{-| -}
darkPurple : Color
darkPurple =
    RgbaSpace (92 / 255) (53 / 255) (102 / 255) 1.0


{-| -}
lightBrown : Color
lightBrown =
    RgbaSpace (233 / 255) (185 / 255) (110 / 255) 1.0


{-| -}
brown : Color
brown =
    RgbaSpace (193 / 255) (125 / 255) (17 / 255) 1.0


{-| -}
darkBrown : Color
darkBrown =
    RgbaSpace (143 / 255) (89 / 255) (2 / 255) 1.0


{-| -}
black : Color
black =
    RgbaSpace (0 / 255) (0 / 255) (0 / 255) 1.0


{-| -}
white : Color
white =
    RgbaSpace (255 / 255) (255 / 255) (255 / 255) 1.0


{-| -}
lightGrey : Color
lightGrey =
    RgbaSpace (238 / 255) (238 / 255) (236 / 255) 1.0


{-| -}
grey : Color
grey =
    RgbaSpace (211 / 255) (215 / 255) (207 / 255) 1.0


{-| -}
darkGrey : Color
darkGrey =
    RgbaSpace (186 / 255) (189 / 255) (182 / 255) 1.0


{-| -}
lightGray : Color
lightGray =
    RgbaSpace (238 / 255) (238 / 255) (236 / 255) 1.0


{-| -}
gray : Color
gray =
    RgbaSpace (211 / 255) (215 / 255) (207 / 255) 1.0


{-| -}
darkGray : Color
darkGray =
    RgbaSpace (186 / 255) (189 / 255) (182 / 255) 1.0


{-| -}
lightCharcoal : Color
lightCharcoal =
    RgbaSpace (136 / 255) (138 / 255) (133 / 255) 1.0


{-| -}
charcoal : Color
charcoal =
    RgbaSpace (85 / 255) (87 / 255) (83 / 255) 1.0


{-| -}
darkCharcoal : Color
darkCharcoal =
    RgbaSpace (46 / 255) (52 / 255) (54 / 255) 1.0
