module DropdownContainer exposing (Config, State, Visibility(..), attributes, initialState, triggerAttributes)

import Html
import Html.Attributes as Att
import Html.Events as Events


type State
    = State
        -- Whether to force the dropdown to stay open,
        -- ie when the container is blurred by clicking on a child
        Bool


initialState =
    State False


type Visibility
    = Open
    | Closed


type alias Config c msg =
    { c
        | setState : State -> msg
        , dropdownBlur : msg
    }


blurMsg : State -> Config c msg -> msg
blurMsg (State childClicked) { dropdownBlur, setState } =
    if childClicked then
        -- don't emit a blur message when a child is clicked, ie just set the same state
        State childClicked |> setState

    else
        dropdownBlur


attributes : State -> Config c msg -> Visibility -> List (Html.Attribute msg)
attributes state config visible =
    let
        visibilityValue =
            case visible of
                Open ->
                    "visible"

                Closed ->
                    "hidden"
    in
    [ Att.style "visibility" visibilityValue
    , Att.style "z-index" "20"
    , Att.style "position" "absolute"
    , Events.onMouseDown (State True |> config.setState)
    , Events.onMouseUp (State False |> config.setState)
    , Events.onBlur (blurMsg state config)
    ]


triggerAttributes : State -> Config c msg -> List (Html.Attribute msg)
triggerAttributes state config =
    [ Events.onBlur (blurMsg state config) ]
