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

- Short press uses a reference-led synchronized toggle. All targets turn off
  together; when turning on, dimmable targets adopt the reference brightness
  and pure on/off targets follow the configured breakpoint.
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

### 1. Select triggers in the visual editor

The blueprint has a separate trigger selector for each function. Trigger IDs
and YAML editing are not required:

| Field | Function | Typical event | Required |
|---|---|---|---|
| `toggle` | Toggles targets unless a custom short-press action is configured | Short press | Optional if only hold dimming is wanted |
| `dim_start` | Starts alternating continuous dimming | Hold starts | Yes for hold-to-dim |
| `dim_stop` | Stops dimming and synchronizes the targets | Held button is released | Yes for hold-to-dim |
| `set_scene` | Runs the configured scene/default action | Double press | No |

For each function:

1. Select **Add trigger**.
2. Select **By type → Generic → Device**.
3. Select the remote under **Device**.
4. Select the integration-specific event under **Trigger**.
5. Repeat inside the same field if several events should perform that function.

The event names are supplied by the device integration and must not be renamed.
For example, an MQTT device action named `on_hold` is selected under
**dim_start**, while `on_hold_release` is selected under **dim_stop**. Experts
may use Event, MQTT, state or any other trigger type offered by Home Assistant.

Separating `dim_stop` from the start triggers ensures that repeated hold-start
messages cannot restart the automation or reverse direction. Common stop-event
names include `hold_release`, `release`, `btn_up` and `brightness_stop`.

### 2. Migrate an automation created with beta.2 or older

Existing combined triggers remain supported in the collapsed **Legacy beta
migration** section, so updating the blueprint does not immediately break an
old automation. Migrate it in the visual editor as follows:

1. Recreate old `toggle` or `short` entries in the new **toggle** field.
2. Recreate old `dim_start` or `hold` entries in **dim_start**.
3. Recreate old `set_default`, `set_scene` or `double` entries in **set_scene**.
4. Keep the existing release event; the old `release_trigger` input now appears
   as **dim_stop** automatically.
5. Verify the new configuration, then remove all entries from **Legacy combined
   action triggers**.

Do not add Trigger IDs to the new fields. The legacy input remains only as a
temporary compatibility bridge during the beta period.

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
commands. Instead, **On/off breakpoint for non-dimmable lights** determines
their final state: they remain on when the resulting brightness is equal to or
above the selected percentage, and are turned off below it. This breakpoint is
applied only after a completed hold-dimming sequence; it does not change short-
or double-press behavior.

For mixed configurations, select the individual light entities as targets.
A Home Assistant light group is classified as one entity, so the blueprint
cannot reliably identify hidden on/off-only members inside that group.

### 4. Configure trigger actions and default light settings

If **Custom toggle action** is empty, a toggle trigger uses the selected
reference light as the source of truth. If no reference is selected, the first
dimmable target is used. When that reference is on, every target receives an
explicit turn-off command. When it is off, all dimmable targets turn on at its
remembered brightness; pure on/off targets turn on only at or above the
configured breakpoint and otherwise receive an explicit turn-off command.
This avoids split groups where independent toggle calls turn some lights on and
others off. If **Custom default scene action** is empty, a default scene trigger
turns them on using **Default light settings – Brightness**, **Color
temperature** and **Transition time** under **Lights and dimming**. The action
selector can instead activate an existing Home Assistant scene, call
`light.turn_on` with any supported light settings or run another action
sequence. Supplying a custom action replaces the corresponding default
completely.

## Example event mappings

Exact event names depend on device model, firmware and integration. Always use
the events Home Assistant offers for the actual device.

These examples describe expected mappings. Only combinations marked verified
in the compatibility catalogue have been tested end to end.

### Philips Hue Dimmer through Zigbee2MQTT/MQTT device triggers

| Blueprint field | Device action |
|---|---|
| `toggle` | `up_press_release` |
| `dim_start` | `up_hold` |
| `dim_stop` | `up_hold_release` |

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
mapping is `single_push` under `toggle`, `double_push` under optional
`set_scene`, `long_push` under `dim_start`, and `btn_up` under `dim_stop`.

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
separate `toggle`, `set_scene`, `dim_start` and `dim_stop` fields. Some Aqara
variants expose multiple click counts but no hold/release and therefore cannot
provide continuous dimming.

## Execution and direction

The automation uses `single` mode. Once a hold starts, additional start events
are ignored until release. This is required for remotes that repeat their hold
message while the button remains down.

Unlike many other dimmer blueprints, this blueprint does not require a Home
Assistant helper to alternate between dimming up and down. The direction
alternates between completed holds. This version does not reset the direction
after an inactivity timeout.

## Troubleshooting

- Nothing happens: verify that each event is selected in its matching
  `toggle`, `dim_start`, `dim_stop` or `set_scene` field. New configurations
  must not use Trigger IDs. For an unmigrated beta.2 automation, verify the old
  IDs in **Legacy combined action triggers** instead.
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
  brightness with **On/off breakpoint for non-dimmable lights**. A level exactly
  at the breakpoint counts as on.

## Design limitation

A blueprint cannot currently inspect a selected device and dynamically create
the correct integration-specific triggers. Device event vocabularies also vary
between MQTT, ZHA and deCONZ. User-selected Home Assistant triggers are therefore
the stable compatibility boundary and avoid a permanently maintained table of
device models and payload names.
