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
- Release stops dimming, synchronizes every brightness-capable target and uses
  the resulting level to determine the final state of pure on/off targets.
- Dimmable lights that do not follow smooth relative dimming are corrected to
  the final absolute brightness when the button is released.
- Pure on/off target lights are left on or off after dimming according to a
  configurable brightness breakpoint (50% by default).

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
The reference input is a real Home Assistant light-entity picker, but entity
selectors cannot filter on `supported_color_modes`. The blueprint validates
that a selected reference reports brightness support when a hold starts. The
user must still verify actual continuous-dimming behavior for the specific
light and integration.

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

### 1. Select action triggers and assign blueprint IDs

In **1. Press actions and hold start**, add the device or event triggers exposed
by Home Assistant. Each trigger contains two different kinds of name:

- The integration-specific action, subtype or event name, such as
  `on_press_release`, `single_push` or `brightness_move_up`. Home Assistant and
  the device integration generate this value. Keep it unchanged.
- The **Trigger ID**, which maps that event to one neutral blueprint function.
  This is the value you add.

| Trigger ID | Blueprint function | Required | Legacy alias |
|---|---|---|---|
| `toggle` | Normal press; toggles targets unless a custom short action is configured | Yes for this function | `short` |
| `set_default` | Double press; applies the configured default unless a custom double action is configured | No | `double` |
| `dim_start` | Starts alternating continuous dimming | Yes for hold-to-dim | `hold` |

Trigger IDs are case-sensitive. Unknown or missing IDs are ignored safely.
Several triggers may use the same ID, allowing multiple buttons or event forms
to invoke the same function. The legacy aliases remain supported during the
beta period, so existing beta.1 automations continue to work.

#### Create device triggers in the visual editor

1. Under **1. Press actions and hold start**, select **Add trigger**.
2. Select **By type → Generic → Device**.
3. Under **Device**, select the remote control.
4. Under **Trigger**, select the physical event for this function.
5. Repeat until every required function has its own trigger, then save the
   automation.

The wording under **Trigger** comes from the device integration and varies by
model. For example, a Hue event called `on_hold` is not renamed; it receives the
additional blueprint ID `dim_start`.

#### Add the Trigger IDs in YAML

Home Assistant's visual editor does not currently offer a control for creating
an ID on a new device trigger inside a blueprint trigger selector. If an ID was
already defined in YAML, the editor may display a text field for it. Therefore,
create the device triggers visually first and add their initial IDs in YAML:

1. Open the saved automation's menu and select **Edit in YAML**.
2. Find `use_blueprint` → `input` → `action_triggers`.
3. Inside every trigger mapping, add `id:` at the same indentation level as
   `trigger:`, `domain:`, `subtype:` or the equivalent generated fields.
4. Set it to `toggle`, `set_default` or `dim_start` according to the function
   of that trigger.
5. Under `release_trigger`, adding `id: dim_stop` is recommended for readable
   YAML, although the separate release input works without it.
6. Save the automation. Do not change device IDs, action subtypes, MQTT topics
   or other fields generated by Home Assistant.

This example uses Hue/MQTT action names only to show the YAML structure. The
values under `subtype` will be different for other devices and integrations:

```yaml
use_blueprint:
  path: papamike/universal_magic_button.yaml
  input:
    action_triggers:
      - domain: mqtt
        device_id: YOUR_DEVICE_ID
        type: action
        subtype: on_press_release  # Integration-specific; keep this value
        trigger: device
        id: toggle                 # Blueprint function; add this value
      - domain: mqtt
        device_id: YOUR_DEVICE_ID
        type: action
        subtype: on_hold           # Integration-specific; keep this value
        trigger: device
        id: dim_start              # Blueprint function; add this value
    release_trigger:
      - domain: mqtt
        device_id: YOUR_DEVICE_ID
        type: action
        subtype: on_hold_release   # Integration-specific; keep this value
        trigger: device
        id: dim_stop               # Recommended documentation ID
```

Experts may use Event, MQTT, state or any other supported trigger type. Only the
placement and spelling of the blueprint IDs remain the same.

### 2. Select the release trigger

