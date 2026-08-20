# Universal Magic Button compatibility

This page records remote controls, integrations and lights used with
`universal_magic_button.yaml`. Compatibility is divided into verified,
expected and unsupported combinations. A documented device is not considered
verified until someone has tested the complete hold-to-dim and release flow.

## Verified combinations

### Remote controls

| Remote | Integration | Short trigger | Hold trigger | Release trigger | Result |
|---|---|---|---|---|---|
| Philips Hue Dimmer Switch gen 1, model `324131092621` | Zigbee2MQTT through Home Assistant MQTT device triggers | `up_press_release` (`short`) | `up_hold` (`hold`) | `up_hold_release` | Verified |
| Philips Hue Dimmer Switch gen 2, model `929002398602` | Zigbee2MQTT through Home Assistant MQTT device triggers | `up_press_release` (`short`) | `up_hold` (`hold`) | `up_hold_release` | Verified |

The Hue test uses the physical brightness-up button. Zigbee2MQTT may emit
repeated `up_hold` actions during one physical hold; the blueprint correctly
ignores those additional starts until release.

Both Hue generations expose matching press, hold and release actions for all
four physical buttons. Four separate instances of the same blueprint can
therefore assign the four buttons to four different lights or light groups.

| Physical button | Gen 1 candidate actions | Gen 2 candidate actions |
|---|---|---|
| First/power | `on_press_release`, `on_hold`, `on_hold_release` | `on_press_release`, `on_hold`, `on_hold_release` |
| Brightness up | `up_press_release`, `up_hold`, `up_hold_release` | `up_press_release`, `up_hold`, `up_hold_release` |
| Brightness down | `down_press_release`, `down_hold`, `down_hold_release` | `down_press_release`, `down_hold`, `down_hold_release` |
| Fourth/off or Hue button | `off_press_release`, `off_hold`, `off_hold_release` | `off_press_release`, `off_hold`, `off_hold_release` |

The brightness-up mappings are verified. Test and report the other three
buttons before treating the complete four-group arrangement as verified.

### Lights

| Light | Model | Integration | Role | Result |
|---|---|---|---|---|
| Philips Hue white and color ambiance E27 1100 lm | `9290024688` | Zigbee2MQTT/MQTT | Continuously dimmable target | Verified |
| Philips Hue white ambiance E14 | `8718696695203` | Zigbee2MQTT/MQTT | Continuously dimmable target | Verified |

The two verified lights have also been tested together as one target group.
They follow relative dimming and final absolute-brightness synchronization.

## Expected to work

These combinations have documented action pairs that satisfy the blueprint's
requirements but have not yet been verified with this blueprint. Firmware,
integration and device-generation differences can still affect the result.

### Remote controls

| Remote | Integration | Candidate short | Candidate hold | Candidate release | Status |
|---|---|---|---|---|---|
| IKEA RODRET, `E2201` | Zigbee2MQTT/MQTT | `on` or `off` | `brightness_move_up` or `brightness_move_down` | `brightness_stop` | Expected |
| Aqara Wireless Mini Switch, `WXKG11LM`, variants that expose hold and release | Zigbee2MQTT/MQTT | `single` | `hold` | `release` | Expected, variant-dependent |
| Shelly Plus 1 or Plus 2PM, generation 2 | Native Home Assistant Shelly integration, input mode `Button` | `single_push` | `long_push` | `btn_up` | Expected; `double_push` can be mapped to `double` |

Equivalent device triggers exposed by ZHA or deCONZ should also work when they
provide distinct short, hold-start and hold-release events. Their exact event
names must be selected in Home Assistant and reported before they can be listed
as verified.

### Lights

The following light categories should work when their Home Assistant entities
actually support repeated relative brightness changes:

- dimmable Zigbee lights exposed by Zigbee2MQTT, ZHA or deCONZ;
- Philips Hue lights through a supported Home Assistant integration;
- dimmable Wi-Fi, Matter or Thread lights whose integration implements relative
  brightness steps consistently;
- mixed target groups, provided a continuously dimmable target is selected as
  reference and the remaining lights accept the final absolute brightness.

Brand or protocol alone does not prove continuous-dimming support. Each exact
model and integration combination must be tested before it is moved to the
verified table.

## Unsupported remote controls

| Remote or category | Integration | Exposed actions | Reason |
|---|---|---|---|
| SONOFF SNZB-01P | Zigbee2MQTT/MQTT | `single`, `double`, `long` | No separate hold-start and release/stop action |
| Shelly generation 1 using only native click events | Native Home Assistant Shelly integration | `single`, `double`, `long` and related completed-click events | No distinct release event in this event set; a separately verified raw-input solution would be required |
| Aqara `WXKG11LM` variants that expose click counts but no `hold` and `release` | Any | Typically `single`, `double`, `triple`, `quadruple` | Model name alone is insufficient; these variants cannot stop continuous dimming |
| Any remote that reports a long press only after the button is released | Any | One completed-long-press event | Continuous dimming cannot start while the button is held |
| Any remote without a distinct release or stop event | Any | Hold without release/stop | The blueprint cannot determine when to stop dimming |

Unsupported here means unsupported for this continuous-dimming blueprint. Such
buttons may still be perfectly suitable for ordinary short-, double- or
long-press automations.

## Unsupported light configurations

- a target group in which no light supports continuous dimming;
- a mixed-capability group without a reference light;
- a reference light that does not itself support continuous dimming;
- non-dimmable targets that cannot accept the final absolute brightness.

## Report a working combination

Please report successful combinations, partial successes and incompatibilities
through a
[GitHub issue](https://github.com/westlund/hassio-blueprints/issues). Include:

1. remote manufacturer and exact model/model ID;
2. integration, for example Zigbee2MQTT/MQTT, ZHA or deCONZ;
3. Home Assistant and integration versions;
4. the exact short, double, hold-start and release/stop action names or trigger
   YAML shown by Home Assistant;
5. light manufacturer, exact model and integration;
6. whether a reference light was selected;
7. whether short press, double press, continuous dimming, release and final
   synchronization all worked;
8. whether the remote repeats its hold action while the button remains down.

Do not include MQTT credentials, API tokens, Zigbee network keys, personal
addresses or other secrets. Confirmed reports will be added to this page so
future users can select known-good event mappings instead of rediscovering
them.
