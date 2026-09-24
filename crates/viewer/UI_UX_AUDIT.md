# OAS VehicleState Viewer UI/UX audit

## Scope

This audit covers the current virtual HMI: no hardware, media engine, account, camera feed, or vehicle command transport is assumed. A screen is complete when it has a clear purpose, safe empty state, and return path; it is not complete merely because a future integration exists.

## Findings and resolution

| Finding | Resolution |
| --- | --- |
| Safety status was local to Home and Media. | A global safety banner is now visible under the top bar on every screen. |
| Media promised Player and Library without a Library screen. | Player and Library are separate in-menu views, each with an explicit empty state. |
| Vehicle had Comfort Control and Vision competing in one view. | Controls and Vision are separate in-menu views. Controls remain local UI simulation only. |
| Settings categories did not lead to distinct content. | Display, Audio, Media safety, and System now have their own in-menu views. |
| Diagnostics lacked CAN and Logs destinations. | Overview, CAN, and Logs now expose safe pre-hardware states. |
| Future integrations could appear as broken blank pages. | Every hardware-dependent destination has a concise waiting state and explains what will appear later. |
| Static CSS could override a hidden in-menu view. | The global `[hidden]` rule has priority, and browser verification checks each menu state. |
| The viewer and the production HMI had drifted into two different visual languages. | Both now use the same Grid system: meeting cells on a hairline rule, zero radius, monochrome with colour reserved for safety, light by default. |
| A missing value rendered as an em dash at display size, which reads as a solid black bar rather than "no value". | Unknown values carry `.is-empty`, which drops them to a readable size in tertiary ink. |
| `.setting-row > div` also matched the sibling `.choice-row`, stacking the theme buttons into a column. | The rule is scoped with `:not(.choice-row)`. |

## Screen inventory

- **Home:** safety summary, media entry, vehicle snapshot, diagnostics entry.
- **Media / Player:** playback permission and policy context.
- **Media / Library:** web media, local media, and queue empty states.
- **Vehicle / Controls:** simulated climate and audio controls.
- **Vehicle / Vision:** camera and privacy waiting state.
- **Settings / Display, Audio, Media safety, System:** one owner per preference category.
- **Diagnostics / Overview, CAN, Logs:** runtime state, target-hardware status, and log waiting state.

## Deliberately excluded

Authentication, maps, app store, phone integration, arbitrary vehicle commands, and cloud content browsing have no supported integration in the current product scope. They are not rendered as inert menus.
