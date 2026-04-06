#!/bin/bash

while read -r spec
do
	lua "$spec"
done < <(find ./spec -name "*_test.lua")
