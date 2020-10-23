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

schema_test wifi-phy
schema_test wifi-ssid

test_inc
utpl -m fs -i wifi.tpl
[ $? -eq 0 ] || error_inc

echo $error/$test failed

return $error
