# Home Assistant blueprints

Blueprints created and maintained by Michael Westlund for personal Home
Assistant installations. The repository is the source of truth; the copies in
each Home Assistant configuration are installed artifacts and should not be
committed to the installation's configuration repository.

## Contents

### Automation blueprints

#### Aqara Wireless Mini Switch for Zigbee2MQTT

[`aqara_wireless_mini_switch.yaml`](blueprints/automation/papamike/aqara_wireless_mini_switch.yaml)
turns an Aqara one-button remote into a compact light controller. It listens to
the configured Zigbee2MQTT action topic and can control one or more lights:

- single press toggles the selected lights;
- double press turns them on at 67% brightness and 3400 K;
- hold alternates between increasing and decreasing brightness;
- release stops dimming and encodes the next direction in the otherwise
  imperceptible odd/even parity of the raw brightness value;
- after a configurable inactivity delay, the parity is reset so a new session
  always starts by increasing brightness.

Inputs: Zigbee2MQTT action topic, target light entities and new-session delay
(10 seconds by default). No helper entity is required.

#### Discreet Volume Limiter (beta)

[`discreet_volume_limiter.yaml`](blueprints/automation/papamike/discreet_volume_limiter.yaml)
is intended to monitor a media player's volume and gently bring it below a
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
