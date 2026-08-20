# Home Assistant blueprints

Blueprints created and maintained by Michael Westlund for personal Home
Assistant installations. The repository is the source of truth; the copies in
each Home Assistant configuration are installed artifacts and should not be
committed to the installation's configuration repository.

## Contents

### Automation blueprints

#### Universal Magic Button – Helper-Free Dimmer 1.0.0-beta.2

[`universal_magic_button.yaml`](blueprints/automation/papamike/universal_magic_button.yaml)
solves a deceptively awkward problem: dimming both up and down with only one
button in Home Assistant, without manually creating a helper. Alternate long
presses dim in opposite directions, while short and optional double presses can
run their own actions.

Users select Home Assistant triggers for short press, optional double press,
hold and release, so the same integration-independent dimming engine can work
with MQTT, Zigbee2MQTT, ZHA, deCONZ, Shelly and other integrations. It provides
configurable press actions, an optional reference light and final
synchronization of dimmable target lights. Pure on/off target lights are left
on or off after dimming according to a configurable brightness breakpoint. At
least one target light must support continuous dimming. A reference light is
required only for mixed groups where some targets lack that support, and the
remote must expose separate events for the start and end of a long press.
Pure on/off targets are detected automatically. Continuous-dimming behavior in
other brightness-capable lights must be verified by the user because Home
Assistant does not expose it as a filterable capability.

Neutral blueprint IDs map integration-specific device events to functions:
`toggle`, optional `set_default`, `dim_start` and the recommended release ID
`dim_stop`. The previous `short`, `double` and `hold` IDs remain compatible
during the beta period.

See the
[`complete configuration guide`](blueprints/automation/papamike/universal_magic_button_README.md)
for requirements, trigger IDs, example mappings and troubleshooting. The
separate
[`compatibility catalogue`](blueprints/automation/papamike/universal_magic_button_COMPATIBILITY.md)
distinguishes verified combinations from devices that should work or are known
to be unsupported, and explains how to report exact action names from new
successful tests.

#### Aqara Magic Button – Helper-Free Dimmer for Zigbee2MQTT 1.4

[`aqara_wireless_mini_switch.yaml`](blueprints/automation/papamike/aqara_wireless_mini_switch.yaml)
turns an Aqara one-button remote into a compact light controller. It listens to
the configured Zigbee2MQTT action topic and can control one or more lights:

- single press toggles the selected lights;
- double press turns them on at a configurable brightness and color
  temperature (67% and 2700 K by default);
- hold alternates between increasing and decreasing brightness;
- release stops dimming and remembers the direction for the next hold;
- all target lights are always asked to dim;
- on release, all target lights are corrected to the desired final level if
  they have not already reached it;
- after a configurable inactivity delay, a new session always starts by
  increasing brightness.

Inputs: Zigbee2MQTT action topic, target light entities, optional reference
light, double-press brightness and color temperature, direction-reset switch
and inactivity timeout (10 seconds by default), plus dimming speed (10% per
second by default). The optional reference light coordinates the group state
and defines the final group level. Lights without smooth step dimming can still
follow when the final absolute level is applied. No helper entity is required.

#### Volume Nudge (beta)

[`volume_nudge.yaml`](blueprints/automation/papamike/volume_nudge.yaml) is
intended to monitor a media player's volume and gently bring it below a
configured ceiling. It provides inputs for a fixed maximum volume, an optional
`input_number` limit and an optional `input_boolean` enable switch.

This blueprint is experimental. In the current implementation, the corrective
`media_player.volume_down` action is disabled and the optional helpers are not
yet applied to the limiter logic. Do not rely on it as an active volume limit
until that behavior has been completed and tested.

#### Hue Dimmer Beyond Lighting 0.5.1b

[`hue_dimmer_beyond_light.yaml`](blueprints/automation/papamike/hue_dimmer_beyond_light.yaml)
provides full control for Philips Hue Dimmer Switch v1 and v2 devices connected
through MQTT/Zigbee2MQTT:

- short on/off presses control the selected lights;
- short dim presses change brightness in configurable steps;
- holding dim continuously changes brightness until release;
- long on/off presses can run arbitrary Home Assistant actions;
- transition time, step size and continuous dimming speed are configurable.

Inputs: Hue Dimmer device, light target, dimming parameters and optional actions
for long presses. Minimum Home Assistant version: 2024.6.0.

#### Hue Magic Up Button – Helper-Free Dimmer 1.1

[`hue_magic_up_button.yaml`](blueprints/automation/papamike/hue_magic_up_button.yaml)
temporarily turns the up button on a Philips Hue Dimmer Switch into a
helper-free one-button light controller. A short press toggles the selected
lights. Holding the button alternates dimming direction; releasing it stops
dimming and synchronizes every target light to the final level. Repeated hold
messages are ignored until release, preventing one physical hold from changing
direction partway through. An optional reference light can coordinate a group.

The blueprint deliberately handles only the up button and has no double-press
action because the Hue Dimmer does not expose a separate double-press device
action. Disable any other automation that uses the same button while testing.

### Script blueprints

#### MyNotifier Plus

[`custom_notification.yaml`](blueprints/script/papamike/custom_notification.yaml)
is a queued notification script for a device running the Home Assistant mobile
app. It accepts a target device, title, multiline message and priority choice,
then sends the message through `notify.notify`. Up to ten calls can be queued.

The current implementation sets notification badge `2`. The selected priority
is exposed as an input but is not yet passed as an interruption level to the
mobile notification.

## Install or update on Home Assistant OS

Clone or update this repository outside `/homeassistant`, then run:

```sh
sudo ./sync-to-home-assistant.sh /homeassistant
```

The script copies only the blueprints maintained by this repository. It does
not remove imported blueprints from Home Assistant.

Run Home Assistant's configuration check after updating and reload the affected
automations or restart Home Assistant when appropriate.

The [LICENSE](LICENSE) applies to everything in this repository.
