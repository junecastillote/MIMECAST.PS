# Release Notes

## v0.3 (2022-04-10)

* Initial release.
* Functions included:
  * [`Get-mcGroup`](docs/function/Get-mcGroup.md) - Get all or top *n* groups from the Mimecast directory.
  * [`Get-mcGroupById`](docs/function/Get-mcGroupById.md) - Get the group information with the specific group ID.
  * [`Get-mcGroupMember`](docs/function/Get-mcGroupMember.md) - Get the members the Mimecast groups.
  * [`Send-mcMailMessage`](docs/function/Send-mcMailMessage.md) - Send email via Mimecast.
  * [`New-mcGroupBackup`](docs/function/New-mcGroupBackup.md) - Create an export the groups (CSV) and group members (JSON). This command wraps the `Get-mcGroup`, `Get-mcGroupById`, `Get-mcGroupMember`, and `Send-mcMailMessage` altogether.
  * `Get-mcAccount` - Retrieves the Mimecast organizational account information.
  * `Get-mcAuthHeader` - Generates the Mimecast authorization header.

