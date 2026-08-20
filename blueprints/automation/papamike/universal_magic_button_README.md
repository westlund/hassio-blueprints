# Universal Magic Button – Helper-Free Dimmer

## The challenge

How do you dim lights both up and down with only one button—and implement that
behavior in Home Assistant without a helper?

This blueprint provides a simple solution: alternate long presses dim up and
down. No separate helper needs to be created, configured or maintained. Short
press toggles the lights by default, while an optional double press can apply a
favorite light setting or run any other Home Assistant action.

`universal_magic_button.yaml` is an integration-independent Home Assistant
automation blueprint for one-button light control. Home Assistant's own trigger
editor connects the blueprint to the selected remote, so the dimming logic does
not need to know whether the event originates from MQTT, Zigbee2MQTT, ZHA,
deCONZ or another integration.

## Features

- Short press toggles all target lights by default.
- Double press is optional and defaults to 67% brightness at 2700 K.
- Short and double press can each be replaced with arbitrary Home Assistant
  actions.
- Hold alternates between dimming upwards and downwards without a helper.
- Repeated hold messages are ignored for the duration of the physical hold.
- Release stops dimming and synchronizes every target light to the reference
  light or calculated group level.
- Lights that do not follow smooth relative dimming are corrected to the final
  absolute brightness when the button is released.

## Requirements

- Home Assistant 2024.10.0 or newer.
- At least one selected light must support continuous dimming.
- If every target light supports continuous dimming, the reference light is
  optional.
- If one or more target lights lack continuous dimming, a reference light is
  required. The reference must be one of the continuously dimmable target
  lights.
- The remote and its Home Assistant integration must expose separate events for
  the start and end of a long press, such as `hold` plus `hold_release`, or
  `brightness_move_up` plus `brightness_stop`.

A remote that cannot distinguish the start of a long press from its release or
stop is incompatible with this blueprint. A short-, double- and long-press
event without a separate release event is not sufficient.

Home Assistant does not expose continuous dimming as one standardized light
capability that a blueprint selector can filter reliably across integrations.
The user must therefore verify these requirements when choosing target and
reference lights.

## Tested and expected compatibility

The blueprint is verified with a Philips Hue Dimmer Switch gen 1 through
Zigbee2MQTT/MQTT and two Philips Hue light models. Other remotes and lights are
listed separately as **expected** until their complete action sequence has been
tested. Devices without distinct hold-start and release/stop events are listed
as unsupported.

See the
[`compatibility catalogue`](universal_magic_button_COMPATIBILITY.md) for exact
models, action names, known limitations and instructions for reporting a new
working combination. Reports should include the precise Home Assistant action
or trigger names; product name alone is not enough because device generations,
firmware and integrations can expose different events.

## Configuration

### 1. Select action triggers

In **Press and hold-start triggers**, add the device or event triggers exposed
by Home Assistant. Open each trigger's settings and assign exactly one of these
trigger IDs:

| Trigger ID | Meaning | Required |
|---|---|---|
| `short` | Short or single press | Yes for toggle/custom short action |
| `double` | Double press | No |
| `hold` | Start of a long press | Yes for continuous dimming |

Trigger IDs are case-sensitive. Unknown or missing IDs are ignored safely.
Several triggers may use the same ID, allowing multiple buttons or event forms
to invoke the same function.

### 2. Select the release trigger

In **Hold-release trigger**, select the event emitted when the held button is
released. It does not need a trigger ID. The blueprint monitors this event only
while a dimming session is active.

Separating release from the main trigger list is intentional. It ensures that
repeated hold messages cannot restart the automation or reverse direction.

### 3. Select lights

Choose one or more target lights. At least one must support continuous dimming.
If every target light supports it, the reference light is optional and the
blueprint calculates a level from the target lights that report brightness.

For a mixed group, select one of the continuously dimmable target lights as the
reference. It determines the initial direction and final level for the entire
group. A non-continuously-dimmable light must not be selected as reference.

