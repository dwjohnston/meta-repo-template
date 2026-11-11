# Task 96: Docker-in-Docker Build and Run

Parked for later.

Extend the Task 95 DinD check to:

- Build a small image containing a unique marker.
- Run a container from it and verify the marker output.
- Confirm the inner image and container are invisible to the host daemon.
- Clean up only the resources created by the test.

## Caveats

- **Building needs a base image.** Pulling one makes the test depend on the network and on registry rate limits. Use a tiny pinned image and accept that, or skip with a clear notice when offline.
- **Inner images live in the container's Docker data volume**, which the feature creates. Removing the outer project with `down --volumes` clears them, so inner cleanup is a courtesy, not a requirement.
- **"Invisible to the host daemon" needs a unique marker** in the image tag and container name, then a host-side search that returns nothing.

Recommended model: Claude Sonnet 5.5.
