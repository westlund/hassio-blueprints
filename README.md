# Home Assistant blueprints

Blueprints created and maintained by Michael Westlund for personal Home
Assistant installations. The repository is the source of truth; the copies in
each Home Assistant configuration are installed artifacts and should not be
committed to the installation's configuration repository.

## Published blueprints

### Universal Magic Button – Helper-Free Dimmer 1.0.0-beta.4

[![Import Universal Magic Button into Home Assistant](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fwestlund%2Fhassio-blueprints%2Fblob%2Fmain%2Fblueprints%2Fautomation%2Fpapamike%2Funiversal_magic_button.yaml)

[`universal_magic_button.yaml`](blueprints/automation/papamike/universal_magic_button.yaml)
solves a deceptively awkward problem: dimming both up and down with only one
button in Home Assistant, without manually creating a helper. Alternate long
presses dim in opposite directions, while short and optional double presses can
run their own actions.

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
brightness and applies the same breakpoint to pure on/off targets. At
least one target light must support continuous dimming. A reference light is
required only for mixed groups where some targets lack that support, and the
remote must expose separate events for the start and end of a long press.
Pure on/off targets are detected automatically. Continuous-dimming behavior in
other brightness-capable lights must be verified by the user because Home
Assistant does not expose it as a filterable capability.

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

### Hue Dimmer Beyond Lighting 0.5.2b

[![Import Hue Dimmer Beyond Lighting into Home Assistant](https://my.home-assistant.io/badges/blueprint_import.svg)](https://my.home-assistant.io/redirect/blueprint_import/?blueprint_url=https%3A%2F%2Fgithub.com%2Fwestlund%2Fhassio-blueprints%2Fblob%2Fmain%2Fblueprints%2Fautomation%2Fpapamike%2Fhue_dimmer_beyond_light.yaml)

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
