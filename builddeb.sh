#!/bin/bash
dpkg-buildpackage --no-sign
dh_clean
