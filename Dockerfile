# syntax=docker/dockerfile:1
#
# Kitchen Crew mock server — production image.
#
# IMPORTANT: build context MUST be the repo root, not server/.
# The server has a path dependency on packages/contracts, so both
# directories have to be inside the build context.
#
#   docker build -t kitchen-crew-server .
#
# Multi-stage: compile to a self-contained native executable in the
# Dart SDK image, then ship only the binary + minimal runtime on a
# `scratch` base (~10 MB final image, fast cold starts).

# ---- build stage ----
FROM dart:stable AS build

WORKDIR /app

# Copy pubspecs first so `dart pub get` is cached across code-only changes.
# The path dependency (contracts) must be present for resolution to succeed.
COPY packages/contracts/pubspec.* packages/contracts/
COPY server/pubspec.* server/
COPY packages/contracts/ packages/contracts/

WORKDIR /app/server
RUN dart pub get

# Copy the rest of the sources and AOT-compile to a native executable.
COPY server/ .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# ---- runtime stage ----
# `/runtime/` is provided by the official dart image: the minimal set of
# shared libraries needed to run an AOT-compiled Dart binary on scratch.
FROM scratch

COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /app/bin/server

# Render injects PORT; the server reads it (falls back to 3000 locally).
# EXPOSE is documentation only — it does not publish the port.
EXPOSE 3000

CMD ["/app/bin/server"]
