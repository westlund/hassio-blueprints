# Home Assistant blueprints

Blueprints created and maintained by Michael Westlund for personal Home
Assistant installations. The repository is the source of truth; the copies in
each Home Assistant configuration are installed artifacts and should not be
committed to the installation's configuration repository.

## Contents

- `blueprints/automation/papamike/` – automation blueprints
- `blueprints/script/papamike/` – script blueprints

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
