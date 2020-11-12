#!/bin/sh

test=0
test_inc() {
	test=$((test + 1))
}

error=0
error_inc() {
	error=$((error + 1))
}

schema_test() {
	test_inc

	jsonlint-php $1.schema
	[ $? -eq 0 ] || {
		error_inc
		return
	}

	jsonlint-php $1.cfg
	[ $? -eq 0 ] || {
		error_inc
		return
	}
	
	jsonschema $1.cfg $1.schema
	[ $? -eq 0 ] || error_inc
}

./generate

schema_test network
schema_test wifi-phy
schema_test wifi-ssid
schema_test ntp
schema_test ssh
schema_test system
schema_test log

echo $error/$test failed

return $error