All selected lights receive every dimming attempt. At release, all lights are
set to the final absolute brightness so a less capable group member can catch
up with the reference light.

### 4. Configure press actions

If **Custom short-press action** is empty, short press toggles the target lights.
If **Custom double-press action** is empty, double press turns them on using the
configured brightness and color temperature. Supplying custom actions replaces
the corresponding default completely.

## Example event mappings

Exact event names depend on device model, firmware and integration. Always use
the events Home Assistant offers for the actual device.

These examples describe expected mappings. Only combinations marked verified
in the compatibility catalogue have been tested end to end.

### Philips Hue Dimmer through Zigbee2MQTT/MQTT device triggers

| Function | Device action | Trigger ID |
|---|---|---|
| Short press | `up_press_release` | `short` |
| Hold start | `up_hold` | `hold` |
| Release | `up_hold_release` | none |

Hue Dimmer does not normally expose a distinct double-press device action.

Both Hue Dimmer generation 1 and generation 2 have dedicated brightness-up and
brightness-down buttons. This blueprint makes a different arrangement possible:
create four automation instances from the same blueprint and map one physical
button to each instance. Each button can then control its own light or light
group with short press and alternating hold dimming.

For example, the four buttons can control ceiling, window, reading and accent
lights independently. Replacement symbols can be placed over the original Hue
symbols so the remote clearly shows the four new destinations. Each automation
must use that button's matching press, hold and release actions; see the Hue
profiles in the compatibility catalogue.

### Shelly Plus 1 or Plus 2PM through the native Shelly integration

Configure the connected momentary input as **Button**. Home Assistant then
creates an event entity and exposes generation 2 button events. A candidate
mapping is `single_push` as `short`, `double_push` as optional `double`,
`long_push` as `hold`, and `btn_up` as release.

This Shelly profile is expected to work but has not yet been verified with the
blueprint. Confirm the exact events exposed by the device and firmware in Home
Assistant before creating the automation. Generation 1 `single` and `long`
click events alone are insufficient because they do not provide a distinct
release event.

### IKEA RODRET through Zigbee2MQTT

Typical action values are `on`, `off`, `brightness_move_up`,
`brightness_move_down` and `brightness_stop`. Choose one physical button for
the magic-button behavior; for example, use `on` as `short`,
`brightness_move_up` as `hold`, and `brightness_stop` as release.

### Aqara Wireless Mini Switch through Zigbee2MQTT

Models that expose `single`, `double`, `hold` and `release` map directly to the
corresponding functions. Some Aqara variants expose multiple click counts but
no hold/release and therefore cannot provide continuous dimming.

## Execution and direction

The automation uses `single` mode. Once a hold starts, additional start events
are ignored until release. This is required for remotes that repeat their hold
message while the button remains down.

Unlike many other dimmer blueprints, this blueprint does not require a Home
Assistant helper to alternate between dimming up and down. The direction
alternates between completed holds. This version does not reset the direction
after an inactivity timeout.

## Troubleshooting

- Nothing happens: verify that each action trigger has the exact ID `short`,
  `double` or `hold`.
- Dimming never stops: the selected release event does not match what the
  device sends. Observe the device's available automation triggers or event
  stream and select the matching release/stop event. If no separate event
  exists, the remote cannot be used with this blueprint.
- A hold is interpreted as a short press: some integrations emit a release
  event that represents both actions. Choose a dedicated short-press event if
  the device provides one.
- Double press also runs short press: the device is reporting two independent
  short presses rather than a native double event. Leave double unconfigured or
  use an integration/device profile that exposes double press distinctly.
- Lights end at slightly different levels: select the most reliable dimmable
  target as the reference light.
- A mixed group behaves unpredictably: verify that the selected reference is a
  target light with continuous-dimming support.

## Design limitation

A blueprint cannot currently inspect a selected device and dynamically create
the correct integration-specific triggers. Device event vocabularies also vary
between MQTT, ZHA and deCONZ. User-selected Home Assistant triggers are therefore
the stable compatibility boundary and avoid a permanently maintained table of
device models and payload names.
