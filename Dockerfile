# Copied from https://docs.docker.com/language/golang/build-images/ with minor modifications
FROM registry.ci.openshift.org/openshift/release:golang-1.16  AS build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download -x

# copy the files necessary to building the binaries
COPY pkg/ ./pkg
COPY cmd/ ./cmd

# build all of the binaries and show they were built
RUN for binary_folder in $(find cmd -maxdepth 1 -mindepth 1); do \
		GOFLAGS= CGO_ENABLED=0 go build -o $(basename $binary_folder) $binary_folder/*; \
	done ; \
	find . -type f -executable
##
## Deploy
##

FROM registry.ci.openshift.org/openshift/release:golang-1.16  

COPY --from=build /app/controller-gen /usr/local/bin
COPY --from=build /app/helpgen /usr/local/bin
COPY --from=build /app/type-scaffold /usr/local/bin


ENTRYPOINT ["controller-gen"]

