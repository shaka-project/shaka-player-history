# Shaka Player History

## Scripts

These are the various shell scripts that handle specific actions to make this
live stream.

Contents:
 - gource.sh: Run Gource to generate a video stream from Shaka Player's commit history
 - prepare-audio-loop.sh: Prepare in advance a single audio file to loop in the output stream
 - rename-aliases.sh: Normalize the names in the commit history file
 - update-git.sh: Update the Shaka Player repo, and build a commit log in the format Gource expects
