#!/bin/bash

create_rms()
{
	mount_path="."

	docker run --name rms \
		--net host \
		--detach \
		-e SOUND_RATES=8000:16000 \
		-e SOUND_TYPES=music:en-us-callie \
		-v ${mount_path}/etc:/etc/freeswitch \
		-v ${mount_path}/snmp:/etc/snmp \
		-v ${mount_path}/resaa-mediation-server-sounds:/usr/share/freeswitch/sounds \
		-v ${mount_path}/freeswitch/scripts/:/usr/share/freeswitch/scripts \
		-v ${mount_path}/freeswitch/voices:/extra-voices \
		docker.resaa.net/mediation-server:latest
		# docker.resaa.net/resaa-mediation-server:latest
}

create_rms
