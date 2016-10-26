#!/bin/bash
sudo rkt run ./django_appc-0.0.1-linux-amd64.aci --insecure-options=image --exec=/bin/sh --interactive --dns=8.8.8.8
