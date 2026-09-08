# Home Assistant blueprints

Blueprints created and maintained by Michael Westlund for personal Home
Assistant installations. The repository is the source of truth; the copies in
each Home Assistant configuration are installed artifacts and should not be
committed to the installation's configuration repository.

## Published blueprints

### Universal Magic Button – Helper-Free Dimmer 1.0.0-beta.5

[![Import Universal Magic Button into Home Assistant](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fwestlund%2Fhassio-blueprints%2Fblob%2Fmain%2Fblueprints%2Fautomation%2Fpapamike%2Funiversal_magic_button.yaml)

[`universal_magic_button.yaml`](blueprints/automation/papamike/universal_magic_button.yaml)
is a helper-free Home Assistant blueprint for smooth one-button dimming. It
solves a deceptively awkward problem: using a single button to toggle a light
and alternate between dimming up and down, without creating or maintaining a
separate Home Assistant helper. Each long press continues in the next
direction, while short press and optional scene/default actions remain
configurable.

Users select Home Assistant triggers in separate `toggle`, `dim_start`,
`dim_stop` and optional `set_scene` fields, so the same
integration-independent dimming engine can work with MQTT, Zigbee2MQTT, ZHA,
deCONZ, Shelly and other integrations. The field in which an event is selected
determines its function automatically; no manual labels or YAML editing are
required. It provides configurable press actions, an optional reference light
and final synchronization of dimmable target lights.
Pure on/off target lights are left on or off after dimming according to a
configurable brightness breakpoint. Toggle is reference-led rather than
applied independently: every target turns
off together, while turning on synchronizes dimmable targets to the reference
brightness and applies the same breakpoint to pure on/off targets. The remote
must expose distinct hold-start and hold-stop/release events. A single target
light, or the selected reference light in a group, must support continuous
dimming across the full brightness range and report its settled brightness
accurately. Other dimmable targets only need to accept final brightness
commands, and pure on/off targets are detected automatically. Continuous
dimming behavior must be verified by the user because Home Assistant does not
expose it as a filterable capability.

The blueprint is designed for continuous dimming: with a suitable light and
integration, brightness should fade smoothly while the button is held, without
visible pauses, flicker or repeated stop-start behavior. For best results,
Home Assistant should have direct, low-level control of the lights, preferably
through Zigbee2MQTT or ZHA. Zigbee2MQTT is generally the recommended setup when
available, because it often exposes precise device actions and gives Home
Assistant better practical control over dimming behavior. Lights controlled
through manufacturer gateways, cloud integrations or bridge abstractions may
still work, but they are more likely to round brightness values, smooth
commands in their own way, delay state updates or otherwise limit the control
needed for truly smooth continuous dimming.

In short: the blueprint provides the helper-free alternating dimming logic, but
the light and integration still need to expose enough real control for smooth
continuous dimming to work well.

Several events may be selected for each function. Automations created with
beta.2 can be migrated using the collapsed **Legacy settings** section; new
automations use only the four dedicated trigger fields.

See the
[`complete configuration guide`](blueprints/automation/papamike/universal_magic_button_README.md)
for requirements, GUI trigger setup, beta migration, changelog, example
mappings and troubleshooting. The
separate
[`compatibility catalogue`](blueprints/automation/papamike/universal_magic_button_COMPATIBILITY.md)
distinguishes verified combinations from devices that should work or are known
to be unsupported, and explains how to report exact action names from new
successful tests.

### Hue Dimmer Beyond Lighting 1.0.0b6

[![Import Hue Dimmer Beyond Lighting into Home Assistant](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fwestlund%2Fhassio-blueprints%2Fblob%2Fmain%2Fblueprints%2Fautomation%2Fpapamike%2Fhue_dimmer_beyond_light.yaml)

[`hue_dimmer_beyond_light.yaml`](blueprints/automation/papamike/hue_dimmer_beyond_light.yaml)
provides full control for Philips Hue Dimmer Switch v1 and v2 devices connected
through MQTT/Zigbee2MQTT:

- short on/off presses control the selected lights;
- short dim presses change brightness in configurable steps;
- holding dim sends one Zigbee2MQTT `brightness_move` command to an optional
  dimmer master; release sends `brightness_move: 0` and synchronizes the other
  selected lights to the master's final brightness;
- long on/off presses can run arbitrary Home Assistant actions;
- transition time, step size and continuous dimming speed are configurable.

The dimmer master must be a Zigbee2MQTT light or group whose Home Assistant
device name matches its Zigbee2MQTT friendly name. When no master is selected,
the first selected light is used. Other selected lights may use different Home
Assistant integrations. The MQTT base topic is configurable and defaults to
`zigbee2mqtt`.

Inputs: Hue Dimmer device, light target, optional dimmer master, dimming
parameters, Zigbee2MQTT base topic and optional actions for long presses.
Minimum Home Assistant version: 2024.6.0.

## Work in progress

> [!WARNING]
> The following blueprints are unfinished personal experiments. They may be
> incomplete, untested or changed without backward compatibility. They are not
> currently documented or recommended for general use.

### Automation blueprints

- [Aqara Magic Button – Helper-Free Dimmer for Zigbee2MQTT](blueprints/automation/papamike/aqara_wireless_mini_switch.yaml) — **WIP**
- [Volume Nudge](blueprints/automation/papamike/volume_nudge.yaml) — **WIP**

### Script blueprints

- [MyNotifier Plus](blueprints/script/papamike/custom_notification.yaml) — **WIP**

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
