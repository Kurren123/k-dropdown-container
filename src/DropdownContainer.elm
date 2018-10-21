module DropdownContainer exposing
    ( Visibility(..), State, initialState
    , dropDownCurrentlyClicked
    , Config, attributes, triggerAttributes
    )

{-| A dropdown container in elm which can keep open when the user clicks inside (if you so choose).


# Stuff to do with your model

@docs Visibility, State, initialState


# Stuff to do with your update

@docs dropDownCurrentlyClicked


# Stuff to do with your view

@docs Config, attributes, triggerAttributes

-}

import Html
import Html.Attributes as Att
import Html.Events as Events


{-| Whether the dropdown is visible
-}
type Visibility
    = Open
    | Closed


{-| The dropdown's internal state. This should be somewhere in your `model`,
along with a value indicating the dropdown's `Visibility`

    type alias Model =
    type alias Model =
        { dropdownState : Dropdown.State
        , dropdownVisbility : Dropdown.Visibility
        }

-}
type State
    = State
        -- Whether to force the dropdown to stay open,
        -- ie when the container is blurred by clicking on a child
        Bool


{-| Use this in the init of your app

    initialModel : Model
    initialModel =
        { dropdownState = Dropdown.initialState
        , dropdownVisbility = Dropdown.Closed
        }

-}
initialState : State
initialState =
    State False


{-| True if the user has pressed mousedown in the dropdown but
not yet released the mouse. This is useful when the `dropdownBlur` event has been
triggered and you need to decide whether you want to close the dropdown.

    update : Msg -> Model -> Model
    update msg model =
        case msg of
            DropdownBlur ->
                if Dropdown.dropDownCurrentlyClicked model.dropdownState then
                    model

                else
                    { model | dropdownVisbility = Dropdown.Closed }

-}
dropDownCurrentlyClicked : State -> Bool
dropDownCurrentlyClicked (State c) =
    c


{-| The config for the dropdown. `setState` should be a message which
updates the dropdowns state. `dropdownBlur` is a message that is fired whenever
the dropdown or it's trigger loses focus. **NOTE**: `dropdownBlur` can occur when the user
clicks into a child element of the dropdown, so when handling this message use
the `dropDownCurrentlyClicked` function to decide whether to close the dropdown on blur.

A tab index must be given for the dropdown, otherwise it cannot recieve focus.

-}
type alias Config msg =
    { setState : State -> msg
    , dropdownBlur : msg
    , tabIndex : Int
    }


{-| These go on the dropdown container itself, such as a `div`. You'll need to style the dropdown yourself.
The function accepts a dropdown state, a config and whether it should be visible or not (which can come from your model)

    dropdownView : Model -> Html Msg
    dropdownView model =
        div
            ([ style "width" "150px"
            , style "height" "200px"
            , style "border" "1px solid black"
            ]
                ++ Dropdown.attributes model.dropdownState dropDownConfig model.dropdownVisbility
            )
            [ button [] [ text "Click here" ] ]

-}
attributes : State -> Config msg -> Visibility -> List (Html.Attribute msg)
attributes state config visible =
    let
        visibilityValue =
            case visible of
                Open ->
                    "block"

                Closed ->
                    "none"
    in
    [ Att.style "display" visibilityValue
    , Att.style "z-index" "20"
    , Att.style "position" "absolute"
    , Att.tabindex config.tabIndex
    , Events.onMouseDown (State True |> config.setState)
    , Events.onMouseUp (State False |> config.setState)
    , Events.onBlur config.dropdownBlur
    ]


{-| Put these on your dropdown trigger: anything which causes a dropdown to open,
like a button or input text box. Remember to also set an event on the trigger to
actually open the dropdown.

    dropdownButton : Html Msg
    dropdownButton =
        button
            ([ onClick OpenDropdown ] ++ Dropdown.triggerAttributes dropDownConfig)
            [ text "Open dropdown" ]

-}
triggerAttributes : Config msg -> List (Html.Attribute msg)
triggerAttributes config =
    [ Events.onBlur config.dropdownBlur ]
