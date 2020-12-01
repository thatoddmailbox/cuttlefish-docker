# cuttlefish-docker
Run the Android [Cuttlefish virtual device](https://source.android.com/setup/create/cuttlefish) from within a Docker container. This still relies on the host's KVM support, so it's not fully isolated. (and the host will need to trust you, so this won't work on a cloud CI/CD system or similar without some control over the host)

Still very much a work-in-progress. (as in, it doesn't actually work yet)

## Requirements
* A Docker host that you have control over
* On that host, working KVM (see [here](https://askubuntu.com/a/104024) for instruction on how to check that)
	* note that this means your CPU needs to support some form of virtualization extensions
	* this means you can't in a cloud VMs, unless your cloud provider supports nested virtualization (Azure and Google Cloud both claim to, although this hasn't been tested on either)

## Instructions
Download aosp_cf_x86_phone-img-6999531.zip and cvd-host_package.tar.gz as described in the [official instructions](https://android.googlesource.com/device/google/cuttlefish/).

On the host:
```bash
docker build --tag cuttlefish:latest .
docker run -v /dev/log:/dev/log --device /dev/kvm --user=0 -it cuttlefish:latest
```

Then, in the container:
```bash
cd cf
HOME=$PWD ./bin/launch_cvd
```

## Limitations
* It doesn't really work yet
* Still need to figure out how to pass through hardware acceleration stuff
* Path to aosp_cf_x86_phone-img is hardcoded to specific build ID
* Requires manually running launch_cvd
	* This should be automated with the start of the container
* /dev/log from the host needs to be passed through to make crosvm happy; there should be a way around that
	* rsyslogd is installed in the container, but it seems to need some configuration or something
* The code in the container is run with uid 0 (aka root)
	* This should be fixable? Might need to change the usermod commands in the Dockerfile though.
* Persistence doesn't really work yet