In **2. Dimming stop (hold release)**, select the separate event emitted when
the held button is released. Common integration names include `hold_release`,
`release`, `btn_up` and `brightness_stop`. The blueprint monitors this input
only while a dimming session is active.

The release input does not technically require a Trigger ID. `dim_stop` is
recommended in YAML because it documents the mapping and may appear in traces.
Separating release from the main trigger list ensures that repeated hold-start
messages cannot restart the automation or reverse direction.

### 3. Select lights

Choose one or more target lights. At least one must support continuous dimming.
If every target light supports it, the reference light is optional and the
blueprint calculates a level from the target lights that report brightness.

For a mixed group, select one of the continuously dimmable target lights as the
reference. It determines the initial direction and final level for the entire
group. A non-continuously-dimmable light must not be selected as reference.
An invalid reference or an automatically detected dimmable/on-off mix without
one stops the hold sequence with an error visible in the automation trace. A
brightness-capable target that performs poorly during continuous dimming
cannot be detected automatically; the user must select a suitable reference
in that case.

All brightness-capable targets receive every dimming attempt. At release, they
are set to the final absolute brightness so a less capable dimmable member can
catch up with the reference light. Pure on/off targets do not receive dimming
commands. Instead, **On/off light breakpoint** determines their final state:
they remain on when the resulting brightness is equal to or above the selected
percentage, and are turned off below it. This breakpoint is applied only after
a completed hold-dimming sequence; it does not change short- or double-press
behavior.

For mixed configurations, select the individual light entities as targets.
A Home Assistant light group is classified as one entity, so the blueprint
cannot reliably identify hidden on/off-only members inside that group.

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
| Normal press | `up_press_release` | `toggle` |
| Hold start | `up_hold` | `dim_start` |
| Release | `up_hold_release` | `dim_stop` recommended; technically optional |

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
mapping is `single_push` as `toggle`, `double_push` as optional `set_default`,
`long_push` as `dim_start`, and `btn_up` as `dim_stop`.

This Shelly profile is expected to work but has not yet been verified with the
blueprint. Confirm the exact events exposed by the device and firmware in Home
Assistant before creating the automation. Generation 1 `single` and `long`
click events alone are insufficient because they do not provide a distinct
release event.

### IKEA RODRET through Zigbee2MQTT

Typical action values are `on`, `off`, `brightness_move_up`,
`brightness_move_down` and `brightness_stop`. Choose one physical button for
the magic-button behavior; for example, map `on` to `toggle`,
`brightness_move_up` to `dim_start`, and `brightness_stop` to `dim_stop`.

### Aqara Wireless Mini Switch through Zigbee2MQTT

Models that expose `single`, `double`, `hold` and `release` map directly to the
neutral blueprint IDs `toggle`, `set_default`, `dim_start` and `dim_stop`.
Some Aqara variants expose multiple click counts but no hold/release and
therefore cannot provide continuous dimming.

## Execution and direction

The automation uses `single` mode. Once a hold starts, additional start events
are ignored until release. This is required for remotes that repeat their hold
message while the button remains down.

Unlike many other dimmer blueprints, this blueprint does not require a Home
Assistant helper to alternate between dimming up and down. The direction
alternates between completed holds. This version does not reset the direction
after an inactivity timeout.

## Troubleshooting

- Nothing happens: verify that each action trigger has the exact ID `toggle`,
  `set_default` or `dim_start`. The legacy IDs `short`, `double` and `hold`
  remain accepted during the beta period.
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
- Hold stops immediately with a configuration error: verify that at least one
  target reports brightness support, that all selected targets are available,
  and that any selected reference is a dimmable target. A detected mix with
  pure on/off targets requires a reference; other continuous-dimming
  limitations must be assessed by the user.
- An on/off light has the unexpected final state: compare the resulting group
  brightness with **On/off light breakpoint**. A level exactly at the
  breakpoint counts as on.

## Design limitation

A blueprint cannot currently inspect a selected device and dynamically create
the correct integration-specific triggers. Device event vocabularies also vary
between MQTT, ZHA and deCONZ. User-selected Home Assistant triggers are therefore
the stable compatibility boundary and avoid a permanently maintained table of
device models and payload names.
